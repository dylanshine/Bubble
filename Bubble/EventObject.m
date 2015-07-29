//
//  EventObject.m
//  Bubble
//
//  Created by Val Osipenko on 7/29/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "EventObject.h"

@implementation EventObject


- (instancetype)initWithDictionary:(NSDictionary *)jsonDict{
    
    self = [super init];
    
    NSNumber *eventID = jsonDict[@"id"];
    NSString *eventTitle = jsonDict[@"title"];
    NSString *eventType = jsonDict[@"type"];
    NSDate *eventTime = jsonDict[@"datetime_local"];
    NSNumber *venueLat = jsonDict[@"venue"][@"location"][@"lat"];
    NSNumber *venueLon = jsonDict[@"venue"][@"location"][@"lon"];
    
    CLLocationCoordinate2D coordinate;
    
    coordinate.latitude = venueLat.floatValue;
    coordinate.longitude = venueLon.floatValue;
    
    if (self){
        _eventID = eventID;
        _eventTitle = eventTitle;
        _eventType = eventType;
        _eventTime = eventTime;
        _coordinate = coordinate;
    }
    
    return self;
}

@end
