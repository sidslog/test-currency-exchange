//
//  ExchangeClient.m
//  test-currency-exchange
//
//  Created by Sergey Sedov on 5/22/17.
//  Copyright © 2017 Test. All rights reserved.
//

#import "ExchangeClient.h"
#import "APIController.h"
#import "ClientErrors.h"

@interface ExchangeClientImpl ()

@property (nonatomic, assign) NSTimeInterval rateUpdateInterval;

@property(nonatomic, strong) NSDictionary<Currency*, NSNumber*> *availableMoney;
@property(nonatomic, strong) NSDictionary<Currency*, NSNumber*> *rates;

@property(nonatomic, strong) NSHashTable* availableMoneyUpdatesDelegates;
@property(nonatomic, strong) NSHashTable* rateUpdatesDelegates;

@property(nonatomic, strong) id<APIClient> apiClient;

@property (nonatomic, strong) NSTimer *rateUpdatesTimer;

@end

@implementation ExchangeClientImpl

- (instancetype)initWithAPIClient: (id<APIClient>) apiClient rateUpdateInterval: (NSTimeInterval) rateUpdateInterval
{
  self = [super init];
  if (self) {
    self.rateUpdateInterval = rateUpdateInterval;
    self.availableMoneyUpdatesDelegates = [NSHashTable weakObjectsHashTable];
    self.rateUpdatesDelegates = [NSHashTable weakObjectsHashTable];
    
    self.apiClient = apiClient;
    
    /// Hardcoded values
    self.availableMoney = @{
                            Currency.GBPCurrency: @100,
                            Currency.EURCurrency: @100,
                            Currency.USDCurrency: @100,
                            };
    
    self.rates = @{};
    
    [self setupRatesUpdates];
  }
  return self;
}

- (void)subscribeToAvailableMoneyUpdates:(id<AvailableMoneyUpdatesDelegate>)availableMoneyUpdatesDelegate {
  [self.availableMoneyUpdatesDelegates addObject:availableMoneyUpdatesDelegate];
  [availableMoneyUpdatesDelegate availableMoneyUpdated:self.availableMoney];
}

- (void) subscribeToRateUpdates:(id<RateUpdatesDelegate>)rateUpdatesDelegate {
  [self.rateUpdatesDelegates addObject:rateUpdatesDelegate];
  [rateUpdatesDelegate ratesUpdated:self.rates];
}

- (NSNumber *) calculateRateFrom: (Currency *) from to: (Currency *) to {
  // we'll use double's to simplify calculations here (probably should use NSDecimal in real app)
  double fromRate = 1;
  double toRate = 1;
  if (from != Currency.EURCurrency) {
    fromRate = self.rates[from].doubleValue;
  }
  
  if (to != Currency.EURCurrency) {
    toRate = self.rates[to].doubleValue;
  }
  
  return @(fromRate / toRate);
}

- (NSError *) exchange:(NSNumber *)amount from:(Currency *)from to:(Currency *)to {
  // Check that client have enough money
  double available = self.availableMoney[from].doubleValue;
  if (available < amount.doubleValue) {
    return [NSError errorWithDomain:ClientErrorDomain code:NotAvailableAmountErrorCode userInfo:nil];
  }
  
  // Update available amounts of money
  double amountInToCurrency = amount.doubleValue / [self calculateRateFrom:from to:to].doubleValue;
  
  NSMutableDictionary *newAvailableMoney = [self.availableMoney mutableCopy];
  newAvailableMoney[from] = @(available - amount.doubleValue);
  newAvailableMoney[to] = @(self.availableMoney[to].doubleValue + amountInToCurrency);
  
  self.availableMoney = [NSDictionary dictionaryWithDictionary:newAvailableMoney];
  return nil;
}

- (void) setupRatesUpdates {
  __weak typeof(self) weakSelf = self;
  self.rateUpdatesTimer = [NSTimer scheduledTimerWithTimeInterval:30 repeats:YES block:^(NSTimer * _Nonnull timer) {
    [weakSelf updateRates];
  }];
  
  [weakSelf updateRates];
}

- (void) updateRates {
  __weak typeof(self) weakSelf = self;
  [self.apiClient downloadRates:^(NSError * error, NSDictionary<Currency*, NSNumber*> *rates) {
    /// ignore the errors for simplicity
    if (rates) {
      weakSelf.rates = rates;
    }
  }];
}

- (void)setRates:(NSDictionary<Currency*, NSNumber*> *)rates {
  _rates = rates;
  for (id<RateUpdatesDelegate> delegate in self.rateUpdatesDelegates) {
    [delegate ratesUpdated:rates];
  }
}

- (void)setAvailableMoney:(NSDictionary<Currency *,NSNumber *> *)availableMoney {
  _availableMoney = availableMoney;
  for (id<AvailableMoneyUpdatesDelegate> delegate in self.availableMoneyUpdatesDelegates) {
    [delegate availableMoneyUpdated:availableMoney];
  }
}

@end
