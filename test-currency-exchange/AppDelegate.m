//
//  AppDelegate.m
//  test-currency-exchange
//
//  Created by Sergey Sedov on 5/22/17.
//  Copyright © 2017 Test. All rights reserved.
//

#import "AppDelegate.h"
#import "ExchangeClient.h"
#import "APIController.h"
#import "Currency.h"
#import "ExchangeRouter.h"

@interface AppDelegate ()

@property (nonatomic, strong) id<ExchangeClient> exchangeClient;
@property (nonatomic, strong) id<APIClient> apiClient;
@property (nonatomic, strong) ExchangeRouter *router;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  self.apiClient = [[APIController alloc] init];
  self.exchangeClient = [[ExchangeClientImpl alloc] initWithAPIClient:self.apiClient rateUpdateInterval:30];

  self.router = [[ExchangeRouter alloc] initWithExhangeClient:self.exchangeClient];
  
  self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
  [self.router loadIntoWindow:self.window];
  
  [self.window makeKeyAndVisible];
  
  return YES;
}

@end
