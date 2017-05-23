//
//  CurrencyRate.h
//  test-currency-exchange
//
//  Created by Sergey Sedov on 5/22/17.
//  Copyright © 2017 Test. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Currency : NSObject<NSCopying>

@property(readonly) NSString * _Nonnull name;
@property(readonly) NSString * _Nonnull code;
@property(readonly) NSString * _Nonnull symbol;

+ (Currency * _Nonnull ) EURCurrency;
+ (Currency * _Nonnull ) USDCurrency;
+ (Currency * _Nonnull ) GBPCurrency;

@end
