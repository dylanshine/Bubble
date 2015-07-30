//
//  XMPPManager.m
//  Bubble
//
//  Created by Dylan Shine on 7/30/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "XMPPManager.h"
#import <UIKit/UIKit.h>
#import "Constants.h"
#import <Parse.h>

@implementation XMPPManager

+ (instancetype)sharedManager {
    static XMPPManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (void)setupStream {
    self.xmppStream = [[XMPPStream alloc] init];
    [self.xmppStream setHostName:kJABBER_HOSTNAME];
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (BOOL)connect {
    
    [self setupStream];
    
    if (![self.xmppStream isDisconnected]) {
        return YES;
    }
    
    if (![PFUser currentUser]) {
        return NO;
    }
    
    NSString *currentUserId = [PFUser currentUser][@"objectId"];
    
    [self.xmppStream setMyJID:[XMPPJID jidWithString:currentUserId]];
    self.xmppStream.hostName = kJABBER_HOSTNAME;
    
    NSError *error = nil;
    
    
    if (![self.xmppStream connectWithTimeout:10 error:&error]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[NSString stringWithFormat:@"Can't connect to server %@", [error localizedDescription]]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        
        return NO;
    }
    
    return YES;
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    
    NSString *presenceType = [presence type]; // online/offline
    NSString *myUsername = [[sender myJID] user];
    NSString *presenceFromUser = [[presence from] user];
    
    if (![presenceFromUser isEqualToString:myUsername]) {
        
        if ([presenceType isEqualToString:@"available"]) {
            
            NSLog(@"%@ has come online.",presenceFromUser);
            
        } else if ([presenceType isEqualToString:@"unavailable"]) {
        
            NSLog(@"%@ has gone offline.",presenceFromUser);
            
        }
    }
}

- (void)goOnline {
    XMPPPresence *presence = [XMPPPresence presence];
    [self.xmppStream sendElement:presence];
}

- (void)goOffline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [self.xmppStream sendElement:presence];
}

- (void)disconnect {
    [self goOffline];
    [self.xmppStream disconnect];
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    self.isOpen = YES;
    NSError *error = nil;
    [self.xmppStream authenticateAnonymously:&error];
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    NSLog(@"User Authenticated.");
    [self goOnline];
}


- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
    NSLog(@"%@",iq.description);
    return NO;
}


- (void)joinOrCreateRoom:(NSString *)room {
    XMPPRoomMemoryStorage *roomMemory = [[XMPPRoomMemoryStorage alloc]init];
    NSString *roomID = [NSString stringWithFormat:@"%@@conference.bubble", room];
    XMPPJID  *roomJID = [XMPPJID jidWithString:roomID];
    self.xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:roomMemory
                                                      jid:roomJID
                                            dispatchQueue:dispatch_get_main_queue()];
    [self.xmppRoom activate:self.xmppStream];
    [self.xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.xmppRoom joinRoomUsingNickname:self.password
                                 history:nil
                                password:nil];
}

-(void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID {
    NSLog(@"sender: %@ message: %@ occupant: %@",sender,message,occupantJID);
    NSString *msg = [[message elementForName:@"body"] stringValue];
    NSString *from = [[message attributeForName:@"from"] stringValue];
    
    NSMutableDictionary *messageDict = [[NSMutableDictionary alloc] init];
    
    if ([msg length]) {
        [messageDict setObject:msg forKey:@"msg"];
        [messageDict setObject:from forKey:@"sender"];
        [self.messageDelegate newMessageReceived:messageDict];
    }
}

- (void)xmppRoomDidCreate:(XMPPRoom *)sender{
    NSLog(@"%@: %@", @"xmppRoomDidCreate", sender);
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender{
    NSLog(@"%@: %@", @"xmppRoomDidJoin", sender);
}

- (void)dealloc {
    [self.xmppStream removeDelegate:self];
}

@end
