/**
 * @fileoverview
 * Provides methods for the Hello Endpoints sample UI and interaction with the
 * Hello Endpoints API.
 *
 * @author danielholevoet@google.com (Dan Holevoet)
 */

/** namespace. */
var rh = rh || {};
rh.moviequotes = rh.moviequotes || {};

/**
 * Prints a movie quote to the log.
 * param {Object} movieQuote MovieQuote to print.
 */
rh.moviequotes.print = function(movieQuote) {
////  var movieQuoteEl = document.createElement('li');
//	$movieQuoteEl = $('<li></li>');
////  movieQuoteEl.classList.add('list-group-item');
//	$movieQuoteEl.addClass('list-group-item');
////  var titleEl = document.createElement('h2');
//	$titleEl = $('<h2></h2>');
////  titleEl.classList.add('list-group-item-heading');
//	$titleEl.addClass('list-group-item-heading');
////  titleEl.innerHTML = movieQuote.movie_title;
//	$titleEl.html(movieQuote.movie_title);
////  var quoteEl = document.createElement('p');
//	$quoteEl = $('<p></p>');
////  quoteEl.classList.add('list-group-item-text');
//	$quoteEl.addClass('list-group-item-text');
////  quoteEl.innerHTML = movieQuote.quote;
//	$quoteEl.html(movieQuote.quote);
////  movieQuoteEl.appendChild(titleEl);
//	$movieQuoteEl.append($titleEl);
////  movieQuoteEl.appendChild(quoteEl);
//	$movieQuoteEl.append($quoteEl);
////  document.getElementById('outputLog').appendChild(movieQuoteEl);
//	$('#outputLog').append($movieQuoteEl);
	

	$titleEl = $('<h2></h2>').addClass('list-group-item-heading').html(movieQuote.movie_title);
	$quoteEl = $('<p></p>').addClass('list-group-item-text').html(movieQuote.quote);
	$movieQuoteEl = $('<li></li>').addClass('list-group-item').append($titleEl).append($quoteEl);
	$('#outputLog').prepend($movieQuoteEl);
};


/**
 * Lists MovieQuotes via the API.
 */
rh.moviequotes.listMovieQuotes = function() {
  gapi.client.moviequotes.quote.list({'order': 'last_touch_date_time'}).execute(
      function(resp) {
        if (!resp.code) {
        	$('#outputLog').html('');
          resp.items = resp.items || [];
          for (var i = 0; i < resp.items.length; i++) {
            rh.moviequotes.print(resp.items[i]);
          }
        }
      });
};


/**
 * Insert a movie quote
 * @param {string} movieTitle Title of the movie for the quote
 * @param {string} quote Quote from the movie.
 */
rh.moviequotes.insertMovieQuote = function(movieTitle, quote) {
  gapi.client.moviequotes.quote.insert({
      'movie_title': movieTitle,
      'quote': quote
    }).execute(function(resp) {
      if (!resp.code) {
        rh.moviequotes.print(resp);
      }
    });
  $('#add-quote-modal').modal('hide');
};


/**
 * Enables the button callbacks in the UI.
 */
rh.moviequotes.enableButtons = function() {
  $('#display-add-quote-modal').click(function() {
	  $('#movie_title').val('');
	  $('#quote').val('');
	  $('#add-quote-modal').modal('show');
  });

  $('#refresh-button').click(rh.moviequotes.listMovieQuotes);

  $('#add-quote-button').click(function() {
    rh.moviequotes.insertMovieQuote(
  		  $('#movie_title').val(),
		  $('#quote').val());
  });
};

/**
 * Initializes the application.
 * @param {string} apiRoot Root of the API's path.
 */
rh.moviequotes.init = function(apiRoot) {
	console.log("init called");
  var apisToLoad;
  var callback = function() {
	  console.log("Loaded an api");
    if (--apisToLoad == 0) {
      rh.moviequotes.enableButtons();
      rh.moviequotes.listMovieQuotes();
    }
  }
  apisToLoad = 1; // must match number of calls to gapi.client.load()
  gapi.client.load('moviequotes', 'v1', callback, apiRoot);
};
