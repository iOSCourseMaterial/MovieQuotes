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
  var movieQuoteEl = document.createElement('li');
  movieQuoteEl.classList.add('list-group-item');
  var titleEl = document.createElement('h2');
  titleEl.classList.add('list-group-item-heading');
  titleEl.innerHTML = movieQuote.movie_title;
  var quoteEl = document.createElement('p');
  quoteEl.classList.add('list-group-item-text');
  quoteEl.innerHTML = movieQuote.quote;
  movieQuoteEl.appendChild(titleEl);
  movieQuoteEl.appendChild(quoteEl);
  document.getElementById('outputLog').appendChild(movieQuoteEl);
};


/**
 * Lists MovieQuotes via the API.
 */
rh.moviequotes.listMovieQuotes = function() {
  gapi.client.moviequotes.quote.list().execute(
      function(resp) {
        if (!resp.code) {
          document.getElementById('outputLog').innerHTML = '';
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
	  document.getElementById('movie_title').value = '';
      document.getElementById('quote').value = '';
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
