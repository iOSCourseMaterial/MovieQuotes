package edu.rosehulman.moviequotesandroid;

import java.util.List;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;
import fisherds_movie_quotes.moviequotes.model.MovieQuote;

public class MovieQuoteArrayAdapter extends ArrayAdapter<MovieQuote> {

	public MovieQuoteArrayAdapter(Context context, int resource,
			int textViewResourceId, List<MovieQuote> objects) {
		super(context, resource, textViewResourceId, objects);
	}
	
	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		View view = super.getView(position, convertView, parent);
		TextView textView1 = (TextView) view.findViewById(android.R.id.text1);
		TextView textView2 = (TextView) view.findViewById(android.R.id.text2);
		textView2.setText(getItem(position).getMovieTitle());
		textView1.setText(getItem(position).getQuote());
		return view;
	}
}
