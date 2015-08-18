#import "EventObject.h"

@interface EventObject()
@property (strong, nonatomic) NSDictionary *eventDictionary;
@end

@implementation EventObject

- (instancetype)initWithSeatgeekDictionary:(NSDictionary *)jsonDict {
    
    self = [super init];

    NSString *title = jsonDict[@"title"];
    NSString *eventTitle = @"";
    
    if ([title containsString:@" - "]) {
        eventTitle = jsonDict[@"performers"][0][@"name"];
    } else {
        eventTitle = jsonDict[@"title"];
    }
    
    NSString *eventID = [jsonDict[@"id"] stringValue];
    NSString *eventType = jsonDict[@"type"];
    
    NSString *eventTime = jsonDict[@"datetime_local"];
    NSString *date = [eventTime substringToIndex:10];
    NSString *time = [eventTime substringFromIndex:11];
    NSString *dateTime = [NSString stringWithFormat:@"%@ %@", date, time];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *eventTimeAsDate = [[NSDate alloc] init];
    eventTimeAsDate = [dateFormat dateFromString:dateTime];

    [dateFormat setDateFormat:@"h:mm a"];
    eventTime = [dateFormat stringFromDate:eventTimeAsDate];
    
    if ([eventTime isEqualToString:@"3:30 AM"]) {
        eventTime = @"TBD";
    }

    NSNumber *listingCountNumber = jsonDict[@"stats"][@"listing_count"];
    NSString *listingCountString = @"No Tickets Available";
    NSString *ticketAvgPrice = @"";
    NSString *ticketHighPrice = @"";
    NSString *ticketLowestPrice = @"";

    if (![jsonDict[@"stats"][@"listing_count"] isKindOfClass:[NSNull class]] && ![listingCountNumber isEqual: @0]) {
        listingCountString = [NSString stringWithFormat:@"Tickets Available: %@",listingCountNumber];
        ticketAvgPrice = [NSString stringWithFormat:@"Average: $%@",jsonDict[@"stats"][@"average_price"]];
        ticketHighPrice = [NSString stringWithFormat:@"High: $%@",jsonDict[@"stats"][@"highest_price"]];;
        ticketLowestPrice = [NSString stringWithFormat:@"Low: $%@",jsonDict[@"stats"][@"lowest_price"]];;
    }
    
    NSNumber *venueLat = jsonDict[@"venue"][@"location"][@"lat"];
    NSNumber *venueLon = jsonDict[@"venue"][@"location"][@"lon"];
    NSString *venueName = jsonDict[@"venue"][@"name"];
    NSString *addressStreet = jsonDict[@"venue"][@"address"];
    NSString *addressCity = jsonDict[@"venue"][@"city"];
    NSString *addressState = jsonDict[@"venue"][@"state"];
    NSNumber *addressZip = jsonDict[@"venue"][@"postal_code"];
    
    // Occassionally the Street is missing from SeatGeek API
    if ([addressStreet isKindOfClass:[NSNull class]]) {
        addressStreet = @"";
        NSLog(@"Null address for event %@",eventTitle);
    }
    
    NSString *ticketURL = jsonDict[@"url"];
    NSString *eventImageURL = jsonDict[@"performers"][0][@"image"];
    
    // Set placeholder image.  Make dynamic for event types
    if ([eventImageURL isKindOfClass:[NSNull class]]) {
        eventImageURL = @"https://placekitten.com/g/414/310";
    }
    
    NSNumber *eventScore = [self checkIfNull:jsonDict[@"score"]];
    NSNumber *venueScore = jsonDict[@"venue"][@"score"];
    
    NSMutableArray *eventPerformers = [[NSMutableArray alloc]init];;
    for(NSDictionary* performer in jsonDict[@"performers"]){
        [eventPerformers addObject:performer[@"name"]];
    }
    CLLocationCoordinate2D coordinate;
    
    coordinate.latitude = venueLat.floatValue;
    coordinate.longitude = venueLon.floatValue;
    
    CLLocation *eventLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    if (self){
        _eventID = eventID;
        _eventTitle = eventTitle;
        _eventType = eventType;
        _eventTime = eventTime;
        _date = eventTimeAsDate;
        _coordinate = coordinate;
        _venueName = venueName;
        _eventPerformers = eventPerformers;
        _addressStreet = addressStreet;
        _addressCity = addressCity;
        _addressState = addressState;
        _addressZip = addressZip;
        _ticketURL = ticketURL;
        _ticketsAvailable = listingCountString;
        _ticketPriceAvg = ticketAvgPrice;
        _ticketPriceHigh = ticketHighPrice;
        _ticketPriceLow = ticketLowestPrice;
        _eventImageURL = eventImageURL;
        _eventScore = eventScore;
        _venueScore = venueScore;
        _eventLocation = eventLocation;
        _subscribed = NO;
        _rsvpYes = @"";
        _rsvpMaybe = @"";
    }
    
    return self;
}

