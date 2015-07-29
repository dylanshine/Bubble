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
    NSString *url = [NSString stringWithFormat:@"http://api.seatgeek.com/2/events?lat=%f&lon=%f&range=10mi&datetime_local.gte=2015-07-29&datetime_local.lt=2015-07-30&per_page=1000",currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
    NSLog(@"%@",currentLocation);
    NSLog(@"FULL URL: %@", url);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             [self createEventObjects:responseObject];
            
             // Implemented delegate to account for pagination if needed
             [self.delegate dataStore:self didLoadEvents:self.eventsArray];
            
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
}


- (void)createEventObjects:(NSDictionary *)incomingJSON{
    
    for (NSDictionary *event in incomingJSON[@"events"]){
        
        EventObject * eventItem = [[EventObject alloc]initWithDictionary:event];
        
        [self.eventsArray addObject:eventItem];
    }
}

- (NSArray *) searchEvents: (NSString *)searchTerm {
    
    if (![searchTerm isEqualToString:@""]) {
        NSPredicate *titlePredicate = [NSPredicate predicateWithFormat:@"SELF.eventTitle contains[c] %@", searchTerm];
        self.filteredEventsArray = [self.eventsArray filteredArrayUsingPredicate:titlePredicate];
        
        [self.delegate dataStore:self didLoadEvents:self.filteredEventsArray];
    } else {
        [self.delegate dataStore:self didLoadEvents:self.eventsArray];
    }
    
    return nil;
}














@end
