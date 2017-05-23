//
//  CarouselView.h
//  test-currency-exchange
//
//  Created by Sergey Sedov on 5/22/17.
//  Copyright © 2017 Test. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CarouselView;

@protocol CarouselViewDatasource <NSObject>

/// View if items in carousel
- (NSInteger) numberOfViewsInCarousel: (CarouselView *) carouselView;

/// View for index
- (UIView *) viewForCarousel: (CarouselView *) carouselView atIndex: (NSInteger) index;

/// Is called when scroll view stops decelerating
- (void) didScrollToIndex: (NSInteger) index inCarousel: (CarouselView *) carouselView;

@end

/// Control that displays carousel view. Current implementation supports only 3 or more items in the carousel.
@interface CarouselView : UIView

/**
 Datasource should return the number of items in carousel and load the views when caruself asks for it
 Views are cached inside the carousel, so the the datasource shouldn't cache them.
 */
@property (nonatomic, weak) id<CarouselViewDatasource> datasource;

/// Return view for specified index
- (UIView *) viewAtIndex: (NSInteger) index;

/// Reloads the carousel
- (void) reloadData;

@end
