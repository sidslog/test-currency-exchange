//
//  ExchangeClientTests.m
//  test-currency-exchange
//
//  Created by Sergey Sedov on 5/23/17.
//  Copyright © 2017 Test. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "APIController.h"
#import "ExchangeClient.h"

/**
 I won't implement all the tests, will just show how to mock dependencies
 */


@interface APIClientMock : NSObject<APIClient>

@property (nonatomic, strong) NSDictionary<Currency *, NSNumber *> *rates;

@end

@implementation APIClientMock

- (void)downloadRates:(DownloadRatesBlock)result {
  result(nil, self.rates);
}

@end

@interface RateSubscriber : NSObject<RateUpdatesDelegate>

@property (nonatomic, strong) NSDictionary<Currency *, NSNumber *> *resultRates;

@end

@implementation RateSubscriber

- (void)ratesUpdated:(NSDictionary<Currency *,NSNumber *> *)rates {
  self.resultRates = rates;
}

@end

@interface ExchangeClientTests : XCTestCase

@property (nonatomic, strong) APIClientMock *apiClient;
@property (nonatomic, strong) RateSubscriber *rateResult;

@end

@implementation ExchangeClientTests

- (void)setUp {
  self.apiClient = [APIClientMock new];
  self.rateResult = [RateSubscriber new];
  [super setUp];
}

- (void)tearDown {
  [super tearDown];
}

- (void) testRateUpdates {
  self.apiClient.rates = @{ Currency.GBPCurrency: @(0.2) };
  
  ExchangeClientImpl *client = [[ExchangeClientImpl alloc] initWithAPIClient:self.apiClient rateUpdateInterval:10];
  [client subscribeToRateUpdates:self.rateResult];
  
  XCTAssertEqual(self.rateResult.resultRates[Currency.GBPCurrency].doubleValue, 0.2);
}

@end
