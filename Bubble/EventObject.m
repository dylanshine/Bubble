//
//  EventObject.m
//  Bubble
//
//  Created by Val Osipenko on 7/29/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "EventObject.h"

@implementation EventObject


-(instancetype)initWithEventID:(NSString *)eventID eventTitle:(NSString *)eventTitle eventType:(NSString *)eventType eventTime:(NSDate *)eventTime venueLat:(NSString *)venueLat venueLon:(NSString *)venueLon{
    
    self = [super init];
    if (self){
        _eventID = eventID;
        _eventTitle = eventTitle;
        _eventType = eventType;
        _eventTime = eventTime;
        _venueLat = venueLat;
        _venueLon = venueLon;
    }
    
    return self;
}




@end
