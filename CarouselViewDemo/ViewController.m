//
//  ViewController.m
//  CarouselViewDemo
//
//  Created by John Wu on 4/26/12.
//  Copyright (c) 2012 TFM. All rights reserved.
//

#import "ViewController.h"

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]


@interface ViewController ()

@end

@implementation ViewController
@synthesize carousel = _carousel;
@synthesize rainbowColors = _rainbowColors;

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSArray *rainbowColors = [NSArray arrayWithObjects:
                              RGB(201, 31, 22),
                              RGB(202, 35, 22),
                              RGB(204, 42, 19),
                              RGB(208, 56, 21),
                              RGB(204, 54, 21),
                              RGB(210, 61, 22),
                              RGB(211, 72, 16),
                              RGB(212, 75, 13),
                              RGB(217, 88, 14),
                              RGB(217, 91, 15),
                              RGB(218, 95, 14),
                              RGB(219, 100, 13),
                              RGB(221, 104, 11),
                              RGB(220, 110, 13),
                              RGB(227, 117, 9),
                              RGB(231, 134, 11),
                              RGB(230, 134, 1),
                              RGB(237, 158, 10),
                              RGB(241, 166, 10),
                              RGB(241, 173, 6),
                              RGB(238, 173, 0),
                              RGB(247, 189, 0),
                              RGB(245, 182, 0),
                              RGB(249, 198, 15),
                              RGB(252, 207, 3),
                              RGB(251, 213, 10),
                              RGB(252, 229, 3),
                              RGB(246, 230, 10),
                              RGB(237, 228, 0),
                              RGB(230, 226, 9),
                              RGB(223, 220, 9),
                              RGB(216, 219, 9),
                              RGB(206, 213, 0),
                              RGB(197, 211, 0),
                              RGB(190, 210, 15),
                              RGB(181, 204, 10),
                              RGB(176, 197, 15),
                              RGB(165, 197, 15),
                              RGB(159, 196, 13),
                              RGB(152, 193, 0),
                              RGB(143, 187, 12),
                              RGB(146, 192, 14),
                              RGB(127, 181, 19),
                              RGB(128, 184, 18),
                              RGB(119, 179, 18),
                              RGB(113, 179, 14),
                              RGB(111, 178, 15),
                              RGB(105, 172, 18),
                              RGB(105, 176, 17),
                              RGB(85, 164, 28),
                              RGB(90, 170, 29),
                              RGB(78, 164, 29),
                              RGB(71, 164, 30),
                              RGB(58, 155, 32),
                              RGB(52, 155, 38),
                              RGB(51, 156, 30),
                              RGB(45, 156, 31),
                              RGB(43, 155, 34),
                              RGB(32, 148, 38),
                              RGB(27, 147, 36),
                              RGB(24, 148, 37),
                              RGB(3, 147, 49),
                              RGB(0, 140, 51),
                              RGB(9, 141, 58),
                              RGB(8, 131, 67),
                              RGB(12, 140, 75),
                              RGB(0, 132, 74),
                              RGB(4, 141, 92),
                              RGB(14, 140, 98),
                              RGB(8, 141, 108),
                              RGB(0, 140, 124),
                              RGB(8, 147, 148),
                              RGB(5, 148, 157),
                              RGB(11, 141, 148),
                              RGB(9, 148, 166),
                              RGB(0, 157, 190),
                              RGB(8, 148, 182),
                              RGB(13, 155, 196),
                              RGB(0, 157, 207),
                              RGB(21, 155, 212),
                              RGB(31, 154, 215),
                              RGB(20, 141, 198),
                              RGB(29, 147, 209),
                              RGB(20, 124, 181),
                              RGB(13, 132, 196),
                              RGB(12, 123, 187),
                              RGB(13, 115, 179),
                              RGB(16, 108, 172),
                              RGB(3, 99, 163),
                              RGB(19, 90, 158),
                              RGB(8, 82, 147),
                              RGB(10, 83, 151),
                              RGB(9, 74, 145),
                              RGB(13, 66, 132),
                              RGB(6, 67, 138),
                              RGB(13, 57, 129),
                              RGB(17, 50, 121),
                              RGB(18, 49, 121),
                              RGB(21, 44, 116),
                              RGB(24, 42, 113),
                              RGB(24, 35, 105),
                              RGB(27, 26, 95),
                              RGB(24, 28, 103),
                              RGB(29, 26, 98),
                              RGB(29, 18, 89),
                              RGB(30, 16, 89),
                              RGB(35, 14, 89),
                              RGB(48, 13, 90),
                              RGB(49, 12, 90),
                              RGB(58, 11, 89),
                              RGB(75, 10, 91),
                              RGB(81, 9, 90),
                              RGB(91, 11, 90),
                              RGB(115, 8, 97),
                              RGB(107, 1, 90),
                              RGB(124, 3, 98),
                              RGB(130, 0, 96),
                              RGB(139, 10, 98),
                              RGB(148, 11, 99),
                              RGB(164, 5, 99),
                              RGB(174, 9, 100),
                              RGB(194, 15, 104),
                              RGB(189, 0, 98),
                              RGB(196, 0, 99),
                              RGB(197, 0, 89),
                              RGB(198, 0, 75),
                              RGB(199, 5, 66),
                              RGB(198, 10, 57),
                              RGB(197, 10, 42),
                              RGB(197, 11, 33),
                              RGB(197, 18, 27),
                              RGB(196, 18, 26),
                              RGB(196, 35, 43),
                              RGB(195, 51, 43),
                              RGB(194, 69, 42),
                              nil];
    self.rainbowColors = rainbowColors;
    
    MSCarouselView *carousel = [[MSCarouselView alloc] initWithFrame:self.view.bounds];
    carousel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    carousel.delegate = self;
    carousel.dataSource = self;
    self.carousel = carousel;
    [self.view addSubview:self.carousel];
    [carousel release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.carousel = nil;
    // Release any retained subviews of the main view.
    
}

- (void) dealloc {
    self.carousel = nil;
    self.rainbowColors = nil;
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.carousel reloadData];
}

#pragma mark - MSCarousel

- (NSUInteger) numberOfViewsForCarouselView:(MSCarouselView *)carouselView {
    return self.rainbowColors.count;
}

- (UIView *) carouselView:(MSCarouselView *)carouselView viewForIndex:(NSUInteger)index {
    UIView *view = [carouselView dequeueReusableViewWithClass:[UIView class]];
    if (view == nil) {
        view = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
    }
    
    view.backgroundColor = [self.rainbowColors objectAtIndex:index];
    
    return view;
}

- (CGFloat) carouselView:(MSCarouselView *)carouselView widthForViewAtIndex:(NSUInteger)index {
    return floorf(self.view.bounds.size.width/16);
}

- (BOOL) carouselViewShouldWrap:(MSCarouselView *)carouselView {
    return YES;
}

- (void) carouselView:(MSCarouselView *)carouselView didTapViewAtIndex:(NSUInteger)index {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"alert" message:[NSString stringWithFormat:@"you tapped view %u", index] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
    [alert show];
    [alert release];
}

@end
