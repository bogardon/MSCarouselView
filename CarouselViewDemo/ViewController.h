//
//  ViewController.h
//  CarouselViewDemo
//
//  Created by John Wu on 4/26/12.
//  Copyright (c) 2012 TFM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSCarouselView.h"

@interface ViewController : UIViewController <MSCarouselViewDelegate, MSCarouselViewDataSource> {
    
}

@property (nonatomic, retain) MSCarouselView *carousel;
@property (nonatomic, retain) NSArray *rainbowColors;

@end
