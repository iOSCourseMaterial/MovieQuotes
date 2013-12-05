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
  var element = document.createElement('div');
  element.classList.add('row');
  element.innerHTML = movieQuote.movie_title + " " + movieQuote.quote;
  document.getElementById('outputLog').appendChild(element);
};


/**
 * Lists MovieQuotes via the API.
 */
rh.moviequotes.listMovieQuotes = function() {
	document.getElementById('outputLog').innerHTML = '';
  gapi.client.moviequotes.quote.list().execute(
      function(resp) {
        if (!resp.code) {
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
	console.log("Insert a movie quote");
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
  document.getElementById('display-add-quote-modal').onclick = function() {
	  console.log("Show the modal");
	  $('#add-quote-modal').modal('show');
  }

  document.getElementById('refresh-button').onclick = function() {
    rh.moviequotes.listMovieQuotes()();
  }

  document.getElementById('add-quote-button').onclick = function() {
    rh.moviequotes.insertMovieQuote(
        document.getElementById('movie_title').value,
        document.getElementById('quote').value);
  }
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
