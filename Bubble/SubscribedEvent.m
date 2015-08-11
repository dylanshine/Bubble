//
//  SubscribedEvent.m
//  
//
//  Created by Dylan Shine on 8/11/15.
//
//

#import "SubscribedEvent.h"


@implementation SubscribedEvent

@dynamic eventID;
@dynamic eventTitle;
@dynamic eventType;
@dynamic eventTime;
@dynamic venueName;
@dynamic addressCity;
@dynamic addressState;
@dynamic addressZip;
@dynamic addressStreet;
@dynamic ticketURL;
@dynamic eventScore;
@dynamic venueScore;
@dynamic eventImage;
@dynamic eventPrice;
@dynamic latitude;
@dynamic longitude;

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
    if ([event.eventPrice isKindOfClass:[NSNumber class]]) {
        self.eventPrice = event.eventPrice;
    }
    self.latitude = @(event.coordinate.latitude);
    self.longitude = @(event.coordinate.longitude);
}

@end
