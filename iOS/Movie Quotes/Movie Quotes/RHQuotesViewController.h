//
//  RHQuotesViewController.h
//  Movie Quotes
//
//  Created by David Fisher on 9/19/13.
//  Copyright (c) 2013 Rose-Hulman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RHQuotesViewController : UITableViewController <UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray* movieQuotes; // of GTLMoviequotesMovieQuotes
- (IBAction)pressedAdd:(id)sender;

@end
