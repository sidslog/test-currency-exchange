//
//  APIController.h
//  test-currency-exchange
//
//  Created by Sergey Sedov on 5/22/17.
//  Copyright © 2017 Test. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Currency.h"

typedef void(^DownloadRatesBlock)(NSError *, NSDictionary<Currency*, NSNumber*> *);

/// API Methods
@protocol APIClient <NSObject>

- (void) downloadRates: (DownloadRatesBlock) result;

@end

@interface APIController : NSObject<APIClient>

@end
