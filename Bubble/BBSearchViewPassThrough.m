//
//  BBSearchView.m
//  Bubble
//
//  Created by Lukas Thoms on 8/5/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "BBSearchViewPassThrough.h"

@implementation BBSearchViewPassThrough

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView* subview in self.subviews ) {
        if ( [subview hitTest:[self convertPoint:point toView:subview] withEvent:event] != nil ) {
            return YES;
        }
    }
    return NO;
}


@end
