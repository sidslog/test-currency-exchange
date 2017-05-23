//
//  RatesParser.h
//  test-currency-exchange
//
//  Created by Sergey Sedov on 5/22/17.
//  Copyright © 2017 Test. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Currency.h"

/// Parses raw data to a dictionary of supported rates (currently only USD, EUR and GBP are supported).
@interface RatesParser : NSObject

- (instancetype)initWithData: (NSData *) data;
- (NSDictionary<Currency*, NSNumber*> *) parseRates;

@end
