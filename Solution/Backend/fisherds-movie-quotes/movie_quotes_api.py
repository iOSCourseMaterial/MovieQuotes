""" Movie quotes API"""


from google.appengine.ext import endpoints
from protorpc import remote

from models import MovieQuote

@endpoints.api(name='moviequotes', version='v1', description='Movie Quotes API', hostname='fisherds-movie-quotes.appspot.com')
class MovieQuotesApi(remote.Service):
    """ Class which defines moviesquotes API"""
    
    @MovieQuote.method(path='quote', http_method='POST', name='quote.insert')
    def quote_insert(self, a_quote):
        """ Insert a quote. """
        a_quote.put()
        return a_quote
    
    @MovieQuote.query_method(query_fields=('limit', 'order', 'pageToken'), path='quotes', http_method='GET', name='quotes.list')
    def quotes_list(self, query):
        """ Return a list of quotes. """
        return query
    
    @MovieQuote.method(request_fields=('id',), path='quote/delete/{id}', http_method='GET', name='quote.delete')
    def quote_delete(self, a_quote):
        """ Delete a quote. """
        if not a_quote.from_datastore:
            raise endpoints.NotFoundException("Quote not found.")
        a_quote.key.delete()
        return MovieQuote(quote="deleted")

APPLICATION = endpoints.api_server([MovieQuotesApi], restricted=False)    

    