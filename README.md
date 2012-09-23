MSCarouselView
==============

A carousel that allows for different width, different views, and wrapping.

# CarouselViewDemo

A contrived demo of 135 strips of UIViews in a carousel, each representing a color in the rainbow spectrum.
Wrapping is enabled for maximum scrolling pleasure.

# How to Use

MSCarouselView is designed to be used like apple's UITableView.
Customization is accomplished by setting the delegate and dataSource.

There are 3 required dataSource methods

    - (NSUInteger) numberOfViewsForCarousel:(MSCarouselView *)carouselView;
    - (UIView *) carouselView:(MSCarouselView *)carouselView viewForIndex:(NSUInteger)index;
    - (CGFloat) carouselView:(MSCarouselView *)carouselView widthForViewAtIndex:(NSUInteger)index;
    
and one optional dataSource method that lets you control which the left/right insets that determine which views are to be rendered. (this is especially useful if you choose to have clipsToBounds set to NO)

    - (CGFloat) bufferInsetForCarouselView:(MSCarouselView *)carouselView;
    
and two optional delegate method (the delegate protocol extends UIScrollViewDelegate)

    - (BOOL) carouselViewShouldWrap:(MSCarouselView *)carouselView;
    - (void) carouselView:(MSCarouselView *)carouselView didTapViewAtIndex:(NSUInteger)index;

# License

MSCarouselView is available under the MIT License. See LICENSE for more info.
