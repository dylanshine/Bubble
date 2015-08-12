#import "SubscribedEvent.h"
#import <AFNetworking/AFNetworking.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface EventObject : NSObject

@property (strong, nonatomic) NSString *eventID;
@property (strong, nonatomic) NSString *eventTitle;
@property (strong, nonatomic) NSString *eventType;
@property (strong, nonatomic) NSString *eventTime;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *venueName;
@property (strong, nonatomic) NSMutableArray *eventPerformers;
@property (strong, nonatomic) NSString *addressStreet;
@property (strong, nonatomic) NSString *addressCity;
@property (strong, nonatomic) NSString *addressState;
@property (strong, nonatomic) NSNumber *addressZip;
@property (strong, nonatomic) NSString *ticketURL;
@property (strong, nonatomic) NSString *ticketsAvailable;
@property (strong, nonatomic) NSString *ticketPriceAvg;
@property (strong, nonatomic) NSString *ticketPriceHigh;
@property (strong, nonatomic) NSString *ticketPriceLow;
@property (strong, nonatomic) NSNumber *eventScore;
@property (strong, nonatomic) NSNumber *venueScore;
@property (strong, nonatomic) NSString *eventImageURL;
@property (strong, nonatomic) UIImage *eventImage;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) CLLocation *eventLocation;
@property (assign, nonatomic) BOOL subscribed;

- (instancetype)initWithSeatgeekDictionary:(NSDictionary *)jsonDict;
- (instancetype)initWithMeetupDictionary:(NSDictionary *)jsonDict;
- (instancetype)initWithSubscribedEvent: (SubscribedEvent *)event;
- (void)fetchEventImage;
- (BOOL)isToday;
@end
