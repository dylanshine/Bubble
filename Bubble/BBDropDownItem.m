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
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/d";
    NSString *eventTitle = [NSString stringWithFormat:@"  %@ %@", [formatter stringFromDate:self.event.date], self.event.eventTitle];
    [self setText:eventTitle];
}

@end
