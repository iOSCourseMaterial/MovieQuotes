//
//  RHQuoteDetailViewController.h
//  Movie Quotes
//
//  Created by David Fisher on 10/9/13.
//  Copyright (c) 2013 Rose-Hulman. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GTLMoviequotesMovieQuote;
@class GTLServiceMoviequotes;

#define LOCAL_HOST_TESTING YES

@interface RHQuoteDetailViewController : UIViewController <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *movieTitleTextView;
@property (weak, nonatomic) IBOutlet UITextView *quoteTextView;
@property (nonatomic, strong) GTLMoviequotesMovieQuote* movieQuote;
@property (nonatomic, weak) GTLServiceMoviequotes* service;

- (IBAction)pressedEdit:(id)sender;

@end
