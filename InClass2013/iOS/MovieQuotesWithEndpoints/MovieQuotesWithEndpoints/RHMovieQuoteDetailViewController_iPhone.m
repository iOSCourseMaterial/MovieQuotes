//
//  RHMovieQuoteDetailViewController_iPhone.m
//  MovieQuotesWithEndpoints
//
//  Created by David Fisher on 10/28/13.
//  Copyright (c) 2013 Rose-Hulman. All rights reserved.
//

#import "RHMovieQuoteDetailViewController_iPhone.h"
#import "GTLMoviequotes.h"

@interface RHMovieQuoteDetailViewController_iPhone ()

@end

@implementation RHMovieQuoteDetailViewController_iPhone


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    self.movieTitleTextView.text = self.movieQuote.movieTitle;
    self.quoteTextView.text = self.movieQuote.quote;
}


- (IBAction)pressedEditQuote:(id)sender {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Edit quote"
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Update quote", nil];
    [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    UITextField* movieTitleTextField = [alert textFieldAtIndex:0];
    UITextField* quoteTextField = [alert textFieldAtIndex:1];
    movieTitleTextField.placeholder = @"Movie title";
    quoteTextField.placeholder = @"Quote";

    movieTitleTextField.text = self.movieQuote.movieTitle;
    quoteTextField.text = self.movieQuote.quote;

    [quoteTextField setSecureTextEntry:NO];
    [alert show];

}

#pragma mark - UIAlertViewDelegate


// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) {
        NSLog(@"Do nothing.  User hit cancel");
        return;
    }

    NSString* movieTitle = [[alertView textFieldAtIndex:0] text];
    NSString* quote = [[alertView textFieldAtIndex:1] text];
    self.movieQuote.movieTitle = movieTitle;
    self.movieQuote.quote = quote;
    self.movieTitleTextView.text = self.movieQuote.movieTitle;
    self.quoteTextView.text = self.movieQuote.quote;
    [self _updateMovieQuote];
}

- (void) _updateMovieQuote {
    GTLServiceMoviequotes* service = self.service;
    GTLQueryMoviequotes* query = [GTLQueryMoviequotes queryForMoviequoteInsertWithObject:self.movieQuote];


    NSLog(@"id of the quote = %@", self.movieQuote.identifier);

    // Hack to work around a localhost bug when doing a POST.
    if (kLocalhostTesting) {
        query.JSON = self.movieQuote.JSON;
        query.bodyObject = nil; // Optional line that Dr. Fisher just thought of and hasn't tested.  Hopefully removes the gzip file.
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [service executeQuery:query completionHandler:^(GTLServiceTicket* ticket,
                                                    GTLMoviequotesMovieQuote* returnedMovieQuote,
                                                    NSError* error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (error != nil) {
            // Ooops!  There is a problem!
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error while doing an update."
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
    }];
}

@end
