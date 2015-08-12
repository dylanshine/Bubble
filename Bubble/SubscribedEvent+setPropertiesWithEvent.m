//
//  SubscribedEvent+setPropertiesWithEvent.m
//  Bubble
//
//  Created by Lukas Thoms on 8/12/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "SubscribedEvent+setPropertiesWithEvent.h"
#import "EventObject.h"

@implementation SubscribedEvent (setPropertiesWithEvent)

-(void)setPropertiesWithEvent:(EventObject *)event {
    self.eventID = event.eventID;
    self.eventTitle = event.eventTitle;
    self.eventType = event.eventType;
    self.eventTime = event.eventTime;
    self.venueName = event.venueName;
    self.addressCity = event.addressCity;
    self.addressState = event.addressState;
    self.addressZip = @([event.addressZip integerValue]);
    self.addressStreet = event.addressStreet;
    self.ticketURL = event.ticketURL;
    if ([event.eventScore isKindOfClass:[NSNumber class]]) {
        self.eventScore = event.eventScore;
    }
    if ([event.venueScore isKindOfClass:[NSNumber class]]) {
        self.venueScore = event.venueScore;
    }
    if ([event.eventImage isKindOfClass:[UIImage class]]) {
        self.eventImage = UIImagePNGRepresentation(event.eventImage);
    }
    if ([event.ticketPriceAvg isKindOfClass:[NSString class]]) {
        self.ticketPriceAvg = event.ticketPriceAvg;
    }
    if ([event.ticketPriceHigh isKindOfClass:[NSString class]]) {
        self.ticketPriceHigh = event.ticketPriceHigh;
    }
    if ([event.ticketPriceLow isKindOfClass:[NSString class]]) {
        self.ticketPriceLow = event.ticketPriceLow;
    }
    if ([event.ticketsAvailable isKindOfClass:[NSString class]]) {
        self.ticketsAvailable = event.ticketsAvailable;
    }
    
    
    self.latitude = @(event.coordinate.latitude);
    self.longitude = @(event.coordinate.longitude);
    self.date = event.date;
}

@end
