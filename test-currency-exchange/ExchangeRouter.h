//
//  ExchangeRouter.h
//  test-currency-exchange
//
//  Created by Sergey Sedov on 5/22/17.
//  Copyright © 2017 Test. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@protocol ExchangeClient;

/// Router is responsible for app loading and navigation between screens
@interface ExchangeRouter: NSObject

- (instancetype)initWithExhangeClient: (id<ExchangeClient>) exchangeClient;

- (void) loadIntoWindow: (UIWindow *) window;

@end
