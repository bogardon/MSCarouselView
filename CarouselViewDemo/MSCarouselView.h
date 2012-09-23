//
//  MSCarouselView.h
//  Miso
//
//  Created by John Wu on 4/17/12.
//  Copyright (c) 2012 TFM. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSCarouselView;

@protocol MSCarouselViewDataSource <NSObject>

- (UIView *) carouselView:(MSCarouselView *)carouselView viewForIndex:(NSUInteger)index;
- (NSUInteger) numberOfViewsForCarouselView:(MSCarouselView *)carouselView;
- (CGFloat) carouselView:(MSCarouselView *)carouselView widthForViewAtIndex:(NSUInteger)index;

@optional
- (CGFloat) bufferInsetForCarouselView:(MSCarouselView *)carouselView;

@end

@protocol MSCarouselViewDelegate <NSObject, UIScrollViewDelegate>

@optional
- (BOOL) carouselViewShouldWrap:(MSCarouselView *)carouselView;
- (void) carouselView:(MSCarouselView *)carouselView didTapViewAtIndex:(NSUInteger)index;

@end

@interface MSCarouselView : UIScrollView {

}

- (void) reloadData;
- (UIView *) dequeueReusableViewWithClass:(Class)klass;
- (void) scrollToIndex:(NSUInteger)index animated:(BOOL)animated;
- (NSUInteger) indexOfViewAtPoint:(CGPoint)point;

@property (nonatomic, assign) id <MSCarouselViewDataSource> dataSource;
@property (nonatomic, assign) id <MSCarouselViewDelegate> delegate;

@end



