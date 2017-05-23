//
//  ExchangeViewController.h
//  test-currency-exchange
//
//  Created by Sergey Sedov on 5/22/17.
//  Copyright © 2017 Test. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ExchangeViewPresenting;
@class Currency;

@protocol ExchangeView <NSObject>

- (void) updateView;

@end

/**
 View controller that allows user to select currencies to exchange, enter an amount and perform an exchange.
 
 You chould configure this view controller with presenter.
 
 This view controller conforms to the `UpdateView` protocol, so you can use it as a `view` for presenter.
 */
@interface ExchangeViewController : UIViewController<ExchangeView>

/// Configures this view controller with presenter.
- (void) configureWithPresenter: (id<ExchangeViewPresenting>) presenter;

@end
