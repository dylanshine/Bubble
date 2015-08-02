//
//  XMPPManager.h
//  Bubble
//
//  Created by Dylan Shine on 7/30/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPP.h"
#import "XMPPRoomMemoryStorage.h"
#import "BBMessage.h"

@protocol MessageDelegate <NSObject>
@required
- (void)newMessageReceived:(BBMessage *)messageContent;
@end

@protocol ChatOccupantDelegate <NSObject>
@required
- (void)connectToChatroom;
- (void)newUserJoinedChatroom;
- (void)userLeftChatroom;
@end

@interface XMPPManager : NSObject

@property (nonatomic, weak) id<MessageDelegate>messageDelegate;
@property (nonatomic, weak) id<ChatOccupantDelegate>chatOccupantDelegate;
@property (nonatomic) XMPPStream *xmppStream;
@property (nonatomic) XMPPRoom *xmppRoom;

+(instancetype)sharedManager;
-(BOOL)connect;
-(void)disconnect;
-(void)joinOrCreateRoom:(NSString *)room;
- (void) sendMessage: (BBMessage *)message;

@end
