//
//  BBDropDownItem.m
//  Bubble
//
//  Created by Dylan Shine on 8/11/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "BBDropDownItem.h"

@implementation BBDropDownItem

-(instancetype)initWithEvent:(SubscribedEvent *)event {
    if (self = [super init]) {
        _event = event;
        [self commonInit];
    }
    return self;
}

-(void)commonInit {
    [self setText:self.event.eventTitle];
}

@end
