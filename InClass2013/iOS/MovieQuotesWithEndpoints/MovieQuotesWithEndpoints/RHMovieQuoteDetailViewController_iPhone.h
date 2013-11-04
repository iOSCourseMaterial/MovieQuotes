//
//  RHMovieQuoteDetailViewController_iPhone.h
//  MovieQuotesWithEndpoints
//
//  Created by David Fisher on 10/28/13.
//  Copyright (c) 2013 Rose-Hulman. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GTLMoviequotesMovieQuote;
@class GTLServiceMoviequotes;

#define kLocalhostTesting                 YES

@interface RHMovieQuoteDetailViewController_iPhone : UIViewController <UIAlertViewDelegate>

@property (nonatomic, strong) GTLServiceMoviequotes* service;
@property (strong, nonatomic) GTLMoviequotesMovieQuote* movieQuote;

@property (strong, nonatomic) IBOutlet UITextView *movieTitleTextView;
@property (strong, nonatomic) IBOutlet UITextView *quoteTextView;

- (IBAction)pressedEditQuote:(id)sender;


@end
