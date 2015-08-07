//
//  AFDataStore.h
//  Bubble
//
//  Created by Val Osipenko on 7/29/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class AFDataStore;

@protocol AFDataStoreDelegate <NSObject>

@required
- (void) dataStore:(AFDataStore *)datastore didLoadEvents:(NSArray *)eventsArray;

@end

@interface AFDataStore : NSObject

@property (nonatomic, strong) id<AFDataStoreDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *eventsArray;

+ (instancetype)sharedData;


- (void) searchEvents: (NSString *)searchTerm withScope:(NSInteger)index;

- (void) getSeatgeekEventsWithLocation:(CLLocation*)currentLocation;

- (void) getSeatgeekEventsWithLocation:(CLLocation *)currentLocation date:(NSDate *)date;
- (void) getMeetupEventsWithLocation:(CLLocation *)currentLocation date:(NSDate *)date;

@end
