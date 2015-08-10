//
//  Friend.m
//  Bubble
//
//  Created by Dylan Shine on 8/10/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "Friend.h"

@implementation Friend

-(instancetype)initWithName:(NSString *)name FacebookId:(NSString *)facebookId {
    if (self = [super init]) {
        _name = name;
        _facebookId = facebookId;
    }
    return self;
}

@end
