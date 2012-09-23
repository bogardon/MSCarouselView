//
//  MSCarouselView.m
//  Miso
//
//  Created by John Wu on 4/17/12.
//  Copyright (c) 2012 TFM. All rights reserved.
//

#import "MSCarouselView.h"

static inline NSNumber * KeyForIndex(NSUInteger index) {
    return [NSNumber numberWithInt:index];
}


@interface MSCarouselView ()

@property (nonatomic, retain) NSMutableDictionary *visibleViews;
@property (nonatomic, retain) NSMutableDictionary *reusableViews;
@property (nonatomic, assign) NSUInteger numberOfViews;
@property (nonatomic, assign) NSUInteger numberOfViewsNecessaryForWrap;
@property (nonatomic, assign) BOOL enableWrap;
@property (nonatomic, retain) NSMutableArray *rectsForViews;
@property (nonatomic, assign) CGFloat bufferInset;

- (void) _onTap:(UIGestureRecognizer *)recognizer;
- (void) _addOrRemoveViewsIfNecessary;
- (void) _enqueueView:(UIView *)view;
- (void) _enqueueViewsInArray:(NSArray *)views;
- (NSUInteger) _clampedIndex:(NSUInteger)index;

@end

@implementation MSCarouselView
@synthesize dataSource = _dataSource;
@synthesize visibleViews = _visibleViews;
@synthesize reusableViews = _reusableViews;
@synthesize numberOfViews = _numberOfViews;
@synthesize enableWrap = _enableWrap;
@synthesize rectsForViews = _rectsForViews;
@synthesize numberOfViewsNecessaryForWrap = _numberOfViewsNecessaryForWrap;
@synthesize bufferInset = _bufferInset;
@dynamic delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.reusableViews = [NSMutableDictionary dictionary];
        self.visibleViews = [NSMutableDictionary dictionary];
        self.rectsForViews = [NSMutableArray array];
    }
    return self;
}

- (void) dealloc {
    self.rectsForViews = nil;
    self.visibleViews = nil;
    self.reusableViews = nil;
    [super dealloc];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.enableWrap) {
        if (self.contentOffset.x < 0) {
            CGRect rect = [[self.rectsForViews objectAtIndex:self.rectsForViews.count - 2 * self.numberOfViewsNecessaryForWrap] CGRectValue];
            self.contentOffset = CGPointMake(CGRectGetMinX(rect) + self.contentOffset.x, self.contentOffset.y);
        } else if (self.contentOffset.x + self.frame.size.width  > self.contentSize.width) {
            CGRect rect = [[self.rectsForViews objectAtIndex:2*self.numberOfViewsNecessaryForWrap-1] CGRectValue];
            self.contentOffset = CGPointMake(CGRectGetMaxX(rect) - (self.contentSize.width - self.contentOffset.x), self.contentOffset.y);
        }
    }

    [self _addOrRemoveViewsIfNecessary];
}

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return [super pointInside:point withEvent:event] || CGRectContainsPoint(CGRectInset(self.bounds, self.bufferInset, self.bufferInset), point);
}

#pragma mark - Public

- (void) setDataSource:(id<MSCarouselViewDataSource>)dataSource {
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        if (self.delegate && self.dataSource) {
            [self performSelector:@selector(reloadData) withObject:nil afterDelay:0];
        }
    }
}

- (void) setDelegate:(id<MSCarouselViewDelegate>)delegate {
    [super setDelegate:delegate];
    if (self.dataSource && self.delegate) {
        [self performSelector:@selector(reloadData) withObject:nil afterDelay:0];
    }
}

- (void) reloadData {

    [self _enqueueViewsInArray:self.visibleViews.allValues];

    [self.visibleViews removeAllObjects];

    [self.rectsForViews removeAllObjects];

    self.numberOfViews = [self.dataSource numberOfViewsForCarouselView:self];

    if (self.numberOfViews == 0) {
        return;
    }

    if ([self.delegate respondsToSelector:@selector(carouselViewShouldWrap:)] && self.numberOfViews > 1) {
        self.enableWrap = [self.delegate carouselViewShouldWrap:self];
    }

    self.numberOfViewsNecessaryForWrap = 0;

    if (self.enableWrap) {
        NSUInteger numberOfViewsNecessaryForWrap = 0;
        CGFloat halfWidth = 0;
        for (int i = 0; i < self.numberOfViews; ++i) {
            numberOfViewsNecessaryForWrap++;
            halfWidth += [self.dataSource carouselView:self widthForViewAtIndex:i];
            if (halfWidth >= floorf(self.frame.size.width/2)) {
                break;
            }
        }
        self.numberOfViewsNecessaryForWrap = numberOfViewsNecessaryForWrap;
    }

    CGFloat contentSizeWidth = 0;
    for (NSUInteger i = 0; i < self.numberOfViews + 2*self.numberOfViewsNecessaryForWrap; ++i) {
        NSUInteger askIndex = [self _clampedIndex:i];
        CGFloat width = [self.dataSource carouselView:self widthForViewAtIndex:askIndex];
        CGRect rect = CGRectMake(contentSizeWidth, 0, width, self.frame.size.height);
        [self.rectsForViews addObject:[NSValue valueWithCGRect:rect]];
        contentSizeWidth += width;
    }

    self.contentSize = CGSizeMake(contentSizeWidth, self.frame.size.height);
    if (self.enableWrap && self.contentOffset.x == 0) {
        CGRect rect = [[self.rectsForViews objectAtIndex:self.numberOfViewsNecessaryForWrap] CGRectValue];
        self.contentOffset = CGPointMake(CGRectGetMinX(rect), self.contentOffset.y);
    }

    self.bufferInset = [self.dataSource respondsToSelector:@selector(bufferInsetForCarouselView:)] ? [self.dataSource bufferInsetForCarouselView:self] : 0;
    [self _addOrRemoveViewsIfNecessary];
}

