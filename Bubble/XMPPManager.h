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

@interface XMPPManager : NSObject

@property (nonatomic) XMPPStream *xmppStream;
@property (nonatomic) XMPPRoom *xmppRoom;
@property (nonatomic) NSString *password;
@property (nonatomic) BOOL isOpen;

+(instancetype)sharedManager;
-(BOOL)connect;
-(void)disconnect;
-(void)joinOrCreateRoom:(NSString *)room;

@end
