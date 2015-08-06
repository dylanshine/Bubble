//
//  ChatDataManager.m
//  Bubble
//
//  Created by Dylan Shine on 8/6/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "ChatDataManager.h"

@implementation ChatDataManager

+ (instancetype)sharedManager {
    static ChatDataManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

-(instancetype)init {
    if (self=[super init]) {
        _messages = [[NSMutableArray alloc] init];
        _avatars = [[NSMutableDictionary alloc] init];
    }
    return self;
}

@end
