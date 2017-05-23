//
//  CurrencyRate.m
//  test-currency-exchange
//
//  Created by Sergey Sedov on 5/22/17.
//  Copyright © 2017 Test. All rights reserved.
//

#import "Currency.h"

NSString *GBPCode = @"GBP";
NSString *EURCode = @"EUR";
NSString *USDCode = @"USD";

NSString *GBPName = @"GBP";
NSString *EURName = @"EUR";
NSString *USDName = @"USD";

NSString *GBPSymbol = @"£";
NSString *EURSymbol = @"€";
NSString *USDSymbol = @"$";


@interface CurrencyProvider : NSObject

@property (nonatomic, strong) NSMutableDictionary<NSString *, Currency *> *currencies;

+ (instancetype) sharedInstance;

- (Currency *)currencyWithCode:(NSString *)code andName: (NSString *) name andSymbol: (NSString *) symbol;

@end


@implementation Currency

- (instancetype)initWithCode: (NSString *) code andName: (NSString *) name andSymbol: (NSString *) symbol {
  if (self = [super init]) {
    _code = code;
    _name = name;
    _symbol = symbol;
  }
  return self;
}

+ ( Currency * _Nonnull ) EURCurrency {
  return [[CurrencyProvider sharedInstance] currencyWithCode:EURCode andName:EURName andSymbol:EURSymbol];
}

+ ( Currency * _Nonnull ) USDCurrency {
  return [[CurrencyProvider sharedInstance] currencyWithCode:USDCode andName:USDName andSymbol:USDSymbol];
}

+ ( Currency * _Nonnull ) GBPCurrency {
  return [[CurrencyProvider sharedInstance] currencyWithCode:GBPCode andName:GBPName andSymbol:GBPSymbol];
}

- (id)copyWithZone:(NSZone *)zone {
  return self;
}

- (NSUInteger)hash {
  return self.code.hash;
}

@end

@implementation CurrencyProvider

- (instancetype)init {
  if (self = [super init]) {
    _currencies = [NSMutableDictionary new];
  }
  return self;
}

+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  static CurrencyProvider *instance = nil;
  dispatch_once(&onceToken, ^{
    instance = [[CurrencyProvider alloc] init];
  });
  return instance;
}

- (Currency *)currencyWithCode:(NSString *)code andName: (NSString *) name andSymbol: (NSString *) symbol {
  if (self.currencies[code] != nil) {
    return self.currencies[code];
  }
  
  Currency *currency = [[Currency alloc] initWithCode:code andName:name andSymbol:symbol];
  self.currencies[code] = currency;
  return currency;
}

@end
