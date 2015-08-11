//
//  EventObject.h
//  Bubble
//
//  Created by Val Osipenko on 7/29/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <AFNetworking/AFNetworking.h>

@interface EventObject : NSObject

@property (nonatomic, strong) NSString *eventID;
@property (nonatomic, strong) NSString *eventTitle;
@property (nonatomic, strong) NSString *eventType;
@property (nonatomic, strong) NSString *eventTime;
@property (nonatomic, strong) NSString *venueName;
@property (nonatomic, strong) NSMutableArray *eventPerformers;
@property (nonatomic, strong) NSString *addressStreet;
@property (nonatomic, strong) NSString *addressCity;
@property (nonatomic, strong) NSString *addressState;
@property (nonatomic, strong) NSNumber *addressZip;
@property (nonatomic, strong) NSString *ticketURL;
@property (nonatomic, strong) NSString *ticketsAvailable;
@property (nonatomic, strong) NSString *ticketPriceAvg;
@property (nonatomic, strong) NSString *ticketPriceHigh;
@property (nonatomic, strong) NSString *ticketPriceLow;
@property (nonatomic, strong) NSNumber *eventScore;
@property (nonatomic, strong) NSNumber *venueScore;
@property (nonatomic, strong) NSString *eventImageURL;
@property (nonatomic, strong) UIImage *eventImage;


@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) CLLocation *eventLocation;

- (instancetype) initWithSeatgeekDictionary:(NSDictionary *)jsonDict;
- (instancetype) initWithMeetupDictionary:(NSDictionary *)jsonDict;

- (void) fetchEventImage;

@end
