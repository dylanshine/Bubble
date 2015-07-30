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

//
//- (NSString *)senderId {
//    return [PFUser currentUser].objectId;
//}
//
//- (NSString *)senderDisplayName {
//    return [PFUser currentUser][@"name"];
//}
//
//- (NSDate *)date {
//    return [NSDate date];
//}
//
//- (BOOL)isMediaMessage {
//    return NO;
//}
//
//- (NSUInteger)messageHash {
//    return [[PFUser currentUser] hash];
//}
//
//- (NSString *)text {
//    return self.content;
//}

@end
