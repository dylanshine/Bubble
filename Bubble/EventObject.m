//
//  EventObject.m
//  Bubble
//
//  Created by Val Osipenko on 7/29/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "EventObject.h"

@interface EventObject()

@property (nonatomic, strong) NSDictionary *eventDictionary;

@end

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
    NSURL *ticketURL = jsonDict[@"url"];
    NSString *imageString = jsonDict[@"performers"][0][@"image"];
    
    // Set placeholder image.  Make dynamic for event types
    if ([imageString isKindOfClass:[NSNull class]]) {
    imageString = @"https://placekitten.com/g/280/210";
    }
    
    NSNumber *eventScore = jsonDict[@"score"];
    NSNumber *venueScore = jsonDict[@"venue"][@"score"];
    
    NSMutableArray *eventPerformers = [[NSMutableArray alloc]init];;
    for(NSDictionary* performer in jsonDict[@"performers"]){
        [eventPerformers addObject:performer[@"name"]];
    }
    CLLocationCoordinate2D coordinate;
    
    coordinate.latitude = venueLat.floatValue;
    coordinate.longitude = venueLon.floatValue;
    
    CLLocation *eventLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
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
        _ticketURL = ticketURL;
        _eventScore = eventScore;
        _venueScore = venueScore;
        _eventLocation = eventLocation;

        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.responseSerializer = [AFImageResponseSerializer serializer];
        
        [manager GET:imageString
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 _eventImage = [UIImage imageWithData:operation.responseData];
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 NSLog(@"%@",error.description);
             }];
    }
    
    return self;
}

@end
