//
//  EventObject.h
//  Bubble
//
//  Created by Val Osipenko on 7/29/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventObject : NSObject

@property (nonatomic, strong) NSString *eventID;
@property (nonatomic, strong) NSString *eventTitle;
@property (nonatomic, strong) NSString *eventType;
@property (nonatomic, strong) NSDate *eventTime;
@property (nonatomic, strong) NSString *venueLat;
@property (nonatomic, strong) NSString *venueLon;

-(instancetype)initWithEventID:(NSString*)eventID eventTitle:(NSString*)eventTitle eventType:(NSString*)eventType eventTime:(NSDate*)eventTime venueLat:(NSString*)venueLat venueLon:(NSString*)venueLon;

@end
