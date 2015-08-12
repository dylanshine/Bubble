//
//  SubscribedEvent.m
//  
//
//  Created by Lukas Thoms on 8/12/15.
//
//

#import "SubscribedEvent.h"
#import "EventObject.h"


@implementation SubscribedEvent

@dynamic addressCity;
@dynamic addressState;
@dynamic addressStreet;
@dynamic addressZip;
@dynamic date;
@dynamic eventID;
@dynamic eventImage;
@dynamic eventScore;
@dynamic eventTime;
@dynamic eventTitle;
@dynamic eventType;
@dynamic latitude;
@dynamic longitude;
@dynamic ticketURL;
@dynamic venueName;
@dynamic venueScore;
@dynamic ticketsAvailable;
@dynamic ticketPriceAvg;
@dynamic ticketPriceHigh;
@dynamic ticketPriceLow;

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
