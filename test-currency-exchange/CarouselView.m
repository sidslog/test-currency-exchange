//
//  CarouselView.m
//  test-currency-exchange
//
//  Created by Sergey Sedov on 5/22/17.
//  Copyright © 2017 Test. All rights reserved.
//

#import "CarouselView.h"

@interface CarouselView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) NSInteger numberOfViews;

@property (nonatomic, strong) NSMutableArray* constraints;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIView *>* viewsCache;

@end

@implementation CarouselView

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder:coder];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (void) commonInit {
  self.viewsCache = [@{} mutableCopy];
  self.constraints = [@[] mutableCopy];
  
  self.selectedIndex = 0;
  self.numberOfViews = 0;
  
  self.scrollView = [[UIScrollView alloc] init];
  self.scrollView.pagingEnabled = YES;
  self.scrollView.showsHorizontalScrollIndicator = NO;
  self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
  
  [self addSubview:self.scrollView];
  
  [self addConstraints:@[
                         [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
                         [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],
                         [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeTop multiplier:1 constant:0],
                         [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
                         ]];
  
  self.contentView = [[UIView alloc] init];
  self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
  [self.scrollView addSubview:self.contentView];
  [self.scrollView addConstraints:@[
                         [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
                         [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],
                         [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0],
                         [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
                         ]];

  self.scrollView.delegate = self;
  [self reloadData];
}

- (void) reloadData {
  
  NSInteger numberOfViews = 0;
  if (self.datasource && [self.datasource respondsToSelector:@selector(numberOfViewsInCarousel:)]) {
    numberOfViews = [self.datasource numberOfViewsInCarousel:self];
  }
  
  self.numberOfViews = numberOfViews;
  
  [self loadInitialViews];
}

- (UIView *) viewAtIndex: (NSInteger) index {
  return [self loadViewAtIndex:index];
}

- (UIView *) nextView {
  NSInteger newIndex = self.selectedIndex + 1;
  if (newIndex > self.numberOfViews - 1) {
    newIndex = 0;
  }
  
  UIView *view = [self loadViewAtIndex:newIndex];
  return view;
}

- (UIView *) prevView {
  NSInteger newIndex = self.selectedIndex - 1;
  if (newIndex < 0) {
    newIndex = self.numberOfViews - 1;
  }
  
  UIView *view = [self loadViewAtIndex:newIndex];
  return view;
}

- (UIView *) loadViewAtIndex: (NSInteger) index {
  if (self.viewsCache[@(index)] != nil) {
    return self.viewsCache[@(index)];
  }
  
  if (self.datasource && [self.datasource respondsToSelector:@selector(viewForCarousel:atIndex:)]) {
    UIView *view = [self.datasource viewForCarousel:self atIndex:index];
    self.viewsCache[@(index)] = view;
    return view;
  }
  return nil;
}

- (void) loadInitialViews {
  
  [self.scrollView removeConstraints:self.constraints];
  [self.constraints removeAllObjects];
  
  for (UIView *view in self.contentView.subviews) {
    [view removeFromSuperview];
  }
  
  if (self.numberOfViews < 3) {
    return;
  }
  
  UIView *prevView = nil;
  
  NSArray *subviews = @[[self prevView], [self loadViewAtIndex:self.selectedIndex], [self nextView]];
  
  for (UIView *view in subviews) {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:view];
    
    [self.constraints addObjectsFromArray:@[
                                            [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1 constant:0],
                                            [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
                                            [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeHeight multiplier:1 constant:0],
                                            [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeWidth multiplier:1 constant:0],
                                            ]
     ];
    
    if (prevView == nil) {
      [self.constraints addObject:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    } else {
      [self.constraints addObject:[NSLayoutConstraint constraintWithItem:prevView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    }
    
    if (view == subviews.lastObject) {
      NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeRight multiplier:1 constant:0];
      [self.constraints addObject:constraint];
    }
    
    prevView = view;
  }
  [self.scrollView addConstraints:self.constraints];
  [self.scrollView layoutIfNeeded];
  [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width, 0) animated:NO];
  
  if (self.datasource && [self.datasource respondsToSelector:@selector(didScrollToIndex:inCarousel:)]) {
    [self.datasource didScrollToIndex:self.selectedIndex inCarousel:self];
  }
}

#pragma mark - scroll view delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  if (scrollView.contentOffset.x == 0) {
    self.selectedIndex = self.selectedIndex - 1;
    if (self.selectedIndex < 0) {
      self.selectedIndex = self.numberOfViews - 1;
    }
    [self loadInitialViews];
  } else if (scrollView.contentOffset.x == self.scrollView.bounds.size.width * 2) {
    self.selectedIndex = self.selectedIndex + 1;
    if (self.selectedIndex > self.numberOfViews - 1) {
      self.selectedIndex = 0;
    }
    [self loadInitialViews];
  }
  
  
}

@end
