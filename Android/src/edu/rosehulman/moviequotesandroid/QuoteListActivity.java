package edu.rosehulman.moviequotesandroid;

import java.io.IOException;

import android.app.ListActivity;
import android.content.Context;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.widget.ListView;

import com.google.api.client.extensions.android.http.AndroidHttp;
import com.google.api.client.json.gson.GsonFactory;

import fisherds_movie_quotes.moviequotes.Moviequotes;
import fisherds_movie_quotes.moviequotes.model.MovieQuoteCollection;

public class QuoteListActivity extends ListActivity {
	
	private Moviequotes mService;
	private static final String MQ = "MQ";
	private static final boolean USE_LOCAL_HOST = false;
	private static final String LOCAL_HOST_URL = "http://10.0.1.11:8080/_ah/api/";
	

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_quote_list);
        
        Moviequotes.Builder builder = new Moviequotes.Builder(AndroidHttp.newCompatibleTransport(),
        		new GsonFactory(), null);
        builder.setApplicationName(getString(R.string.app_name));
        if (USE_LOCAL_HOST) {
        	builder.setRootUrl(LOCAL_HOST_URL);
        }
        
        mService = builder.build();

        new QueryQuotesTask(this).execute(); // Get quotes from the backend.
        
//        ArrayList<MovieQuote> testQuotes = new ArrayList<MovieQuote>();
//        MovieQuote quote1 = new MovieQuote();
//        quote1.setMovieTitle("Title1");
//        quote1.setQuote("Quote1");
//        testQuotes.add(quote1);
//        MovieQuote quote2 = new MovieQuote();
//        quote2.setMovieTitle("Title2");
//        quote2.setQuote("Quote2");
//        testQuotes.add(quote2);
//        MovieQuote quote3 = new MovieQuote();
//        quote3.setMovieTitle("Title3");
//        quote3.setQuote("Quote3");
//        testQuotes.add(quote3);
//        MovieQuoteArrayAdapter adapter = new MovieQuoteArrayAdapter(this, android.R.layout.simple_expandable_list_item_2, android.R.id.text1, testQuotes);
//        setListAdapter(adapter);
    }
    
    

    private class QueryQuotesTask extends AsyncTask<Void, Void, MovieQuoteCollection> {
  	  Context context;

  	  public QueryQuotesTask(Context context) {
  	    this.context = context;
  	  }

  	  protected MovieQuoteCollection doInBackground(Void... unused) {
  		  MovieQuoteCollection quotes = null;
  	    try {
  	    	quotes = mService.quotes().list().execute();
  	    } catch (IOException e) {
  	      Log.d(MQ, e.getMessage(), e);
  	    }
  	    return quotes;
  	  }

  	  protected void onPostExecute(MovieQuoteCollection quotes) {
  		  if (quotes == null) {
  			  Log.d(MQ, "No quotes received");
  			  return;
  		  }
  		  Log.d(MQ, "Received " + quotes.getItems().size() + " movie quotes.");
          MovieQuoteArrayAdapter adapter = new MovieQuoteArrayAdapter(context, android.R.layout.simple_expandable_list_item_2, android.R.id.text1, quotes.getItems());
          setListAdapter(adapter);
          
          // TODO: Add a long press listener similar to the ArmScripts app.
  	  }
  	}
    
    @Override
	protected void onListItemClick(ListView listView, View selectedView, int position, long id) {
		super.onListItemClick(listView, selectedView, position, id);
		
		// Show a Toast or other dialog.
	}
    
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.quote_list, menu);
        return true;
    }
    
}


