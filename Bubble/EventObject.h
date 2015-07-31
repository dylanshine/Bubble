//
//  EventObject.h
//  Bubble
//
//  Created by Val Osipenko on 7/29/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

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

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

- (instancetype) initWithDictionary:(NSDictionary *)jsonDict;

- (NSString*) stripEventTitleText:(NSString*)title;

@end
