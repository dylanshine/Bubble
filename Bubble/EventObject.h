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

@property (nonatomic, strong) NSNumber *eventID;
@property (nonatomic, strong) NSString *eventTitle;
@property (nonatomic, strong) NSString *eventType;
@property (nonatomic, strong) NSString *eventTime;
@property (nonatomic, strong) NSString *venueName;
@property (nonatomic, strong) NSMutableArray *eventPerformers;
@property (nonatomic, strong) NSString *addressStreet;
@property (nonatomic, strong) NSString *addressCity;
@property (nonatomic, strong) NSString *addressState;
@property (nonatomic, strong) NSNumber *addressZip;
@property (nonatomic, strong) NSURL *ticketURL;
@property (nonatomic, strong) NSNumber *eventScore;
@property (nonatomic, strong) NSNumber *venueScore;
//@property (nonatomic, strong, readonly) UIImage *eventPhoto;
@property (nonatomic, strong) UIImage *eventImage;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

- (instancetype) initWithDictionary:(NSDictionary *)jsonDict;


@end
