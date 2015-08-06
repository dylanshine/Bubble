//
//  ChatDataManager.h
//  Bubble
//
//  Created by Dylan Shine on 8/6/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatDataManager : NSObject

+(instancetype)sharedManager;
@property (nonatomic) NSMutableArray *messages;
@property (nonatomic) NSMutableDictionary *avatars;
@end
