/**
 * @fileoverview
 * User interactions for the Movie Quotes web client.
 *
 * @author fisherds@gmail.com (Dave Fisher)
 */

/** Namespace declarations. */
var rh = rh || {};
rh.moviequotes = rh.moviequotes || {};
rh.moviequotes.endpoints = rh.moviequotes.endpoints || {};

/**
 * @param {Object} Map of IDs to movieQuotes.
 */
rh.moviequotes.quotes = {}


/**
 * @param {bool} Tracks the editing status.
 */
rh.moviequotes.editEnabled = false;


/**
 * @param {number} Constant for when to ID is selected.
 * @const
 */
rh.moviequotes.NO_ID_SELECTED = -1;


/**
 * @param {number} Tracks the editing status.
 */
rh.moviequotes.selectedId = rh.moviequotes.NO_ID_SELECTED;


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
 * Finds the ID for the MovieQuote using the list-group-item's id attribute.
 */
rh.moviequotes.getQuoteId = function($rowButton) {
	var quoteId = 0;
	var $parent = null;
	var parentEls = $rowButton.parents();
	for (var i = 0; i < parentEls.length; i++) {
		$parent = $(parentEls[i]);
		if ($parent.hasClass('list-group-item')) {
			quoteId = $parent.attr('id');
			break;
		}
	}
	return quoteId;
}

/**
 * Deletes the MovieQuote for this row.
 */
rh.moviequotes.deleteQuote = function ($deleteButton) {
	var quoteId = rh.moviequotes.getQuoteId($deleteButton);
	if (quoteId != 0) {
		rh.moviequotes.endpoints.deleteMovieQuote(quoteId);
	}
}


/**
 * Edits the MovieQuote for this row.
 */
rh.moviequotes.editQuote = function ($editButton) {
	

}



/**
 * Enables the button callbacks in the UI.
 */
rh.moviequotes.enableButtons = function() {
  $('#display-add-quote-modal').click(function() {
	  $('#myModalLabel').html('Add a movie quote');
	  $('#add-quote-button').html("Add Quote");
	  rh.moviequotes.selectedId = rh.moviequotes.NO_ID_SELECTED;
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
	  $('#myModalLabel').html('Edit movie quote');
	  $('#add-quote-button').html("Edit Quote");
	  rh.moviequotes.selectedId = rh.moviequotes.getQuoteId($(this));
	  var selectedQuote = rh.moviequotes.quotes[rh.moviequotes.selectedId];
	  $('#movie_title').val(selectedQuote.movie_title);
	  $('#quote').val(selectedQuote.quote);
	  $('#add-quote-modal').modal('show');
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
  gapi.client.moviequotes.quote.list({'order': '-last_touch_date_time'}).execute(
      function(resp) {
        if (!resp.code) {
        	$('#outputLog').html('');
          resp.items = resp.items || [];
          // Loop through in reverse order since the newest goes on top.
          rh.moviequotes.quotes = {}
          for (var i = resp.items.length - 1; i >= 0; i--) {
        	var movieQuote = resp.items[i];
            rh.moviequotes.print(movieQuote);
            rh.moviequotes.quotes[movieQuote.id] = movieQuote;
          }
        }
      });
};


/**
 * Insert a movie quote
 * @param {string} movieTitle Title of the movie for the quote
 * @param {string} quote Quote from the movie.
 */
rh.moviequotes.endpoints.insertMovieQuote = function(movieTitle, quote) {
  var postJson = {
	      'movie_title': movieTitle,
	      'quote': quote
	    };
  if (rh.moviequotes.selectedId != rh.moviequotes.NO_ID_SELECTED) {
	  postJson.id = rh.moviequotes.selectedId;
  }
  gapi.client.moviequotes.quote.insert(postJson).execute(function(resp) {
      if (!resp.code) {
    	  if (rh.moviequotes.selectedId == rh.moviequotes.NO_ID_SELECTED) {
    	     rh.moviequotes.print(resp);  
    	  } else {
    		  $('#' + rh.moviequotes.selectedId + ' .list-group-item-heading').html(movieTitle);
    		  $('#' + rh.moviequotes.selectedId + ' .list-group-item-text').html(quote);
    	  }
      }
    });
  $('#add-quote-modal').modal('hide');
};

/**
 * Delete a movie quote
 * @param {int} id Id of the movieQuote to delete
 */
rh.moviequotes.endpoints.deleteMovieQuote = function(movieQuoteId) {
  gapi.client.moviequotes.quote.delete({
      'id': movieQuoteId
    }).execute(function(resp) {
      if (!resp.code) {
    	  console.log("Deleting now remove from DOM");
    	  $('#' + movieQuoteId).slideUp();
      }
    });
};
