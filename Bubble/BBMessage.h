//
//  BBMessage.h
//  Bubble
//
//  Created by Lukas Thoms on 7/30/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSQMessageData.h>

@interface BBMessage : NSObject <JSQMessageData>

@property (strong, nonatomic) NSString *text;
@property (nonatomic) NSInteger messageHash;
@property (nonatomic) BOOL isMediaMessage;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *senderId;
@property (strong, nonatomic) NSString *senderDisplayName;

-(instancetype) initWithText: (NSString*)text;


@end
