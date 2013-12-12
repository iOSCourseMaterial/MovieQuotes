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
rh.moviequotes.endpoints = rh.moviequotes.endpoints || {};

/**
 * @param {bool} Tracks the editing status.
 */
rh.moviequotes.editEnabled = false;

/**
 * Prints a movie quote to the log.
 * param {Object} movieQuote MovieQuote to print.
 */
rh.moviequotes.print = function(movieQuote) {
	$titleEl = $('<h2></h2>').addClass('list-group-item-heading').html(movieQuote.movie_title);
	$quoteEl = $('<p></p>').addClass('list-group-item-text').html(movieQuote.quote);
	$quoteInfo = $('<div class="quote-info"></div>').append($titleEl).append($quoteEl);

	$buttonGroup = $('<div class="row-buttons"></div>');
	$buttonGroup.append('<button class = "btn btn-success individual-edit-button">Edit</button>');
	$buttonGroup.append('<button class = "btn btn-danger individual-delete-button">Delete</button>');
	
	if (rh.moviequotes.editEnabled) {
		$quoteInfo.addClass('narrow-for-edit');
	} else {
		$buttonGroup.hide();
	}
	$movieQuoteEl = $('<li></li>').attr('id', movieQuote.id).addClass('list-group-item').append($quoteInfo).append($buttonGroup);
	$('#outputLog').prepend($movieQuoteEl);
};



/**
 * Shows or hides the edit and delete buttons.
 */
rh.moviequotes.toggleEdit = function() {
	if (rh.moviequotes.editEnabled) {
		rh.moviequotes.editEnabled = false;
		$('#toggle-edit-mode-button').html("Edit");
		$('.row-buttons').fadeOut('fast');
		$('.quote-info').removeClass('narrow-for-edit');
	} else {
		rh.moviequotes.editEnabled = true;
		$('#toggle-edit-mode-button').html("Done");
		console.log("change to done");
		$('.row-buttons').fadeIn('fast');
		$('.quote-info').addClass('narrow-for-edit');
	}
}



/**
 * 
 */
rh.moviequotes.deleteQuote = function ($deleteButton) {
	var quoteId = 0;
	var $parent = null;
	var parentEls = $deleteButton.parents();
	for (var i = 0; i < parentEls.length; i++) {
		$parent = $(parentEls[i]);
		if ($parent.hasClass('list-group-item')) {
			quoteId = $parent.attr('id');
			break;
		}
	}
	if (quoteId != 0) {
		rh.moviequotes.endpoints.deleteMovieQuote(quoteId, $parent);
	}
}
		
/**
 * Enables the button callbacks in the UI.
 */
rh.moviequotes.enableButtons = function() {
  $('#display-add-quote-modal').click(function() {
	  $('#movie_title').val('');
	  $('#quote').val('');
	  $('#add-quote-modal').modal('show');
  });

  $('#refresh-button').click( function() {
	  if (rh.moviequotes.editEnabled) {
		  rh.moviequotes.toggleEdit();
	  }
	  rh.moviequotes.endpoints.listMovieQuotes();
  });

  $('#add-quote-button').click(function() {
    rh.moviequotes.endpoints.insertMovieQuote(
  		  $('#movie_title').val(),
		  $('#quote').val());
  });
  
  $('#toggle-edit-mode-button').click( function() {
	 rh.moviequotes.toggleEdit(); 
  });
  
  $('#outputLog').on('click', '.individual-edit-button', function() {
	  rh.moviequotes.editQuote($(this));
  });
  
  $('#outputLog').on('click', '.individual-delete-button', function() {
	  rh.moviequotes.deleteQuote($(this));
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
      rh.moviequotes.endpoints.listMovieQuotes();
    }
  }
  apisToLoad = 1; // must match number of calls to gapi.client.load()
  gapi.client.load('moviequotes', 'v1', callback, apiRoot);
};


// ----------------------- Endpoints methods -----------------------

/**
 * Lists MovieQuotes via the API.
 */
rh.moviequotes.endpoints.listMovieQuotes = function() {
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
rh.moviequotes.endpoints.insertMovieQuote = function(movieTitle, quote, existingId) {
  var postJson = {
	      'movie_title': movieTitle,
	      'quote': quote
	    };
  if (existingId) {
	  postJson.id = existingId
  }
  gapi.client.moviequotes.quote.insert(postJson).execute(function(resp) {
      if (!resp.code) {
        rh.moviequotes.print(resp);
      }
    });
  $('#add-quote-modal').modal('hide');
};

/**
 * Delete a movie quote
 * @param {int} id Id of the movieQuote to delete
 */
rh.moviequotes.endpoints.deleteMovieQuote = function(movieQuoteId, $row) {
  gapi.client.moviequotes.quote.delete({
      'id': movieQuoteId
    }).execute(function(resp) {
      if (!resp.code) {
    	  console.log("Deleted now remove from DOM");
    	  $row.slideUp();
      }
    });
};
