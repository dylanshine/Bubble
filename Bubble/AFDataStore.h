//
//  AFDataStore.h
//  Bubble
//
//  Created by Val Osipenko on 7/29/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFDataStore;

@protocol AFDataStoreDelegate <NSObject>

@required
- (void) dataStore:(AFDataStore *)datastore didLoadEvents:(NSArray *)eventsArray;

@end

@interface AFDataStore : NSObject

@property (nonatomic, strong) id<AFDataStoreDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *eventsArray;

+ (instancetype)sharedData;

- (NSArray *) searchEvents: (NSString *)searchTerm;
- (void)getSeatgeekEvents;

@end
