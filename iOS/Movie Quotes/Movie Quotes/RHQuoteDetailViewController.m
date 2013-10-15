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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    self.movieTitleTextView.text = self.movieQuote.movieTitle;
    self.quoteTextView.text = self.movieQuote.quote;
}

@end
