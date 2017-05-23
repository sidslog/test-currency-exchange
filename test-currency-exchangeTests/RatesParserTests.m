//
//  RestParserTests.m
//  test-currency-exchange
//
//  Created by Sergey Sedov on 5/23/17.
//  Copyright © 2017 Test. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RatesParser.h"
#import "Currency.h"

@interface RatesParserTests : XCTestCase

@end

@implementation RatesParserTests

- (void)testExample {
  NSData *data = [NSData dataWithContentsOfFile:[[NSBundle bundleForClass:RatesParserTests.class] pathForResource:@"test" ofType:@"xml"]];
  RatesParser *parser = [[RatesParser alloc] initWithData:data];
  NSDictionary<Currency *, NSNumber *> *rates = [parser parseRates];
  XCTAssertEqual(rates[Currency.GBPCurrency].doubleValue, 0.86353);
}

@end
