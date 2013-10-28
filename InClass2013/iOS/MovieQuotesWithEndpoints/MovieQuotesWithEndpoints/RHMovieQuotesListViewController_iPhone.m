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

@interface RHMovieQuotesListViewController_iPhone ()
@property (nonatomic) BOOL initialQueryComplete;
@end

@implementation RHMovieQuotesListViewController_iPhone

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewWillAppear:(BOOL)animated {
    self.initialQueryComplete = NO;
    // TODO: Query the backend
    
}
- (GTLServiceMoviequotes*) service {
    if (_service == nil) {
        _service = [[GTLServiceMoviequotes alloc] init];
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

@end
