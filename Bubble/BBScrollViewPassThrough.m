//
//  BBScrollViewPassThrough.m
//  Bubble
//
//  Created by Jordan Guggenheim on 7/30/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "BBScrollViewPassThrough.h"

@implementation BBScrollViewPassThrough

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    
    for (UIView *view in self.subviews) {
        CGPoint relativePoint = [view convertPoint:point fromView:self];
        
        if ([view pointInside:relativePoint withEvent:event]) {
            return YES;
        }
    }
    return NO;
}

@end
