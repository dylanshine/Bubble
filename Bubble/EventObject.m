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
    NSString *eventTime = jsonDict[@"datetime_local"];
    NSNumber *venueLat = jsonDict[@"venue"][@"location"][@"lat"];
    NSNumber *venueLon = jsonDict[@"venue"][@"location"][@"lon"];
    NSString *venueName = jsonDict[@"venue"][@"name"];
    NSString *addressStreet = jsonDict[@"venue"][@"address"];
    NSString *addressCity = jsonDict[@"venue"][@"city"];
    NSString *addressState = jsonDict[@"venue"][@"state"];
    NSNumber *addressZip = jsonDict[@"venue"][@"postal_code"];
    
    NSMutableArray *eventPerformers = [[NSMutableArray alloc]init];;
    for(NSDictionary* performer in jsonDict[@"performers"]){
        [eventPerformers addObject:performer[@"name"]];
    }
    CLLocationCoordinate2D coordinate;
    
    coordinate.latitude = venueLat.floatValue;
    coordinate.longitude = venueLon.floatValue;
    
    if (self){
        _eventID = eventID;
        _eventTitle = eventTitle;
        _eventType = eventType;
        _eventTime = eventTime;
        _coordinate = coordinate;
        _venueName = venueName;
        _eventPerformers = eventPerformers;
        _addressStreet = addressStreet;
        _addressCity = addressCity;
        _addressState = addressState;
        _addressZip = addressZip;
    }
    
    return self;
}

@end
