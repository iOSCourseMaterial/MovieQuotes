//
//  RHQuoteDetailViewController.m
//  Movie Quotes
//
//  Created by David Fisher on 10/9/13.
//  Copyright (c) 2013 Rose-Hulman. All rights reserved.
//

#import "RHQuoteDetailViewController.h"
#import "GTLMoviequotes.h"

@interface RHQuoteDetailViewController ()

@end

@implementation RHQuoteDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    self.movieTitleTextView.text = self.movieQuote.movieTitle;
    self.quoteTextView.text = self.movieQuote.quote;
}

- (IBAction)pressedEdit:(id)sender {
    UIAlertView* editQuoteAlert = [[UIAlertView alloc] initWithTitle:@"Edit quote"
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Update", nil];
    
    [editQuoteAlert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    UITextField* movieTitleTextField = [editQuoteAlert textFieldAtIndex:0];
    movieTitleTextField.placeholder = @"Movie title";
    movieTitleTextField.text = self.movieQuote.movieTitle;
    UITextField* quoteTextField = [editQuoteAlert textFieldAtIndex:1];
    quoteTextField.placeholder = @"Quote";
    quoteTextField.text = self.movieQuote.quote;
    [quoteTextField setSecureTextEntry:NO];
    [editQuoteAlert show];
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        self.movieQuote.movieTitle = [[alertView textFieldAtIndex:0] text];
        self.movieQuote.quote = [[alertView textFieldAtIndex:1] text];
        
        
        self.movieTitleTextView.text = self.movieQuote.movieTitle;
        self.quoteTextView.text = self.movieQuote.quote;
        
        [self _updateQuote];
    }
}


- (void) _updateQuote {
    GTLQueryMoviequotes *query = [GTLQueryMoviequotes queryForQuoteInsertWithObject:self.movieQuote];
    
    // Temporary hacky fix to an annoying gzip bug.
    if (LOCAL_HOST_TESTING) {
        [query setJSON:self.movieQuote.JSON];
    }
    
    NSLog(@"Sending...");
    NSLog(@" movieTitle = %@", self.movieQuote.movieTitle);
    NSLog(@" quote = %@", self.movieQuote.quote);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLMoviequotesMovieQuote *returnedGtlMovieQuote, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (error == nil) {
            NSLog(@"Done with insert.  Returned...");
            NSLog(@" movieTitle = %@", returnedGtlMovieQuote.movieTitle);
            NSLog(@" quote = %@", returnedGtlMovieQuote.quote);
            NSLog(@" id = %@", returnedGtlMovieQuote.identifier);
            NSLog(@" last_touch_date_time = %@", returnedGtlMovieQuote.lastTouchDateTime);
            
        } else {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error during quote update."
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

@end
