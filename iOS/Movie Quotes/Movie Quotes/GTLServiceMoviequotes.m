/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2013 Google Inc.
 */

//
//  GTLServiceMoviequotes.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   moviequotes/v1
// Description:
//   Movie Quotes API
// Classes:
//   GTLServiceMoviequotes (0 custom class methods, 0 custom properties)

#import "GTLMoviequotes.h"

@implementation GTLServiceMoviequotes

#if DEBUG
// Method compiled in debug builds just to check that all the needed support
// classes are present at link time.
+ (NSArray *)checkClasses {
  NSArray *classes = [NSArray arrayWithObjects:
                      [GTLQueryMoviequotes class],
                      [GTLMoviequotesMovieQuote class],
                      [GTLMoviequotesMovieQuoteCollection class],
                      nil];
  return classes;
}
#endif  // DEBUG

- (id)init {
  self = [super init];
  if (self) {
    // Version from discovery.
    self.apiVersion = @"v1";

    // From discovery.  Where to send JSON-RPC.
    // Turn off prettyPrint for this service to save bandwidth (especially on
    // mobile). The fetcher logging will pretty print.
    self.rpcURL = [NSURL URLWithString:@"https://fisherds-movie-quotes/_ah/api/rpc?prettyPrint=false"];
  }
  return self;
}

@end
