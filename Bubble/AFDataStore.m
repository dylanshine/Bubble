//
//  AFDataStore.m
//  Bubble
//
//  Created by Val Osipenko on 7/29/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "AFDataStore.h"
#import <AFNetworking.h>
#import "EventObject.h"
#import "Constants.h"
@interface AFDataStore()


@property (nonatomic, strong) NSArray *filteredEventsArray;

@end

@implementation AFDataStore

- (instancetype)init{
    self = [super init];
    if(self){
        _eventsArray = [[NSMutableArray alloc]init];
    }
    return self;
}

+ (instancetype)sharedData {
    static AFDataStore *_sharedData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedData = [[self alloc] init];
        _sharedData.eventsArray = [[NSMutableArray alloc] init];
    });
    
    return _sharedData;
}

- (void)getSeatgeekEventsWithLocation:(CLLocation *)currentLocation{
    [self getSeatgeekEventsWithLocation:currentLocation date:[NSDate date]];
    
}

-(void)getSeatgeekEventsWithLocation:(CLLocation *)currentLocation date:(NSDate *)date {
    NSDateComponents *nextDaySetter = [[NSDateComponents alloc] init];
    nextDaySetter.day = 1;
    NSDate *nextDay = [date dateByAddingTimeInterval:60*60*24];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    // create API URL and make the call
    NSString *url = [NSString stringWithFormat:@"http://api.seatgeek.com/2/events?lat=%f&lon=%f&range=15mi&datetime_local.gte=%@&datetime_local.lt=%@&per_page=1000",currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, [formatter stringFromDate:date], [formatter stringFromDate:nextDay]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:url parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             [self createSeatgeekEventObjects:responseObject];
             
             // Implemented delegate to account for pagination if needed
             [self.delegate dataStore:self didLoadEvents:self.eventsArray];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
}

- (void)getMeetupEventsWithLocation:(CLLocation *)currentLocation date:(NSDate*)date{
    NSDateComponents *tomorrowSetter = [[NSDateComponents alloc] init];
    tomorrowSetter.day = 1;
    NSDate *tomorrow = [date dateByAddingTimeInterval:60*60*24];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate * todayEpoch = [formatter dateFromString:[formatter stringFromDate:date]];
    NSDate * tomorrowEpoch = [formatter dateFromString:[formatter stringFromDate:tomorrow]];
    
    NSString *url = [NSString stringWithFormat:@"https://api.meetup.com/2/open_events?&key=%@&photo-host=public&lat=%f&lon=%f&time=%lld,%lld&radius=10&page=75",kMEETUP_API_KEY, currentLocation.coordinate.latitude, currentLocation.coordinate.longitude,[@(floor([todayEpoch timeIntervalSince1970] * 1000)) longLongValue],[@(floor([tomorrowEpoch timeIntervalSince1970] * 1000)) longLongValue]];
    
    
    //https://api.meetup.com/2/groups?&sign=true&photo-host=public&group_urlname=NYCUltimate&page=20
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:url parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             [self createMeetupEventObjects:responseObject];
             // Implemented delegate to account for pagination if needed
             [self.delegate dataStore:self didLoadEvents:self.eventsArray];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
}

- (void)createSeatgeekEventObjects:(NSDictionary *)incomingJSON{
    
    self.eventsArray = [@[] mutableCopy];
    for (NSDictionary *event in incomingJSON[@"events"]){
        
        EventObject * eventItem = [[EventObject alloc]initWithSeatgeekDictionary:event];
        
        [eventItem fetchEventImage];
        
        [self.eventsArray addObject:eventItem];
    }
}

- (void)createMeetupEventObjects:(NSDictionary *)incomingJSON{
    
    //self.eventsArray = [@[] mutableCopy];
    for (NSDictionary *event in incomingJSON[@"results"]){
        
        EventObject * eventItem = [[EventObject alloc]initWithMeetupDictionary:event];
        
        //[eventItem fetchEventImage];
        
        [self.eventsArray addObject:eventItem];
    }
    NSLog(@"%lu",(unsigned long)self.eventsArray.count);
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
