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
    
    NSString *eventID = [jsonDict[@"id"] stringValue];
    NSString *eventType = jsonDict[@"type"];
    
    NSString *eventTime = jsonDict[@"datetime_local"];
    eventTime = [eventTime substringWithRange:NSMakeRange(11, eventTime.length-11)];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm:ss"];
    
    NSDate *eventTimeAsDate = [[NSDate alloc] init];
    eventTimeAsDate = [dateFormat dateFromString:eventTime];

    [dateFormat setDateFormat:@"h:mm a"];
    eventTime = [dateFormat stringFromDate:eventTimeAsDate];
    
    if ([eventTime isEqualToString:@"3:30 AM"]) {
        eventTime = @"TBD";
    }

    NSNumber *listingCountNumber = jsonDict[@"stats"][@"listing_count"];
    NSString *listingCountString = @"No Tickets Available";
    NSString *ticketAvgPrice = @"";
    NSString *ticketHighPrice = @"";
    NSString *ticketLowestPrice = @"";

    if (![jsonDict[@"stats"][@"listing_count"] isKindOfClass:[NSNull class]] && ![listingCountNumber isEqual: @0]) {
        listingCountString = [NSString stringWithFormat:@"Tickets Available: %@",listingCountNumber];
        ticketAvgPrice = [NSString stringWithFormat:@"Average: $%@",jsonDict[@"stats"][@"average_price"]];
        ticketHighPrice = [NSString stringWithFormat:@"High: $%@",jsonDict[@"stats"][@"highest_price"]];;
        ticketLowestPrice = [NSString stringWithFormat:@"Low: $%@",jsonDict[@"stats"][@"lowest_price"]];;
    }
    
    NSNumber *venueLat = jsonDict[@"venue"][@"location"][@"lat"];
    NSNumber *venueLon = jsonDict[@"venue"][@"location"][@"lon"];
    NSString *venueName = jsonDict[@"venue"][@"name"];
    NSString *addressStreet = jsonDict[@"venue"][@"address"];
    NSString *addressCity = jsonDict[@"venue"][@"city"];
    NSString *addressState = jsonDict[@"venue"][@"state"];
    NSNumber *addressZip = jsonDict[@"venue"][@"postal_code"];
    
    // Occassionally the Street is missing from SeatGeek API
    if ([addressStreet isKindOfClass:[NSNull class]]) {
        addressStreet = @"";
        NSLog(@"Null address for event %@",eventTitle);
    }
    
    NSString *ticketURL = jsonDict[@"url"];
    NSString *eventImageURL = jsonDict[@"performers"][0][@"image"];
    
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
        _ticketsAvailable = listingCountString;
        _ticketPriceAvg = ticketAvgPrice;
        _ticketPriceHigh = ticketHighPrice;
        _ticketPriceLow = ticketLowestPrice;
        _eventImageURL = eventImageURL;
        _eventScore = eventScore;
        _venueScore = venueScore;
        _eventLocation = eventLocation;
    }
    
    return self;
}

- (instancetype)initWithMeetupDictionary:(NSDictionary *)jsonDict{
    
    self = [super init];
    
    NSString *eventTitle = jsonDict[@"name"];
    NSString *eventID = jsonDict[@"id"];
    NSString *eventType = @"meetup";
    NSNumber *venueLat = jsonDict[@"venue"][@"lat"];
    NSNumber *venueLon = jsonDict[@"venue"][@"lon"];
    NSString *venueName = jsonDict[@"venue"][@"name"];
    NSString *addressStreet = jsonDict[@"venue"][@"address_1"];
    NSString *addressCity = jsonDict[@"venue"][@"city"];
    NSString *addressState = jsonDict[@"venue"][@"state"];
    NSNumber *addressZip = jsonDict[@"venue"][@"zip"];
    NSString *ticketURL = jsonDict[@"event_url"];
    NSString *eventImageURL = jsonDict[@"group"][@"urlname"];
   
    UIImage *eventImage = [UIImage imageNamed:@"MeetupCover"];
    
    NSString *ticketPrice = @"Ticket Price: Free";
    NSString *rsvpYes = @"No Attendees";
    NSString *rsvpMaybe = @"No Attendees";

    if (jsonDict[@"fee"][@"amount"] != nil) {
        CGFloat floatPrice = ((NSNumber *)jsonDict[@"fee"][@"amount"]).floatValue;
        ticketPrice = [NSString stringWithFormat:@"$%.f",floatPrice];
    }
    
    NSNumber *eventTimeNumber = jsonDict[@"time"];
    NSDate *eventTime = [NSDate dateWithTimeIntervalSince1970:eventTimeNumber.doubleValue/1000];

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"h:mm a"];
    
    NSString *startTime = [dateFormat stringFromDate:eventTime];
    
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
        _eventTime = startTime;
        _coordinate = coordinate;
        _venueName = venueName;
        _eventPerformers = eventPerformers;
        _addressStreet = addressStreet;
        _addressCity = addressCity;
        _addressState = addressState;
        _addressZip = addressZip;
        _ticketURL = ticketURL;
        _ticketsAvailable = @"";
        _ticketPriceAvg = @"";
        _ticketPriceHigh = @"";
        _ticketPriceLow = @"";
        _eventImageURL = eventImageURL;
        _eventScore = eventScore;
        _eventLocation = eventLocation;
        _eventImage = eventImage;
    }
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
