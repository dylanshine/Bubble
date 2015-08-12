#import "AFDataStore.h"
#import <AFNetworking.h>
#import "EventObject.h"
#import "Constants.h"
@interface AFDataStore()


@property (nonatomic, strong) NSArray *filteredEventsArray;

@end

@implementation AFDataStore

- (instancetype)init{
    if (self = [super init]){
        _eventsArray = [[NSMutableArray alloc]init];
    }
    return self;
}

+ (instancetype)sharedData {
    static AFDataStore *_sharedData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedData = [[self alloc] init];
    });
    
    return _sharedData;
}

- (void)getAllEventsWithLocation:(CLLocation *)currentLocation date:(NSDate *)date{
    
    [self.eventsArray removeAllObjects];
    
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    operationQueue.maxConcurrentOperationCount = 1;
    
    
    NSBlockOperation *seatgeekOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        AFHTTPRequestOperation *seatGeekOp = [self getSeatgeekEventsWithLocation:currentLocation date:date];
        [seatGeekOp waitUntilFinished];
    }];
    
    NSBlockOperation *meetupOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        AFHTTPRequestOperation *meetUpOp = [self getMeetupEventsWithLocation:currentLocation date:date];
        [meetUpOp waitUntilFinished];
    }];
    
    [meetupOperation addDependency:seatgeekOperation];
    
    [operationQueue addOperation:seatgeekOperation];
    [operationQueue addOperation:meetupOperation];
    
}

- (AFHTTPRequestOperation *)getSeatgeekEventsWithLocation:(CLLocation *)currentLocation date:(NSDate *)date {
    NSDateComponents *nextDaySetter = [[NSDateComponents alloc] init];
    nextDaySetter.day = 1;
    NSDate *nextDay = [date dateByAddingTimeInterval:60*60*24];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    // create API URL and make the call
    NSString *url = [NSString stringWithFormat:@"http://api.seatgeek.com/2/events?lat=%f&lon=%f&range=15mi&datetime_local.gte=%@&datetime_local.lt=%@&per_page=1000&aid=11510",currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, [formatter stringFromDate:date], [formatter stringFromDate:nextDay]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    return [manager GET:url parameters:nil
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    [self createSeatgeekEventObjects:responseObject];
 
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                }];
}

- (AFHTTPRequestOperation *)getMeetupEventsWithLocation:(CLLocation *)currentLocation date:(NSDate*)date{
    NSDateComponents *tomorrowSetter = [[NSDateComponents alloc] init];
    tomorrowSetter.day = 1;
    NSDate *tomorrow = [date dateByAddingTimeInterval:60*60*24];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate * todayEpoch = [formatter dateFromString:[formatter stringFromDate:date]];
    NSDate * tomorrowEpoch = [formatter dateFromString:[formatter stringFromDate:tomorrow]];
    
    NSString *url = [NSString stringWithFormat:@"https://api.meetup.com/2/open_events?&key=%@&photo-host=public&lat=%f&lon=%f&time=%lld,%lld&radius=10&page=200",kMEETUP_API_KEY, currentLocation.coordinate.latitude, currentLocation.coordinate.longitude,[@(floor([todayEpoch timeIntervalSince1970] * 1000)) longLongValue],[@(floor([tomorrowEpoch timeIntervalSince1970] * 1000)) longLongValue]];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    return [manager GET:url parameters:nil
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    [self createMeetupEventObjects:responseObject];
                    // Implemented delegate to account for pagination if needed
                    [self.delegate dataStore:self didLoadEvents:self.eventsArray];
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                    [self.delegate dataStore:self didLoadEvents:self.eventsArray];
                }];
}

- (void)createSeatgeekEventObjects:(NSDictionary *)incomingJSON{
    
    for (NSDictionary *event in incomingJSON[@"events"]){
        
        EventObject * eventItem = [[EventObject alloc]initWithSeatgeekDictionary:event];
        
        [eventItem fetchEventImage];
        
        [self.eventsArray addObject:eventItem];
    }
}

- (void)createMeetupEventObjects:(NSDictionary *)incomingJSON{
    
    for (NSDictionary *event in incomingJSON[@"results"]){
        
        EventObject * eventItem = [[EventObject alloc]initWithMeetupDictionary:event];
        
        if ([eventItem.eventScore intValue] > 25){
            [self.eventsArray addObject:eventItem];
        }
    }
}



- (void) searchEvents: (NSString *)searchTerm withScope:(NSInteger)index {
    
    if ([searchTerm isEqualToString:@""]) {
        self.filteredEventsArray = self.eventsArray;
    } else if (index == 0) {
        NSPredicate *titlePredicate = [NSPredicate predicateWithFormat:@"SELF.eventTitle contains[c] %@", searchTerm];
        self.filteredEventsArray = [self.eventsArray filteredArrayUsingPredicate:titlePredicate];

    } else if (index == 1) {
        NSPredicate *venuePredicate = [NSPredicate predicateWithFormat:@"SELF.venueName contains[c] %@", searchTerm];
        self.filteredEventsArray = [self.eventsArray filteredArrayUsingPredicate:venuePredicate];

    } else if (index == 2) {
        NSPredicate *performerPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchTerm];
        NSMutableArray *results = [@[]mutableCopy];
        for (EventObject *event in self.eventsArray) {
            if (![[event.eventPerformers filteredArrayUsingPredicate:performerPredicate] isEqual:@[]] && ![results containsObject:event]) {
                [results addObject:event];
            }
        }
        self.filteredEventsArray = results;

    } else {
        self.filteredEventsArray = @[];

    }
    [self.delegate dataStore:self didLoadEvents:self.filteredEventsArray];
}














@end
