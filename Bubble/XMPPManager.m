//
//  XMPPManager.m
//  Bubble
//
//  Created by Dylan Shine on 7/30/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "XMPPManager.h"
#import <UIKit/UIKit.h>

@implementation XMPPManager

+ (instancetype)sharedManager {
    static XMPPManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

@end
