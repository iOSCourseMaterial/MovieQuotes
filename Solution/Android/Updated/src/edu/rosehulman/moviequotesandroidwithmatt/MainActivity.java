package edu.rosehulman.moviequotesandroidwithmatt;

import java.io.IOException;
import java.util.ArrayList;

import android.app.Dialog;
import android.app.DialogFragment;
import android.app.ListActivity;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.ActionMode;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.AbsListView.MultiChoiceModeListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.Toast;

import com.appspot.fisherds_movie_quotes.moviequotes.Moviequotes;
import com.appspot.fisherds_movie_quotes.moviequotes.model.MovieQuote;
import com.appspot.fisherds_movie_quotes.moviequotes.model.MovieQuoteCollection;
import com.google.api.client.extensions.android.http.AndroidHttp;
import com.google.api.client.json.gson.GsonFactory;

public class MainActivity extends ListActivity {

	private static final String MQ = "MQ";

	private Moviequotes mService;

	private ActionMode mActionMode;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

		Moviequotes.Builder builder = new Moviequotes.Builder(AndroidHttp.newCompatibleTransport(), new GsonFactory(),
				null);
		mService = builder.build();

		updateQuotes();
		getListView().setChoiceMode(ListView.CHOICE_MODE_MULTIPLE_MODAL);
		getListView().setMultiChoiceModeListener(new QuoteDeleteModeListener());
	}

	
	private class QuoteDeleteModeListener implements MultiChoiceModeListener {
		
		private ArrayList<MovieQuote> mQuotesToDelete = new ArrayList<MovieQuote>();

		@Override
		public boolean onActionItemClicked(ActionMode mode, MenuItem item) {
			switch( item.getItemId()) {
			case R.id.menu_item_list_view_delete:
				Log.d(MQ, "You pressed the delete button");
				deleteSelectedItems();
				mode.finish();
				return true;
			}
			return false;
		}

		private void deleteSelectedItems() {
			for (MovieQuote aQuote : mQuotesToDelete) {
				
				((MovieQuoteArrayAdapter) getListAdapter()).remove(aQuote);
				((MovieQuoteArrayAdapter) getListAdapter()).notifyDataSetChanged();

				new DeleteQuoteTask().execute(aQuote.getId());
			}
			updateQuotes();
		}

		@Override
		public boolean onCreateActionMode(ActionMode mode, Menu menu) {
			MenuInflater inflater = mode.getMenuInflater();
			inflater.inflate(R.menu.quote_context_menu, menu);
			mode.setTitle("Select other titles to delete");
			return true;
		}

		@Override
		public void onDestroyActionMode(ActionMode mode) {
			
		}

		@Override
		public boolean onPrepareActionMode(ActionMode mode, Menu menu) {
			mQuotesToDelete = new ArrayList<MovieQuote>();
			return true;
		}

		@Override
		public void onItemCheckedStateChanged(ActionMode mode, int position, long id, boolean checked) {
			MovieQuote quoteSelected = (MovieQuote) getListAdapter().getItem(position);
			if (checked) {
				// Get the quote at this position and add it.
				mQuotesToDelete.add(quoteSelected);
			} else {
				mQuotesToDelete.remove(quoteSelected);
			}
			mode.setTitle("Selected " + mQuotesToDelete.size() + " quotes.");
		}
	}

	@Override
	protected void onListItemClick(ListView l, View v, int position, long id) {

		Log.d(MQ, "Clicked to update a quote");
		final MovieQuote currentQuote = (MovieQuote) getListAdapter().getItem(position);

		DialogFragment df = new DialogFragment() {
			@Override
			public Dialog onCreateDialog(Bundle savedInstanceState) {
				Dialog dialog = super.onCreateDialog(savedInstanceState);
				return dialog;
			}

			@Override
			public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
				View dialogView = inflater.inflate(R.layout.insert_quote_dialog, container);
				getDialog().setTitle("Update Quote");

				final Button confirmButton = (Button) dialogView.findViewById(R.id.confirm_insert_quote_button);
				final Button cancelButton = (Button) dialogView.findViewById(R.id.cancel_quote_button);
				final EditText movieTitleEditText = (EditText) dialogView.findViewById(R.id.edittext_movie_title);
				final EditText quoteEditText = (EditText) dialogView.findViewById(R.id.edittext_quote);

				confirmButton.setText("Update");
				movieTitleEditText.setText(currentQuote.getMovieTitle());
				quoteEditText.setText(currentQuote.getQuote());

				confirmButton.setOnClickListener(new View.OnClickListener() {
					@Override
					public void onClick(View v) {
						// Updating an existing quote.
						Log.d(MQ, "Updating an existing quote.");
						currentQuote.setMovieTitle(movieTitleEditText.getText().toString());
						currentQuote.setQuote(quoteEditText.getText().toString());
						((MovieQuoteArrayAdapter) getListAdapter()).notifyDataSetChanged();
						new InsertQuoteTask().execute(currentQuote);
						getDialog().dismiss();
					}
				});
				cancelButton.setOnClickListener(new OnClickListener() {
					@Override
					public void onClick(View v) {
						Log.d(MQ, "Do nothing.");
						getDialog().dismiss();
					}
				});
				return dialogView;
			}
		};
		df.show(getFragmentManager(), "");

		super.onListItemClick(l, v, position, id);
	}

	// ======================================================================
	// Backend communication
	// ======================================================================

	private void updateQuotes() {
		new QueryForQuotesTask().execute(); // Get quotes from the backend.
	}

	private class QueryForQuotesTask extends AsyncTask<Void, Void, MovieQuoteCollection> {

		protected MovieQuoteCollection doInBackground(Void... unused) {
			MovieQuoteCollection quotes = null;
			try {
				// quotes = mService.quotes().list().execute(); // unsorted
				Moviequotes.Quotes.List quotesQuery = mService.quotes().list();
				quotesQuery.setOrder("-last_touch_date_time");
				quotes = quotesQuery.execute();
			} catch (IOException e) {
				Log.d(MQ, e.getMessage(), e);
			}
			return quotes;
		}

		protected void onPostExecute(MovieQuoteCollection quotes) {
			if (quotes == null) {
				Log.d(MQ, "No quotes received");
				Toast.makeText(MainActivity.this, "Query error", Toast.LENGTH_SHORT).show();
				return;
			}
			Log.d(MQ, "Received " + quotes.getItems().size() + " movie quotes.");
			Toast.makeText(MainActivity.this, "Query for quotes completed successfully", Toast.LENGTH_SHORT).show();
			MovieQuoteArrayAdapter adapter = new MovieQuoteArrayAdapter(MainActivity.this,
					android.R.layout.simple_expandable_list_item_2, android.R.id.text1, quotes.getItems());
			setListAdapter(adapter);
		}
	}

	private class InsertQuoteTask extends AsyncTask<MovieQuote, Void, MovieQuote> {

		protected MovieQuote doInBackground(MovieQuote... movieQuotes) {
			MovieQuote returnedQuote = null;
			try {
				returnedQuote = mService.quote().insert(movieQuotes[0]).execute();
			} catch (IOException e) {
				Log.d(MQ, e.getMessage(), e);
			}
			return returnedQuote;
		}

		protected void onPostExecute(MovieQuote quote) {
			if (quote == null) {
				Log.d(MQ, "No quote received");
				Toast.makeText(MainActivity.this, "Error inserting a quote", Toast.LENGTH_SHORT).show();
				return;
			}
			updateQuotes();
		}
	}
	

	/** Delete. */
	private class DeleteQuoteTask extends
			AsyncTask<Long, Void, MovieQuote> {

		protected MovieQuote doInBackground(Long... ids) {
			MovieQuote quoteDeleted = null;
			try {
				quoteDeleted = mService.quote().delete(ids[0]).execute();
			} catch (IOException e) {
				Log.d(MQ, "Error deleting quote. Error message = " + e.getMessage(), e);
			}
			return quoteDeleted;
		}

		protected void onPostExecute(MovieQuote quote) {
			if (quote == null) {
				Log.d(MQ, "No quote was deleted.");
				Toast.makeText(MainActivity.this, "Delete error", Toast.LENGTH_SHORT).show();
				return;
			}
			Log.d(MQ, "Delete complete. Received back quote = " + quote.getQuote());
			Toast.makeText(MainActivity.this, "Delete completed successfully", Toast.LENGTH_SHORT).show();
			//updateQuotes(); // Done at the end of all deletes instead.
		}
	}

	// ======================================================================
	// Menus
	// ======================================================================

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(R.menu.main, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case R.id.add_quote:

			addItem();

			// mSelectedPosition = NO_POSITION_SELECTED;
			// showDialog(INSERT_QUOTE_DIALOG_ID);
			return true;
		case R.id.force_sync:
			updateQuotes();
			return true;
		}
		return super.onOptionsItemSelected(item);
	}

	public void addItem() {
		DialogFragment df = new DialogFragment() {
			@Override
			public Dialog onCreateDialog(Bundle savedInstanceState) {
				Dialog dialog = super.onCreateDialog(savedInstanceState);
				return dialog;
			}

			@Override
			public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
				View dialogView = inflater.inflate(R.layout.insert_quote_dialog, container);
				getDialog().setTitle("New Quote");

				final Button confirmButton = (Button) dialogView.findViewById(R.id.confirm_insert_quote_button);
				final Button cancelButton = (Button) dialogView.findViewById(R.id.cancel_quote_button);
				final EditText movieTitleEditText = (EditText) dialogView.findViewById(R.id.edittext_movie_title);
				final EditText quoteEditText = (EditText) dialogView.findViewById(R.id.edittext_quote);

				if (confirmButton == null) {
					Log.d(MQ, "Confirm button is null");
				}
				confirmButton.setOnClickListener(new View.OnClickListener() {
					@Override
					public void onClick(View v) {
						Log.d(MQ, "Updating a new quote.");
						MovieQuote newQuote = new MovieQuote();
						newQuote.setMovieTitle(movieTitleEditText.getText().toString());
						newQuote.setQuote(quoteEditText.getText().toString());

						// Toast.makeText(getActivity(), "Quote = " +
						// newQuote.getQuote(), Toast.LENGTH_SHORT).show();

						((MovieQuoteArrayAdapter) getListAdapter()).add(newQuote);
						((MovieQuoteArrayAdapter) getListAdapter()).notifyDataSetChanged();

						new InsertQuoteTask().execute(newQuote);
						getDialog().dismiss();
					}
				});
				cancelButton.setOnClickListener(new OnClickListener() {
					@Override
					public void onClick(View v) {
						Log.d(MQ, "Do nothing.");
						getDialog().dismiss();
					}
				});
				return dialogView;
			}
		};
		df.show(getFragmentManager(), "");
	}
}
