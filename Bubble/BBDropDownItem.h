//
//  BBDropDownItem.h
//  Bubble
//
//  Created by Dylan Shine on 8/11/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "IGLDropDownItem.h"
#import "SubscribedEvent.h"

@interface BBDropDownItem : IGLDropDownItem
@property (strong, nonatomic) SubscribedEvent *event;
-(instancetype)initWithEvent:(SubscribedEvent *)event;
@end
