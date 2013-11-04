//
//  RHQuotesViewController.m
//  Movie Quotes
//
//  Created by David Fisher on 9/19/13.
//  Copyright (c) 2013 Rose-Hulman. All rights reserved.
//

#import "RHQuotesViewController.h"
#import "GTLMoviequotes.h"
#import "RHQuoteDetailViewController.h"
#import "GTMHTTPFetcherLogging.h"


#define kQuoteCellIdentifier @"QuoteCell"
#define kLoadingQuotesCellIdentifier @"LoadingQuotesCell"
#define kNoQuotesCellIdentifier @"NoQuotesCell"

#define kQuoteDetailSegue @"QuoteDetailSegue"


@interface RHQuotesViewController ()
@property (nonatomic, readonly) GTLServiceMoviequotes* service;
@property (nonatomic) BOOL initialQueryComplete;
@end

@implementation RHQuotesViewController
@synthesize service = _service;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

- (void) viewWillAppear:(BOOL)animated {
    self.initialQueryComplete = NO;
    [self _queryForQuotes];
}

- (NSMutableArray*) movieQuotes {
    if (_movieQuotes == nil) {
        _movieQuotes = [[NSMutableArray alloc] init];
    }
    return _movieQuotes;
}

- (IBAction)pressedAdd:(id)sender {
    UIAlertView* addQuoteAlert = [[UIAlertView alloc] initWithTitle:@"Create a new quote"
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"OK", nil];
    
    [addQuoteAlert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    UITextField* movieTitleTextField = [addQuoteAlert textFieldAtIndex:0];
    movieTitleTextField.placeholder = @"Movie title";
    UITextField* quoteTextField = [addQuoteAlert textFieldAtIndex:1];
    quoteTextField.placeholder = @"Quote";
    [quoteTextField setSecureTextEntry:NO];
    [addQuoteAlert show];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.movieQuotes.count == 0) {
        return 1;
    }
    return self.movieQuotes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (self.movieQuotes.count == 0) {
        if (self.initialQueryComplete) {
            cell = [tableView dequeueReusableCellWithIdentifier:kNoQuotesCellIdentifier forIndexPath:indexPath];
            cell.accessoryView = nil;
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:kLoadingQuotesCellIdentifier forIndexPath:indexPath];
            UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            cell.accessoryView = activityIndicatorView;
            [((UIActivityIndicatorView*)cell.accessoryView) startAnimating];
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:kQuoteCellIdentifier forIndexPath:indexPath];
        GTLMoviequotesMovieQuote* currentQuote = self.movieQuotes[indexPath.row];
        cell.textLabel.text = currentQuote.quote;
        cell.detailTextLabel.text = currentQuote.movieTitle;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.movieQuotes.count == 0) {
        return NO;
    }
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        GTLMoviequotesMovieQuote* quoteToDelete = self.movieQuotes[indexPath.row];
        [self _deleteQuoteWithId:quoteToDelete.identifier];
        [self.movieQuotes removeObjectAtIndex:indexPath.row];
        if (self.movieQuotes.count == 0) {
            [tableView reloadData];
            [self setEditing:NO animated:YES];
        } else {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.movieQuotes.count == 0) {
        return;
    }
    [self performSegueWithIdentifier:kQuoteDetailSegue sender:self.movieQuotes[indexPath.row]];
}

#pragma mark - Endpoints

- (GTLServiceMoviequotes*) service {
    if (_service == nil) {
        _service = [[GTLServiceMoviequotes alloc] init];
        if (LOCAL_HOST_TESTING) {
            NSLog(@"Setting to localhost api url");
            [_service setRpcURL:[NSURL URLWithString:@"http://localhost:21080/_ah/api/rpc?prettyPrint=false"]]; // Simulator
        }
        _service.retryEnabled = YES;
        [GTMHTTPFetcher setLoggingEnabled:YES];
    }
    return _service;
}

- (void) _insertQuote:(GTLMoviequotesMovieQuote*) gtlMovieQuote {
    GTLQueryMoviequotes *query = [GTLQueryMoviequotes queryForQuoteInsertWithObject:gtlMovieQuote];
    
    // Temporary hacky fix to an annoying gzip bug.
    if (LOCAL_HOST_TESTING) {
        [query setJSON:gtlMovieQuote.JSON];
        query.bodyObject = nil;
    }
    
    NSLog(@"Sending...");
    NSLog(@" movieTitle = %@", gtlMovieQuote.movieTitle);
    NSLog(@" quote = %@", gtlMovieQuote.quote);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLMoviequotesMovieQuote *returnedGtlMovieQuote, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (error == nil) {
            NSLog(@"Done with insert.  Returned...");
            NSLog(@" movieTitle = %@", returnedGtlMovieQuote.movieTitle);
            NSLog(@" quote = %@", returnedGtlMovieQuote.quote);
            NSLog(@" id = %@", returnedGtlMovieQuote.identifier);
            NSLog(@" last_touch_date_time = %@", returnedGtlMovieQuote.lastTouchDateTime);
            gtlMovieQuote.identifier = returnedGtlMovieQuote.identifier;

            [self _queryForQuotes];
        } else {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error during insert"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (void) _queryForQuotes {
    GTLQueryMoviequotes *query = [GTLQueryMoviequotes queryForQuotesList];
    query.order = @"-last_touch_date_time";
    
    NSLog(@"Sending request for movie quotes");
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLMoviequotesMovieQuoteCollection* collection, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (error == nil) {
            NSLog(@"Done with query for quotes! Returned %d quotes.", collection.items.count);
            self.movieQuotes = [collection.items mutableCopy];
            self.initialQueryComplete = YES;
            [self.tableView reloadData];
        } else {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error during query for quotes"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (void) _deleteQuoteWithId:(NSNumber*) idToDelete {
    GTLQueryMoviequotes *query = [GTLQueryMoviequotes queryForQuoteDeleteWithIdentifier:[idToDelete longLongValue]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLMoviequotesMovieQuote *returnedGtlQuote, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (error == nil) {
            NSLog(@"Delete completed on the backend");
            //[self _queryForQuotes];
        } else {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error during delete"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kQuoteDetailSegue]) {
        RHQuoteDetailViewController* destination = segue.destinationViewController;
        destination.movieQuote = sender;
        destination.service = self.service;
    }
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        GTLMoviequotesMovieQuote* newQuote = [[GTLMoviequotesMovieQuote alloc] init];
        newQuote.movieTitle = [[alertView textFieldAtIndex:0] text];
        newQuote.quote = [[alertView textFieldAtIndex:1] text];
        [self.movieQuotes insertObject:newQuote atIndex:0];

        if (LOCAL_HOST_TESTING) {
            // This is an optional change.  Turns out localhost testing is too fast and the insert can finish
            // and a query can finish before the animaiton finishes.  So for localhost testing don't ever do
            // and animation.  Just do a reload and that will avoid the race condition.
            [self.tableView reloadData];
        } else {
            // Use the fancy insert animation with the deployed version.
            if (self.movieQuotes.count == 1) {
                [self.tableView reloadData];
            } else {
                NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }

        [self _insertQuote:newQuote];
    }
}
@end
