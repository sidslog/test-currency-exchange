//
//  RatesParser.m
//  test-currency-exchange
//
//  Created by Sergey Sedov on 5/22/17.
//  Copyright © 2017 Test. All rights reserved.
//

#import "RatesParser.h"

@interface RatesParser () <NSXMLParserDelegate>

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSMutableDictionary<Currency*, NSNumber*> *result;

@end

@implementation RatesParser

- (instancetype)initWithData: (NSData *) data {
  if (self = [super init]) {
    self.data = data;
    self.result = [@{} mutableCopy];
  }
  return self;
}

- (NSDictionary<Currency*, NSNumber*> *) parseRates {
  NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.data];
  parser.delegate = self;
  if (![parser parse]) {
    return nil;
  }
  
  return self.result;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(NSDictionary<NSString *, NSString *> *)attributeDict {
  if ([elementName isEqualToString:@"Cube"] && attributeDict[@"currency"] != nil && attributeDict[@"rate"] != nil) {
    NSString *currencyCode = attributeDict[@"currency"];
    NSNumber *rate = @([attributeDict[@"rate"] doubleValue]);
    
    /// process only known currencies
    if ([currencyCode isEqualToString:Currency.EURCurrency.code]) {
      _result[Currency.EURCurrency] = rate;
    }
    if ([currencyCode isEqualToString:Currency.GBPCurrency.code]) {
      _result[Currency.GBPCurrency] = rate;
    }
    if ([currencyCode isEqualToString:Currency.USDCurrency.code]) {
      _result[Currency.USDCurrency] = rate;
    }
  }
}

@end
