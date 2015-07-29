//
//  AFDataStore.h
//  Bubble
//
//  Created by Val Osipenko on 7/29/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AFDataStore : NSObject

@property (nonatomic, strong) NSMutableArray *eventsArray;

+ (instancetype)sharedData;

-(void)getSeatgeekEvents;
@end
