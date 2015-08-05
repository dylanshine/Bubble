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


- (instancetype)initWithSeatgeekDictionary:(NSDictionary *)jsonDict{
    
    self = [super init];
    
    NSString *title = jsonDict[@"title"];
    NSString *eventTitle = @"";
    
    if ([title containsString:@" - "]) {
        eventTitle = jsonDict[@"performers"][0][@"name"];
    } else {
        eventTitle = jsonDict[@"title"];
    }
    
    NSString *eventID = jsonDict[@"id"];
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
    NSString *eventImageURL = jsonDict[@"performers"][0][@"image"];
    NSNumber * eventPrice = jsonDict[@"stats"][@"average_price"];
    
    // Set placeholder image.  Make dynamic for event types
    if ([eventImageURL isKindOfClass:[NSNull class]]) {
    eventImageURL = @"https://placekitten.com/g/414/310";
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
        _eventImageURL = eventImageURL;
        _eventScore = eventScore;
        _venueScore = venueScore;
        _eventLocation = eventLocation;
        _eventPrice = eventPrice;
    }
    
    return self;
}

- (instancetype)initWithMeetupDictionary:(NSDictionary *)jsonDict{
    
    self = [super init];
    
    NSString *eventTitle = jsonDict[@"name"];
    NSString *eventID = jsonDict[@"id"];
    NSString *eventType = @"meetup";
    NSString *eventTime = jsonDict[@"time"];
    NSNumber *venueLat = jsonDict[@"venue"][@"lat"];
    NSNumber *venueLon = jsonDict[@"venue"][@"lon"];
    NSString *venueName = jsonDict[@"venue"][@"name"];
    NSString *addressStreet = jsonDict[@"venue"][@"address_1"];
    NSString *addressCity = jsonDict[@"venue"][@"city"];
    NSString *addressState = jsonDict[@"venue"][@"state"];
    NSNumber *addressZip = jsonDict[@"venue"][@"zip"];
    NSURL *ticketURL = jsonDict[@"event_url"];
    NSString *eventImageURL = jsonDict[@"group"][@"urlname"];
    NSNumber * eventPrice = jsonDict[@"fee"][@"amount"];

    
    // Set placeholder image.  Make dynamic for event types
    if ([eventImageURL isKindOfClass:[NSNull class]]) {
        eventImageURL = @"https://placekitten.com/g/414/310";
    }
    
    NSNumber *eventScore = jsonDict[@"yes_rsvp_count"];
    
    NSMutableArray *eventPerformers = [[NSMutableArray alloc]init];;
    [eventPerformers addObject:jsonDict[@"group"][@"name"]];
    
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
        _eventImageURL = eventImageURL;
        _eventScore = eventScore;
        _eventLocation = eventLocation;
        _eventPrice = eventPrice;
    }
    NSLog(@"%@",eventImageURL);
    return self;
}



- (void) fetchEventImage {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    manager.responseSerializer = [AFImageResponseSerializer serializer];
    
    [manager GET:self.eventImageURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             self.eventImage = responseObject;             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"%@",error.description);
         }];
}


@end
