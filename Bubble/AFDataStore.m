//
//  AFDataStore.m
//  Bubble
//
//  Created by Val Osipenko on 7/28/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "AFDataStore.h"
#import <AFNetworking.h>
#import "eventObject.h"

@interface AFDataStore()
@property (nonatomic, strong) NSDictionary *responseData;

@end

@implementation AFDataStore

-(instancetype)init{
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

-(void)getSeatgeekEvents{
    NSString *url = [NSString stringWithFormat:@"http://api.seatgeek.com/2/events?lat=40.772514&lon=-73.983732&range=10mi&datetime_local.gte=2015-07-29&datetime_local.lt=2015-07-30&per_page=1000"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             self.responseData = responseObject;
             
             [self createEventObjects];
             
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
}

-(void)createEventObjects{
    
    for (NSDictionary *event in self.responseData[@"events"]){
        NSString *eventID = event[@"id"];
        NSString *eventTitle = event[@"title"];
        NSString *eventType = event[@"type"];
        NSDate *eventTime = event[@"datetime_local"];
        NSString *venueLat = event[@"venue"][@"location"][@"lat"];
        NSString *venueLon = event[@"venue"][@"location"][@"lon"];
        
        eventObject * eventItem = [[eventObject alloc]initWithEventID:eventID eventTitle:eventTitle eventType:eventType eventTime:eventTime venueLat:venueLat venueLon:venueLon];
        [self.eventsArray addObject:eventItem];
        
    }
    
    NSLog(@"Event Count: %lu",(unsigned long)self.eventsArray.count);
    
    for(eventObject*event in self.eventsArray){
        NSLog(@"Event ID:%@",event.eventID);
    }

}

@end
