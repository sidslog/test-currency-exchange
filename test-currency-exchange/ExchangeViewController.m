//
//  ExchangeViewController.m
//  test-currency-exchange
//
//  Created by Sergey Sedov on 5/22/17.
//  Copyright © 2017 Test. All rights reserved.
//

#import "ExchangeViewController.h"
#import "ExchangeClient.h"
#import "ExchangeViewPresenter.h"
#import "CurrencyView.h"
#import "CarouselView.h"

@interface ExchangeViewController ()<UIScrollViewDelegate, CarouselViewDatasource>

@property (nonatomic, strong) id<ExchangeViewPresenting> presenter;

@property (weak, nonatomic) IBOutlet CarouselView *fromCarousel;
@property (weak, nonatomic) IBOutlet CarouselView *toCarousel;
@property (weak, nonatomic) IBOutlet UIPageControl *fromPageControl;
@property (weak, nonatomic) IBOutlet UIPageControl *toPageControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMargin;

@end

@implementation ExchangeViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.toCarousel.datasource = self;
  self.fromCarousel.datasource = self;
  
  [self.fromCarousel reloadData];
  [self.toCarousel reloadData];
  
  [[self.fromCarousel viewAtIndex:0] becomeFirstResponder];
  
  self.fromPageControl.numberOfPages = self.presenter.availableCurrencies.count;
  self.toPageControl.numberOfPages = self.presenter.availableCurrencies.count;
  
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Exchange" style:UIBarButtonItemStylePlain target:self action:@selector(onExchange)];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) onExchange {
  [self.presenter exchange];
}

- (void) configureWithPresenter: (id<ExchangeViewPresenting>) presenter {
  self.presenter = presenter;
}

- (void)updateView {
  if (self.isViewLoaded) {
    
    self.navigationItem.rightBarButtonItem.enabled = self.presenter.canExchange;
    
    for (NSInteger i = 0; i < [self numberOfViewsInCarousel:self.fromCarousel]; i++) {
      CurrencyView *view = (CurrencyView *) [self.fromCarousel viewAtIndex:i];
      Currency *currency = self.presenter.availableCurrencies[i];
      NSString *amount = [self.presenter amountForCurrency:currency isFrom:YES];
      BOOL isValid = [self.presenter amountIsValidForCurrency:currency];
      [view configure:currency.code available:self.presenter.availableAmounts[i] rate:@"" amount: amount fromIsValid:isValid];
    }

    for (NSInteger i = 0; i < [self numberOfViewsInCarousel:self.toCarousel]; i++) {
      CurrencyView *view = (CurrencyView *) [self.toCarousel viewAtIndex:i];
      Currency *currency = self.presenter.availableCurrencies[i];
      NSString *amount = [self.presenter amountForCurrency:currency isFrom:NO];
      NSString *rate = [self.presenter toRateForCurrency:currency];
      [view configure:currency.code available:self.presenter.availableAmounts[i] rate:rate amount: amount fromIsValid:YES];
    }
  }
}

- (void) onTextChange: (NSString *) text inFrom: (BOOL) inFrom {
  if (inFrom) {
    [self.presenter updateFromAmount:text];
  } else {
    [self.presenter updateToAmount:text];
  }
}

#pragma mark - carousel datasource

- (NSInteger)numberOfViewsInCarousel:(CarouselView *)carouselView {
  return self.presenter.availableCurrencies.count;
}

- (UIView *)viewForCarousel:(CarouselView *)carouselView atIndex:(NSInteger)index {
  CurrencyView *view = [CurrencyView loadFromNib];
  __weak typeof(self) weakSelf = self;
  
  BOOL isFrom = carouselView == self.fromCarousel;
  Currency *currency = self.presenter.availableCurrencies[index];
  NSString *amount = [self.presenter amountForCurrency:currency isFrom:isFrom];
  BOOL isValid = isFrom ? [self.presenter amountIsValidForCurrency:currency] : YES;
  NSString *rate = isFrom ? @"" : [self.presenter toRateForCurrency:currency];
  [view configure:currency.code
        available:self.presenter.availableAmounts[index]
             rate:rate
           amount: amount
      fromIsValid: isValid
     onTextChange:^(NSString *newText) {
       [weakSelf onTextChange:newText inFrom:isFrom];
  }
   onBecomeFirstResponder:^{
     [weakSelf.presenter changeEditingFromAmount:isFrom];
   }
  ];
  return view;
}

- (void) didScrollToIndex:(NSInteger)index inCarousel:(CarouselView *)carouselView {
  
  if ((self.presenter.isEditingFromAmount && carouselView == self.fromCarousel)
    || (!self.presenter.isEditingFromAmount && carouselView == self.toCarousel)) {
    [[carouselView viewAtIndex:index] becomeFirstResponder];
  }
  
  UIPageControl *pageControl = self.fromCarousel == carouselView ? self.fromPageControl : self.toPageControl;
  pageControl.currentPage = index;
  
  if (self.fromCarousel == carouselView) {
    [self.presenter changeFromCurrency:self.presenter.availableCurrencies[index]];
  } else {
    [self.presenter changeToCurrency:self.presenter.availableCurrencies[index]];
  }
}

#pragma mark - keyboard handling

- (void) keyboardWillShow: (NSNotification *) notification {
  CGRect rect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
  UIViewAnimationOptions curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
  NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  
  self.bottomMargin.constant = rect.size.height;
  [UIView animateWithDuration:duration delay:0 options:curve animations:^{
    [self.view layoutIfNeeded];
  } completion:nil];
}

- (void) keyboardWillHide: (NSNotification *) notification {
  // do nothing, keyboard should be always on screen
}

@end
