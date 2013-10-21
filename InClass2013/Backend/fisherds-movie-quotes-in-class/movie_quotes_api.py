
from protorpc import remote
from google.appengine.ext import endpoints

from models import MovieQuote

@endpoints.api(name='moviequotes', version='v1',
               description='Movie Quotes API',
               hostname='fisherds-movie-quotes-in-class.appspot.com')
class MovieQuotesApi(remote.Service):
    """ Provides the Movie Quote JSON api methods. """
    
    # Insert movie quote
    @MovieQuote.method(path='moviequote/insert',
                       http_method='POST',
                       name='moviequote.insert')
    def movie_quote_insert(self, a_quote):
        """ Insert the quote into the database. """
        # Add this object into the database.
        a_quote.put()
        # Return the object that was inserted.
        return a_quote
    
    # Read movie quotes
    
    # Delete movie quote

app = endpoints.api_server([MovieQuotesApi], restricted=False)
