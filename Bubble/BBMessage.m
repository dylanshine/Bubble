//
//  BBMessage.m
//  Bubble
//
//  Created by Lukas Thoms on 7/30/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "BBMessage.h"
#import <Parse.h>


@implementation BBMessage

-(instancetype) initWithText: (NSString*)text {
    self = [super init];
    if (self) {
        _date = [NSDate date];
        _isMediaMessage = NO;
        _text = text;
        _senderDisplayName = [PFUser currentUser][@"name"];
        _senderId = [PFUser currentUser].objectId;
        
        NSMutableString *hashString = [text mutableCopy];
        [hashString appendString:[NSDate date].description];
        _messageHash = [hashString hash];
    }
    
    return self;
}

-(instancetype) initIncomingWithText: (NSString *)text senderId:(NSString*)Id displayName:(NSString*)displayName date:(NSDate *)date {
    
    self = [super init];
    if (self) {
        _date = date;
        _isMediaMessage = NO;
        _text = text;
        _senderDisplayName = displayName;
        _senderId = Id;
        NSMutableString *hashString = [text mutableCopy];
        [hashString appendString:date.description];
        _messageHash = [hashString hash];
    }
    return self;
}


@end
