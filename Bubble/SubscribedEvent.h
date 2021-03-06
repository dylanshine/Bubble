//
//  SubscribedEvent.h
//  
//
//  Created by Val Osipenko on 8/17/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SubscribedEvent : NSManagedObject

@property (nonatomic, retain) NSString * addressCity;
@property (nonatomic, retain) NSString * addressState;
@property (nonatomic, retain) NSString * addressStreet;
@property (nonatomic, retain) NSNumber * addressZip;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * eventID;
@property (nonatomic, retain) NSData * eventImage;
@property (nonatomic, retain) NSNumber * eventScore;
@property (nonatomic, retain) NSString * eventTime;
@property (nonatomic, retain) NSString * eventTitle;
@property (nonatomic, retain) NSString * eventType;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * ticketPriceAvg;
@property (nonatomic, retain) NSString * ticketPriceHigh;
@property (nonatomic, retain) NSString * ticketPriceLow;
@property (nonatomic, retain) NSString * ticketsAvailable;
@property (nonatomic, retain) NSString * ticketURL;
@property (nonatomic, retain) NSString * venueName;
@property (nonatomic, retain) NSNumber * venueScore;
@property (nonatomic, retain) NSString * rsvpYes;
@property (nonatomic, retain) NSString * rsvpMaybe;

@end
