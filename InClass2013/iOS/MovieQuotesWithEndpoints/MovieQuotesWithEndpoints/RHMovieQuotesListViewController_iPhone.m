//
//  RHMovieQuotesListViewController_iPhone.m
//  MovieQuotesWithEndpoints
//
//  Created by David Fisher on 10/28/13.
//  Copyright (c) 2013 Rose-Hulman. All rights reserved.
//

#import "RHMovieQuotesListViewController_iPhone.h"
#import "GTLMoviequotes.h"
#import "GTMHTTPFetcherLogging.h"

#define kMovieQuoteCellIdentifier         @"MovieQuoteCell"
#define kLoadingMovieQuotesCellIdentifier @"LoadingMovieQuotesCell"
#define kNoMovieQuotesCellIdentifier      @"NoMovieQuotesCell"

#define kLocalhostTesting                 YES
#define kLocalhostRpcUrl                  @"http://localhost:20080/_ah/api/rpc?prettyPrint=false"

@interface RHMovieQuotesListViewController_iPhone ()
@property (nonatomic) BOOL initialQueryComplete;
@end

@implementation RHMovieQuotesListViewController_iPhone

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewWillAppear:(BOOL)animated {
    self.initialQueryComplete = NO;
    // TODO: Query the backend
    [self _queryForQuotes];
}

- (GTLServiceMoviequotes*) service {
    if (_service == nil) {
        _service = [[GTLServiceMoviequotes alloc] init];
        
        if (kLocalhostTesting) {
            _service.rpcURL = [NSURL URLWithString:kLocalhostRpcUrl];
        }
        _service.retryEnabled = YES;
        [GTMHTTPFetcher setLoggingEnabled:YES];
    }
    return _service;
}

- (NSMutableArray*) quotes {
    if (_quotes == nil) {
        _quotes = [[NSMutableArray alloc] init];
        
        
        // Add some code for initial testing.
//        GTLMoviequotesMovieQuote* mq1 = [[GTLMoviequotesMovieQuote alloc] init];
//        mq1.movieTitle = @"Local movie 1";
//        mq1.quote = @"Local quote 1";
//        [_quotes addObject:mq1];
//        
//        
//        GTLMoviequotesMovieQuote* mq2 = [[GTLMoviequotesMovieQuote alloc] init];
//        mq2.movieTitle = @"Local movie 2";
//        mq2.quote = @"Local quote 2";
//        [_quotes addObject:mq2];
//        
//        
//        GTLMoviequotesMovieQuote* mq3 = [[GTLMoviequotesMovieQuote alloc] init];
//        mq3.movieTitle = @"Local movie 3";
//        mq3.quote = @"Local quote 3";
//        [_quotes addObject:mq3];
        
    }
    return _quotes;
}

- (IBAction) pressedAdd:(id)sender {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Create a new quote"
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Create quote", nil];
    
    [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    UITextField* movieTitleTextField = [alert textFieldAtIndex:0];
    UITextField* quoteTextField = [alert textFieldAtIndex:1];
    movieTitleTextField.placeholder = @"Movie title";
    quoteTextField.placeholder = @"Quote";
    [quoteTextField setSecureTextEntry:NO];
    [alert show];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.quotes.count == 0) {
        return 1;
    }
    return self.quotes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (self.quotes.count == 0) {
        if (self.initialQueryComplete) {
            cell = [tableView dequeueReusableCellWithIdentifier:kNoMovieQuotesCellIdentifier forIndexPath:indexPath];
            cell.accessoryView = nil;
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:kLoadingMovieQuotesCellIdentifier forIndexPath:indexPath];
            UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            cell.accessoryView = spinner;
            [spinner startAnimating];
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:kMovieQuoteCellIdentifier forIndexPath:indexPath];
        cell.accessoryView = nil;
        GTLMoviequotesMovieQuote* currentQuote = self.quotes[indexPath.row];
        cell.textLabel.text = currentQuote.quote;
        cell.detailTextLabel.text = currentQuote.movieTitle;
    }
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (self.quotes.count == 0) {
        return NO;
    }
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        // Fire off a message to remove this quote on the backend
        
        GTLMoviequotesMovieQuote* quoteToDelete = self.quotes[indexPath.row];
        [self _deleteQuote:quoteToDelete.identifier];
        
        [self.quotes removeObjectAtIndex:indexPath.row];
        if (self.quotes.count == 0) {
            [tableView reloadData];
        } else {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }

    }
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark - UIAlertViewDelegate


// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) {
        NSLog(@"Do nothing.  User hit cancel");
        return;
    }
    
    NSString* movieTitle = [[alertView textFieldAtIndex:0] text];
    NSString* quote = [[alertView textFieldAtIndex:1] text];
    
    
    GTLMoviequotesMovieQuote* newQuote = [[GTLMoviequotesMovieQuote alloc] init];
    newQuote.movieTitle = movieTitle;
    newQuote.quote = quote;
    
    // Add to the top.  ONLY add it locally (which we'll later change).
    [self.quotes insertObject:newQuote atIndex:0];

//    if (self.quotes.count == 1) {
//        [self.tableView reloadData];
//    } else {
//        NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    }
    
    [self.tableView reloadData];

    
    [self _insertQuote:newQuote];
}



#pragma mark - Endpoints

- (void) _queryForQuotes {
    GTLServiceMoviequotes* service = self.service;
    GTLQueryMoviequotes* query = [GTLQueryMoviequotes queryForMoviequoteList];
    query.limit = 30;
    query.order = @"-last_touch_date_time";
    // Execute the query using the service object
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [service executeQuery:query completionHandler:^(GTLServiceTicket* ticket,
                                                    GTLMoviequotesMovieQuoteCollection* movieQuotes,
                                                    NSError* error) {
        //   Inside the callback block process the result
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.initialQueryComplete = YES;
        if (error != nil){
            // Ooops!  There is a problem!
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error while doing a query for quotes."
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [self.tableView reloadData];
            [alert show];
            return;
        }
        self.quotes = [movieQuotes.items mutableCopy];

        // Optional.
        if (movieQuotes.nextPageToken != nil) {
            NSLog(@"Note, there are more quotes on the server.  You could call query again to get more using the page token %@", movieQuotes.nextPageToken);
        }
        
        [self.tableView reloadData];
    }];
}

- (void) _insertQuote:(GTLMoviequotesMovieQuote*) newQuote {
    GTLServiceMoviequotes* service = self.service;
    GTLQueryMoviequotes* query = [GTLQueryMoviequotes queryForMoviequoteInsertWithObject:newQuote];
    // Hack to work around a localhost bug when doing a POST.
    if (kLocalhostTesting) {
        query.JSON = newQuote.JSON;
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [service executeQuery:query completionHandler:^(GTLServiceTicket* ticket,
                                                    GTLMoviequotesMovieQuote* returnedMovieQuote,
                                                    NSError* error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (error != nil) {
            // Ooops!  There is a problem!
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error while doing an insert."
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        // Update this newQuote with the id of the returnedQuote
        newQuote.identifier = returnedMovieQuote.identifier;
        
        // Optional
        [self _queryForQuotes];
        
    }];
    
}

- (void) _deleteQuote:(NSNumber*) idToDelete {
    GTLServiceMoviequotes* service = self.service;
    GTLQueryMoviequotes* query = [GTLQueryMoviequotes queryForMoviequoteDeleteWithIdentifier:idToDelete.longLongValue];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [service executeQuery:query completionHandler:^(GTLServiceTicket* ticket,
                                                    GTLMoviequotesMovieQuote* returnedMovieQuote,
                                                    NSError* error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (error != nil) {
            // Ooops!  There is a problem!
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error while doing a delete."
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        // Delete worked.  Good for us.  Already done with delete on client.
        
        
        // Optional (very options)
//        [self _queryForQuotes];
        
    }];
}

@end






