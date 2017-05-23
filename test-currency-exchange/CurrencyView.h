//
//  CurrencyView.h
//  test-currency-exchange
//
//  Created by Sergey Sedov on 5/22/17.
//  Copyright © 2017 Test. All rights reserved.
//

#import <UIKit/UIKit.h>

/// Displays currency tile in the carousel in the exchange screen
@interface CurrencyView : UIView

+ (instancetype) loadFromNib;

- (void) configure: (NSString *) code
         available: (NSString *) available
              rate: (NSString *) rate
            amount: (NSString *) amount
       fromIsValid: (BOOL) fromIsValid
      onTextChange: (void (^)(NSString *))onTextChange
      onBecomeFirstResponder: (void (^)())onBecomeFirstResponder;

- (void) configure: (NSString *) code
         available: (NSString *) available
              rate: (NSString *) rate
            amount: (NSString *) amount
       fromIsValid: (BOOL) fromIsValid;

@end