- (instancetype)initWithMeetupDictionary:(NSDictionary *)jsonDict {
    
    self = [super init];
    
    NSString *eventTitle = jsonDict[@"name"];
    NSString *eventID = jsonDict[@"id"];
    NSString *eventType = @"meetup";
    
    NSString *eventTime = [jsonDict[@"time"] stringValue];
    NSString *eventTimeSeconds = [eventTime substringToIndex:10];
    NSTimeInterval eventTimeInterval = [eventTimeSeconds doubleValue];
    NSDate *eventDate = [NSDate dateWithTimeIntervalSince1970:eventTimeInterval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"h:mm a"];
    NSString *eventTimeString = [formatter stringFromDate:eventDate];
    
    NSNumber *venueLat = jsonDict[@"venue"][@"lat"];
    NSNumber *venueLon = jsonDict[@"venue"][@"lon"];
    NSString *venueName = jsonDict[@"venue"][@"name"];
    NSString *addressStreet = jsonDict[@"venue"][@"address_1"];
    NSString *addressCity = jsonDict[@"venue"][@"city"];
    NSString *addressState = jsonDict[@"venue"][@"state"];
    NSString *addressZip = @"";// jsonDict[@"venue"][@"zip"];
    NSString *ticketURL = jsonDict[@"event_url"];
    NSString *eventImageURL = jsonDict[@"group"][@"urlname"];
   
    UIImage *eventImage = [UIImage imageNamed:@"MeetupCover"];
    
    NSString *ticketPriceAvg = @"Admission: Free";
    NSString *rsvpYes = [NSString stringWithFormat:@"RSVP Yes: %@",jsonDict[@"yes_rsvp_count"]];
    NSString *rsvpMaybe = [NSString stringWithFormat:@"RSVP Maybe: %@",jsonDict[@"maybe_rsvp_count"]];

    if (jsonDict[@"fee"][@"amount"] != nil) {
        CGFloat floatPrice = ((NSNumber *)jsonDict[@"fee"][@"amount"]).floatValue;
        ticketPriceAvg = [NSString stringWithFormat:@"$%.f",floatPrice];
    }
    
    // Set placeholder image.  Make dynamic for event types
    if ([eventImageURL isKindOfClass:[NSNull class]]) {
        eventImageURL = @"https://placekitten.com/g/414/310";
    }
    
    NSNumber *eventScore = [self checkIfNull:jsonDict[@"yes_rsvp_count"]];
    
    NSMutableArray *eventPerformers = [[NSMutableArray alloc]init];;
    [eventPerformers addObject:jsonDict[@"group"][@"name"]];
    
    CLLocationCoordinate2D coordinate;
    
    coordinate.latitude = venueLat.floatValue;
    coordinate.longitude = venueLon.floatValue;
    
    CLLocation *eventLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    if (self){
        _eventID = eventID;
        _eventTitle = eventTitle;
        _eventType = eventType;
        _eventTime = eventTimeString;
        _date = eventDate;
        _coordinate = coordinate;
        _venueName = venueName;
        _eventPerformers = eventPerformers;
        _addressStreet = addressStreet;
        _addressCity = addressCity;
        _addressState = addressState;
        _addressZip = addressZip;
        _ticketURL = ticketURL;
        _ticketsAvailable = @"";
        _ticketPriceAvg = ticketPriceAvg;
        _ticketPriceHigh = @"";
        _ticketPriceLow = @"";
        _eventImageURL = eventImageURL;
        _eventScore = eventScore;
        _eventLocation = eventLocation;
        _eventImage = eventImage;
        _subscribed = NO;
        _rsvpYes = rsvpYes;
        _rsvpMaybe = rsvpMaybe;
    }
    return self;
}

-(instancetype) initWithSubscribedEvent: (SubscribedEvent *)event {
    self = [super init];
    if (self) {
        _eventID = event.eventID;
        _eventTitle = event.eventTitle;
        _eventType = event.eventType;
        _eventTime = event.eventTime;
        _date = event.date;
        _coordinate = CLLocationCoordinate2DMake([event.latitude doubleValue], [event.longitude doubleValue]);
        _venueName = event.venueName;
        _addressStreet = event.addressStreet;
        _addressCity = event.addressCity;
        _addressState = event.addressState;
        _addressZip = event.addressZip;
        _ticketURL = event.ticketURL;
        _eventScore = event.eventScore;
        _ticketPriceAvg = event.ticketPriceAvg;
        _ticketPriceHigh = event.ticketPriceHigh;
        _ticketPriceLow = event.ticketPriceLow;
        _ticketsAvailable = event.ticketsAvailable;
//        _eventLocation = event.eventLocation;
        _eventImage = [UIImage imageWithData:event.eventImage];
        _subscribed = YES;
        _rsvpMaybe = event.rsvpMaybe;
        _rsvpYes = event.rsvpYes;
        
    }
    return self;
}

- (void)fetchEventImage {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFImageResponseSerializer serializer];
    
    [manager GET:self.eventImageURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             self.eventImage = responseObject;             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"%@",error.description);
    }];
}


- (BOOL)isToday {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    if ([[formatter stringFromDate:self.date] isEqual:[formatter stringFromDate:[NSDate date]]]) {
        return YES;
    }
    return  NO;
}

- (NSNumber*)checkIfNull:(NSNumber*)number{
    if ([number isKindOfClass:[NSNull class]]){
        return @0;
    }
    else {
        return number;
    }
}

@end
