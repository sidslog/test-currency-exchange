//
//  ExchangeClient.h
//  test-currency-exchange
//
//  Created by Sergey Sedov on 5/22/17.
//  Copyright © 2017 Test. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Currency.h"

@protocol APIClient;

@protocol RateUpdatesDelegate <NSObject>

- (void) ratesUpdated: (NSDictionary<Currency*, NSNumber*> *) rates;

@end

@protocol AvailableMoneyUpdatesDelegate <NSObject>

- (void) availableMoneyUpdated: (NSDictionary<Currency*, NSNumber*> *) availableMoney;

@end


/// Represents the state of the app and state updates. Users can subscribe to the updates of available money and currency rates.
@protocol ExchangeClient <NSObject>

- (void) subscribeToAvailableMoneyUpdates: (id<AvailableMoneyUpdatesDelegate>) availableMoneyUpdatesDelegate;
- (void) subscribeToRateUpdates: (id<RateUpdatesDelegate>) rateUpdatesDelegate;
- (NSError *) exchange: (NSNumber *) amount from: (Currency *) from to: (Currency *) to;
- (NSNumber *) calculateRateFrom: (Currency *) from to: (Currency *) to;

@end


/// Implementation of the `ExchangeClient`. Stores the actual state and communicates with the `apiClient` in order to load the rates.
@interface ExchangeClientImpl : NSObject<ExchangeClient>

- (instancetype)initWithAPIClient: (id<APIClient>) apiClient rateUpdateInterval: (NSTimeInterval) rateUpdateInterval;

@end
