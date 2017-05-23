//
//  ExchangeRouter.m
//  test-currency-exchange
//
//  Created by Sergey Sedov on 5/22/17.
//  Copyright © 2017 Test. All rights reserved.
//

#import "ExchangeRouter.h"
#import "ExchangeClient.h"
#import "ExchangeViewController.h"
#import "ExchangeViewPresenter.h"

@interface ExchangeRouter ()

@property (nonatomic, strong) id<ExchangeClient> exchangeClient;
@property (nonatomic, strong) UIStoryboard *storyboard;
@property (nonatomic, strong) UINavigationController *navigationController;

@end

@implementation ExchangeRouter

- (instancetype)initWithExhangeClient: (id<ExchangeClient>) exchangeClient {
  if (self = [super init]) {
    self.exchangeClient = exchangeClient;
    
    self.storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:NSBundle.mainBundle];
    
    ExchangeViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ExchangeViewController"];
    
    ExchangeViewPresenter *presenter = [[ExchangeViewPresenter alloc] initWithExchangeClient:self.exchangeClient view:controller];
    
    [controller configureWithPresenter:presenter];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
  }
  return self;
}

- (void) loadIntoWindow: (UIWindow *) window {
  window.rootViewController = self.navigationController;
}

@end
