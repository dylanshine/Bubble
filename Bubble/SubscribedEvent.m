//
//  SubscribedEvent.m
//  
//
//  Created by Lukas Thoms on 8/11/15.
//
//

#import "SubscribedEvent.h"
#import "EventObject.h"


@implementation SubscribedEvent

@dynamic addressCity;
@dynamic addressState;
@dynamic addressStreet;
@dynamic addressZip;
@dynamic eventID;
@dynamic eventImage;
@dynamic eventPrice;
@dynamic eventScore;
@dynamic eventTime;
@dynamic eventTitle;
@dynamic eventType;
@dynamic latitude;
@dynamic longitude;
@dynamic ticketURL;
@dynamic venueName;
@dynamic venueScore;
@dynamic date;

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

    self.latitude = @(event.coordinate.latitude);
    self.longitude = @(event.coordinate.longitude);
    self.date = event.date;
}

@end
