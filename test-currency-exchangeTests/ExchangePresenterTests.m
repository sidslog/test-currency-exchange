//
//  ExchangePresenterTests.m
//  test-currency-exchange
//
//  Created by Sergey Sedov on 5/23/17.
//  Copyright © 2017 Test. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ExchangeViewPresenter.h"
#import "ExchangeViewController.h"
#import "ExchangeClient.h"
#import "Currency.h"

/**
 I won't implement all the tests, will just show how to mock dependencies
 */

@interface ExchcangeClientMock : NSObject<ExchangeClient>

@property (nonatomic, strong) NSNumber *calculatedRate;
@property (nonatomic, strong) NSDictionary<Currency *, NSNumber *> *available;

@end

@implementation ExchcangeClientMock

- (void) subscribeToAvailableMoneyUpdates: (id<AvailableMoneyUpdatesDelegate>) availableMoneyUpdatesDelegate {
  [availableMoneyUpdatesDelegate availableMoneyUpdated:self.available];
}
- (void) subscribeToRateUpdates: (id<RateUpdatesDelegate>) rateUpdatesDelegate {}

- (NSError *) exchange: (NSNumber *) amount from: (Currency *) from to: (Currency *) to {
  return nil;
}

- (NSNumber *) calculateRateFrom: (Currency *) from to: (Currency *) to {
  return self.calculatedRate;
}

@end


@interface ViewMock : NSObject<ExchangeView>

@property (nonatomic, assign) BOOL updateIsCalled;

@end

@implementation ViewMock

- (void)updateView {
  self.updateIsCalled = YES;
}

@end

@interface ExchangePresenterTests : XCTestCase

@property (nonatomic, strong) ViewMock *view;
@property (nonatomic, strong) ExchcangeClientMock *exchangeClient;

@end

@implementation ExchangePresenterTests

- (void)setUp {
  self.view = [ViewMock new];
  self.exchangeClient = [ExchcangeClientMock new];
  [super setUp];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testExample {
  self.exchangeClient.available = @{ Currency.GBPCurrency: @(20) };
  ExchangeViewPresenter *presenter = [[ExchangeViewPresenter alloc] initWithExchangeClient:self.exchangeClient view:self.view];
  
  XCTAssertEqual(presenter.availableAmounts.count, 3);
  XCTAssertTrue([presenter.availableAmounts[0] isEqualToString:@"You have €0"]);
  XCTAssertTrue([presenter.availableAmounts[1] isEqualToString:@"You have £20"]);
  XCTAssertTrue([presenter.availableAmounts[2] isEqualToString:@"You have $0"]);
}

@end
