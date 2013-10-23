
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
    @MovieQuote.query_method(query_fields=('limit', 'order', 'pageToken'),
                             path='moviequote/list',
                             name='moviequote.list',
                             http_method='GET')
    def movie_quote_list(self, query):
        """ Get a list of movie quotes. """
        return query
    
    # Delete movie quote
    @MovieQuote.method(request_fields=('id',),
                       path='moviequote/delete/{id}',
                       name='moviequote.delete',
                       http_method='GET')
    def movie_quote_delete(self, a_quote):
        """ Delete a MovieQuote. """
        # Check to make sure this quote really exist in the datastore.
        if not a_quote.from_datastore:
            raise endpoints.NotFoundException('No quote found with that id')
        # Then delete it.
        a_quote.key.delete()
        return MovieQuote(quote='deleted')
        
        

app = endpoints.api_server([MovieQuotesApi], restricted=False)
