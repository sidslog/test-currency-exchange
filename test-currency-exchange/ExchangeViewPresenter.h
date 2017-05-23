//
//  ExchangeViewPresenter.h
//  test-currency-exchange
//
//  Created by Sergey Sedov on 5/22/17.
//  Copyright © 2017 Test. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Currency;
@protocol ExchangeClient;
@protocol ExchangeView;


/// Protocol that keeps the logic of the currencies selection, entering an amount of money to exchange and actual exchanging
@protocol ExchangeViewPresenting<NSObject>

/// state

@property (readonly) BOOL isEditingFromAmount;
@property (readonly) NSArray<Currency *> *availableCurrencies;
@property (readonly) NSArray<NSString *> *availableAmounts;
@property (readonly) BOOL canExchange;

- (NSString *) amountForCurrency: (Currency *) currency isFrom: (BOOL) isFrom;
- (BOOL) amountIsValidForCurrency: (Currency *) currency;
- (NSString *) toRateForCurrency: (Currency *) currency;

/// user events

- (void) updateFromAmount: (NSString *) amount;
- (void) updateToAmount: (NSString *) amount;

- (void) changeFromCurrency: (Currency *) currency;
- (void) changeToCurrency: (Currency *) currency;

- (void) changeEditingFromAmount: (BOOL) isEditingFromAmount;

- (void) exchange;

@end

/// The implementation of the `ExchangeViewPresenting` protocol. Communicates with the `ExchangeClient` to load the rates and available amount of money. Updates the view when necessary by calling it's `updateView` method.
@interface ExchangeViewPresenter : NSObject<ExchangeViewPresenting>

- (instancetype)initWithExchangeClient: (id<ExchangeClient>) client view: (id<ExchangeView>) view;

@end
