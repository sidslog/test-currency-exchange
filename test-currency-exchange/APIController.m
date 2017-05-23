//
//  APIController.m
//  test-currency-exchange
//
//  Created by Sergey Sedov on 5/22/17.
//  Copyright © 2017 Test. All rights reserved.
//

#import "APIController.h"
#import "RatesParser.h"

@implementation APIController

- (void)downloadRates:(DownloadRatesBlock)result {
  
  NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml"]];
  
  NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    
    if (error) {
      if (result) {
        dispatch_async(dispatch_get_main_queue(), ^{
          result(error, nil);
        });
      }
      return;
    }
    
    // ignore checking for response code for simplicity
    
    RatesParser *parser = [[RatesParser alloc] initWithData:data];
    if (result) {
      dispatch_async(dispatch_get_main_queue(), ^{
        result(nil, parser.parseRates);
      });
    }
  }];
  
  [task resume];
}

@end
