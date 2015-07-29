//
//  AFDataStore.h
//  Bubble
//
//  Created by Val Osipenko on 7/29/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AFDataStoreDelegate <NSObject>
- (void) batchEventArrays;
@end

@interface AFDataStore : NSObject

@property (nonatomic, strong) id<AFDataStoreDelegate> delegate;

+ (instancetype)sharedData;

-(void)getSeatgeekEvents:(void (^)(NSArray*))completionBlock;

@end
