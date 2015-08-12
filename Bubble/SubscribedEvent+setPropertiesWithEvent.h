//
//  SubscribedEvent+setPropertiesWithEvent.h
//  Bubble
//
//  Created by Lukas Thoms on 8/12/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "SubscribedEvent.h"

@class EventObject;

@interface SubscribedEvent (setPropertiesWithEvent)

-(void)setPropertiesWithEvent:(EventObject *)event;

@end
