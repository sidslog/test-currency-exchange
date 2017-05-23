//
//  ExchangeViewPresenter.m
//  test-currency-exchange
//
//  Created by Sergey Sedov on 5/22/17.
//  Copyright © 2017 Test. All rights reserved.
//

#import "ExchangeViewPresenter.h"
#import "ExchangeViewController.h"
#import "Currency.h"
#import "ExchangeClient.h"

@interface ExchangeViewPresenter () <RateUpdatesDelegate, AvailableMoneyUpdatesDelegate>

@property (weak) id<ExchangeView> view;
@property (weak) id<ExchangeClient> exchangeClient;

@property (nonatomic, strong) NSArray<Currency *> *availableCurrencies;
@property (nonatomic, strong) NSArray<NSString *> *availableAmounts;
@property (nonatomic, strong) Currency *fromCurrency;
@property (nonatomic, strong) Currency *toCurrency;

@property (nonatomic, strong) NSDictionary<Currency *, NSNumber *> *rates;
@property (nonatomic, strong) NSDictionary<Currency *, NSNumber *> *availableMoney;

@property (nonatomic, strong) NSNumber *fromAmount;
@property (nonatomic, strong) NSNumber *toAmount;

@property (assign) BOOL isEditingFromAmount;

@end

@implementation ExchangeViewPresenter

+ (NSNumberFormatter *)numberFormatter
{
  static NSNumberFormatter *_numberFormatter = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _numberFormatter = [[NSNumberFormatter alloc] init];
    _numberFormatter.maximumFractionDigits = 2;
    [_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
  });
  
  return _numberFormatter;
}

- (instancetype)initWithExchangeClient: (id<ExchangeClient>) client view: (id<ExchangeView>) view {
  if (self = [super init]) {
    self.exchangeClient = client;
    self.view = view;
    
    self.availableCurrencies = @[Currency.EURCurrency, Currency.GBPCurrency, Currency.USDCurrency];
    
    self.fromCurrency = self.availableCurrencies.firstObject;
    self.toCurrency = self.availableCurrencies[1];
    
    [self.exchangeClient subscribeToRateUpdates:self];
    [self.exchangeClient subscribeToAvailableMoneyUpdates:self];
  }
  return self;
}

- (BOOL) canExchange {
  return [self amountNumberForCurrency:self.fromCurrency isFrom:YES].doubleValue > 0 && [self amountIsValidForCurrency:self.fromCurrency] && self.fromCurrency != self.toCurrency;
}

- (NSString *) amountForCurrency: (Currency *) currency isFrom: (BOOL) isFrom{
  return [[ExchangeViewPresenter numberFormatter] stringFromNumber:[self amountNumberForCurrency:currency isFrom:isFrom]];
}

- (NSNumber *) amountNumberForCurrency: (Currency *) currency isFrom: (BOOL) isFrom{
  if (self.isEditingFromAmount) {
    if (isFrom) {
      return self.fromAmount;
    } else {
      double rate = [self.exchangeClient calculateRateFrom:currency to:self.fromCurrency].doubleValue;
      return @(self.fromAmount.doubleValue * rate);
    }
  } else {
    if (!isFrom) {
      return self.toAmount;
    } else {
      double rate = [self.exchangeClient calculateRateFrom:currency to:self.toCurrency].doubleValue;
      return @(self.toAmount.doubleValue * rate);
    }
  }
}

- (BOOL) amountIsValidForCurrency: (Currency *) currency {
  NSNumber *amount = [self amountNumberForCurrency:currency isFrom:YES];
  return self.availableMoney[currency].doubleValue >= amount.doubleValue;
}

- (NSString *) toRateForCurrency: (Currency *) currency {
  NSNumber *rate = [self.exchangeClient calculateRateFrom:self.fromCurrency to:currency];
  NSString *rateString = [[ExchangeViewPresenter numberFormatter] stringFromNumber:rate];
  return [NSString stringWithFormat:@"%@1 = %@%@", currency.symbol, self.fromCurrency.symbol, rateString];
}

- (void) updateAvailableAmounts {
  NSMutableArray *amounts = [NSMutableArray array];
  for (Currency *currency in self.availableCurrencies) {
    NSString *amountString = self.availableMoney[currency] ? [[ExchangeViewPresenter numberFormatter] stringFromNumber:self.availableMoney[currency]] : @"0";
    [amounts addObject: [NSString stringWithFormat:@"You have %@%@", currency.symbol, amountString]];
  }
  self.availableAmounts = [NSArray arrayWithArray:amounts];
  
  [self.view updateView];
}

- (void)changeToCurrency:(Currency *)currency {
  self.toCurrency = currency;
  [self updateAvailableAmounts];
}

- (void)changeFromCurrency:(Currency *)currency {
  self.fromCurrency = currency;
  [self updateAvailableAmounts];
}

- (void)updateFromAmount:(NSString *)amount {
  self.fromAmount = @([amount doubleValue]);
  [self.view updateView];
}

- (void)updateToAmount:(NSString *)amount {
  self.toAmount = @([amount doubleValue]);
  [self.view updateView];
}

- (void) changeEditingFromAmount: (BOOL) isEditingFromAmount {
  self.isEditingFromAmount = isEditingFromAmount;
}

- (void) exchange {
  [self.exchangeClient exchange:[self amountNumberForCurrency:self.fromCurrency isFrom:YES] from:self.fromCurrency to:self.toCurrency];
}

#pragma mark - rate updates

- (void) ratesUpdated: (NSDictionary<Currency*, NSNumber*> *) rates {
  self.rates = rates;
  [self.view updateView];
}

#pragma mark - available money updates

- (void)availableMoneyUpdated:(NSDictionary<Currency *,NSNumber *> *)availableMoney {
  self.availableMoney = availableMoney;
  [self updateAvailableAmounts];
}


@end
