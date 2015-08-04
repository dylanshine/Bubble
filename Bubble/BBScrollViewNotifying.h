//
//  BBScrollViewNotifying.h
//  Bubble
//
//  Created by Jordan Guggenheim on 8/4/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol BBScrollViewNotifying <NSObject>

- (void) scrollViewDidMove:(UIScrollView *)scrollView;

@end