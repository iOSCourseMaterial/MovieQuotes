//
//  RHMovieQuotesListViewController_iPhone.h
//  MovieQuotesWithEndpoints
//
//  Created by David Fisher on 10/28/13.
//  Copyright (c) 2013 Rose-Hulman. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GTLServiceMoviequotes;

@interface RHMovieQuotesListViewController_iPhone : UITableViewController <UIAlertViewDelegate>


@property (nonatomic, strong) GTLServiceMoviequotes* service;
@property (nonatomic, strong) NSMutableArray* quotes;
- (IBAction)pressedAdd:(id)sender;

@end
