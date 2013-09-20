//
//  RHQuotesViewController.m
//  Movie Quotes
//
//  Created by David Fisher on 9/19/13.
//  Copyright (c) 2013 Rose-Hulman. All rights reserved.
//

#import "RHQuotesViewController.h"
#import "GTLMoviequotes.h"
#import "RHQuoteDetailViewController_iPhone.h"
#import "GTMHTTPFetcherLogging.h"


#define kMovieQuoteCellIdentifier @"QuoteCell"
#define LOCAL_HOST_TESTING YES

@interface RHQuotesViewController ()
@property (nonatomic, readonly) GTLServiceMoviequotes* service;
@end

@implementation RHQuotesViewController
@synthesize service = _service;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self _queryForQuotes];
}


- (NSMutableArray*) movieQuotes {
    if (_movieQuotes == nil) {
        _movieQuotes = [[NSMutableArray alloc] init];
    }
    return _movieQuotes;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movieQuotes.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMovieQuoteCellIdentifier forIndexPath:indexPath];
    GTLMoviequotesMovieQuote* currentQuote = self.movieQuotes[indexPath.row];
    cell.textLabel.text = currentQuote.quote;
    cell.detailTextLabel.text = currentQuote.movieTitle;
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        GTLMoviequotesMovieQuote* quoteToDelete = self.movieQuotes[indexPath.row];
        [self _deleteQuoteWithId:quoteToDelete.identifier];
        [self.movieQuotes removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

    }
}

#pragma mark - Endpoints

- (GTLServiceMoviequotes*) service {
    if (_service == nil) {
        _service = [[GTLServiceMoviequotes alloc] init];
        if (LOCAL_HOST_TESTING) {
            [_service setRpcURL:[NSURL URLWithString:@"http://localhost:8080/_ah/api/rpc?prettyPrint=false"]]; // Simulator
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
    }
    
    NSLog(@"Sending...");
    NSLog(@" movieTitle = %@", gtlMovieQuote.movieTitle);
    NSLog(@" quote = %@", gtlMovieQuote.quote);
    
    [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLMoviequotesMovieQuote *returnedGtlMovieQuote, NSError *error) {
        
        if (error == nil) {
            NSLog(@"Done with insert.  Returned...");
            NSLog(@" movieTitle = %@", returnedGtlMovieQuote.movieTitle);
            NSLog(@" quote = %@", returnedGtlMovieQuote.quote);
            NSLog(@" id = %@", returnedGtlMovieQuote.identifier);
            NSLog(@" last_touch_date_time = %@", returnedGtlMovieQuote.lastTouchDateTime);
            
            [self.movieQuotes addObject:returnedGtlMovieQuote];
            [self.tableView reloadData];
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
    
    [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLMoviequotesMovieQuoteCollection* collection, NSError *error) {
        if (error == nil) {
            NSLog(@"Done with query for quotes! Returned %d quotes.", collection.items.count);
            self.movieQuotes = [collection.items mutableCopy];
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
    [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLMoviequotesMovieQuote *returnedGtlQuote, NSError *error) {
        if (error == nil) {
            NSLog(@"Delete complete on the backend");
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

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        GTLMoviequotesMovieQuote* newQuote = [[GTLMoviequotesMovieQuote alloc] init];
        newQuote.movieTitle = [[alertView textFieldAtIndex:0] text];
        newQuote.quote = [[alertView textFieldAtIndex:1] text];
        [self _insertQuote:newQuote];
    }
}
@end