- (UIView *) dequeueReusableViewWithClass:(Class)klass {
    NSString *classKey = NSStringFromClass(klass);
    NSMutableSet *set = [self.reusableViews objectForKey:classKey];
    UIView *view = [[set anyObject] retain];
    if (view) {
        [set removeObject:view];
    }
    return [view autorelease];
}

- (NSUInteger) indexOfViewAtPoint:(CGPoint)point {
    __block NSUInteger index = NSUIntegerMax;
    [self.rectsForViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGRect rect = [obj CGRectValue];
        if (CGRectContainsPoint(rect, point)) {
            index = [self _clampedIndex:idx];
            *stop = YES;
        }
    }];
    return index;
}

- (void) scrollToIndex:(NSUInteger)index animated:(BOOL)animated {
    if (self.rectsForViews.count) {
        CGRect scrollRect = [[self.rectsForViews objectAtIndex:self.enableWrap? self.numberOfViewsNecessaryForWrap + index : index] CGRectValue];
        [self scrollRectToVisible:scrollRect animated:animated];
    }
}

#pragma mark - Private Methods

- (void) _onTap:(UIGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded && [self.delegate respondsToSelector:@selector(carouselView:didTapViewAtIndex:)]) {
        [self.delegate carouselView:self didTapViewAtIndex:recognizer.view.tag];
    }
}

- (NSUInteger) _clampedIndex:(NSUInteger)index {
    return self.enableWrap ? (index-self.numberOfViewsNecessaryForWrap+self.numberOfViews)%self.numberOfViews : index;
}

- (void) _enqueueView:(UIView *)view {
    [view removeFromSuperview];
    NSString *classKey = NSStringFromClass([view class]);
    NSMutableSet *set = [self.reusableViews objectForKey:classKey];

    if (set == nil && classKey) {
        set = [NSMutableSet set];
        [self.reusableViews setObject:set forKey:classKey];
    }

    if (view) {
        [set addObject:view];
    }
}

- (void) _enqueueViewsInArray:(NSArray *)views {
    [views enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self _enqueueView:obj];
    }];
}

- (void) _addOrRemoveViewsIfNecessary {



    CGRect bufferRect = CGRectInset(self.bounds, self.bufferInset, self.bufferInset);

    NSMutableArray *keysToRemove = [NSMutableArray array];
    NSMutableArray *viewsToRemove = [NSMutableArray array];
    [self.visibleViews enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        UIView *view = (UIView *)obj;
        if (CGRectIntersectsRect(bufferRect, view.frame) == NO) {
            [keysToRemove addObject:key];
            [viewsToRemove addObject:obj];
        }
    }];
    [self _enqueueViewsInArray:viewsToRemove];
    [self.visibleViews removeObjectsForKeys:keysToRemove];

    [self.rectsForViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

        CGRect rect = [obj CGRectValue];
        if (CGRectIntersectsRect(bufferRect, rect) == NO) {
            return;
        } else {
            NSUInteger askIndex = [self _clampedIndex:idx];
            if ([self.visibleViews objectForKey:KeyForIndex(idx)] == nil) {
                UIView *view = [self.dataSource carouselView:self viewForIndex:askIndex];
                if (view) {
                    view.frame = rect;
                    view.tag = askIndex;
                    [self insertSubview:view atIndex:0];
                    [self.visibleViews setObject:view forKey:KeyForIndex(idx)];

                    if (view.gestureRecognizers.count == 0 && [self.delegate respondsToSelector:@selector(carouselView:didTapViewAtIndex:)]) {
                        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_onTap:)];
                        [view addGestureRecognizer:tap];
                        [tap release];
                    }
                }
            }
        }
    }];
}

@end
