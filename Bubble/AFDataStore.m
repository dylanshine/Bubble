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

@property (nonatomic, strong) NSMutableArray *eventsArray;

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

-(void)getSeatgeekEvents:(void (^)(NSArray*))completionBlock{
    NSString *url = [NSString stringWithFormat:@"http://api.seatgeek.com/2/events?lat=40.772514&lon=-73.983732&range=10mi&datetime_local.gte=2015-07-29&datetime_local.lt=2015-07-30&per_page=1000"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             [self createEventObjects:responseObject];
             
             completionBlock(self.eventsArray);
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
}


-(void)createEventObjects:(NSDictionary *)incomingJSON{
    
    for (NSDictionary *event in incomingJSON[@"events"]){
        
        EventObject * eventItem = [[EventObject alloc]initWithDictionary:event];
        
        [self.eventsArray addObject:eventItem];
    }
}

@end
