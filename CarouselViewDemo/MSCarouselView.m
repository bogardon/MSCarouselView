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

- (void) _addOrRemoveViewsIfNecessary;
- (void) _enqueueView:(UIView *)view;
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
            CGRect rect = CGRectFromString([self.rectsForViews objectAtIndex:self.rectsForViews.count - 2 * self.numberOfViewsNecessaryForWrap]);
            self.contentOffset = CGPointMake(CGRectGetMinX(rect) + self.contentOffset.x, self.contentOffset.y);
        } else if (self.contentOffset.x + self.frame.size.width  > self.contentSize.width) {
            CGRect rect = CGRectFromString([self.rectsForViews objectAtIndex:2*self.numberOfViewsNecessaryForWrap-1]);
            self.contentOffset = CGPointMake(CGRectGetMaxX(rect) - (self.contentSize.width - self.contentOffset.x), self.contentOffset.y);
        }
    }
    
    [self _addOrRemoveViewsIfNecessary];
}

- (void) setDataSource:(id<MSCarouselViewDataSource>)dataSource {
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        [self performSelector:selector(reloadData) withObject:nil afterDelay:0];
    }
}

- (void) reloadData {

    [self.visibleViews enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self _enqueueView:obj];
    }];
    
    [self.visibleViews.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
    [self.visibleViews removeAllObjects];
    
    [self.rectsForViews removeAllObjects];
    
    self.numberOfViews = [self.dataSource numberOfViewsForCarousel:self];
    
    if (self.numberOfViews == 0) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(carouselViewShouldWrap:)]) {
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
        [self.rectsForViews addObject:NSStringFromCGRect(rect)];
        contentSizeWidth += width;
    }
    
    self.contentSize = CGSizeMake(contentSizeWidth, self.frame.size.height);
    if (self.enableWrap && self.contentOffset.x == 0) {
        CGRect rect = CGRectFromString([self.rectsForViews objectAtIndex:self.numberOfViewsNecessaryForWrap]);
        self.contentOffset = CGPointMake(CGRectGetMinX(rect), self.contentOffset.y);
    }
    
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

#pragma mark - Private Methods

- (NSUInteger) _clampedIndex:(NSUInteger)index {
    return self.enableWrap ? (index-self.numberOfViewsNecessaryForWrap+self.numberOfViews)%self.numberOfViews : index;
}

- (void) _enqueueView:(UIView *)view {
    NSString *classKey = NSStringFromClass([view class]);
    NSMutableSet *set = [self.reusableViews objectForKey:classKey];
    if (set == nil) {
        set = [NSMutableSet set];
        [self.reusableViews setObject:set forKey:classKey];
    }
    [set addObject:view];

}

- (void) _addOrRemoveViewsIfNecessary {
    NSMutableArray *keysToRemove = [NSMutableArray array];
    NSMutableArray *viewsToRemove = [NSMutableArray array];
    [self.visibleViews enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        UIView *view = (UIView *)obj;
        if (CGRectIntersectsRect(self.bounds, view.frame) == NO) {
            [keysToRemove addObject:key];
            [viewsToRemove addObject:obj];
            [self _enqueueView:view];
        }
        
    }];
    [viewsToRemove makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.visibleViews removeObjectsForKeys:keysToRemove];
    
    [self.rectsForViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGRect rect = CGRectFromString(obj);
        NSUInteger askIndex = [self _clampedIndex:idx];
        if (CGRectIntersectsRect(self.bounds, rect) == YES && [self.visibleViews objectForKey:KeyForIndex(askIndex)] == nil) {
            UIView *view = [self.dataSource carouselView:self viewForIndex:askIndex];
            if (view) {
                view.frame = rect;
                [self insertSubview:view atIndex:0];
                [self.visibleViews setObject:view forKey:KeyForIndex(askIndex)];
            }
        }
    }];
}

@end
