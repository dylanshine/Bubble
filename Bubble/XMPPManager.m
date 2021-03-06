#import "XMPPManager.h"
#import <UIKit/UIKit.h>
#import "Constants.h"
#import <Parse.h>
#import <XMPPReconnect.h>

@interface XMPPManager ()
@property (strong, nonatomic) XMPPReconnect *xmppReconnect;
@end

@implementation XMPPManager

+ (instancetype)sharedManager {
    static XMPPManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

#pragma mark - Setup Stream and Connect to Server

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
    
    NSString *currentUserId = [NSString stringWithFormat:@"%@@bubble",[PFUser currentUser].objectId];
    
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

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    NSError *error = nil;
    if(![self.xmppStream authenticateAnonymously:&error]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[NSString stringWithFormat:@"Can't connect to server %@", [error localizedDescription]]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    NSLog(@"User Authenticated.");
    self.xmppReconnect = [[XMPPReconnect alloc] init];
    [self.xmppReconnect activate:self.xmppStream];
    [self.xmppReconnect addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self goOnline];
    
    if (self.currentRoomId && ![self.xmppRoom isJoined]) {
        [self joinOrCreateRoom:self.currentRoomId];
    }
}

#pragma mark - XMPP Presence

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

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
    NSLog(@"%@",iq.description);
    return NO;
}

#pragma mark - XMPP Room

- (void)joinOrCreateRoom:(NSString *)room {
    self.currentRoomId = room;
    XMPPRoomMemoryStorage *roomMemory = [[XMPPRoomMemoryStorage alloc]init];
    NSString *roomID = [NSString stringWithFormat:@"%@@conference.bubble", room];
    XMPPJID  *roomJID = [XMPPJID jidWithString:roomID];
    self.xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:roomMemory
                                                      jid:roomJID
                                            dispatchQueue:dispatch_get_main_queue()];
    [self.xmppRoom activate:self.xmppStream];
    [self.xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.xmppRoom joinRoomUsingNickname:[PFUser currentUser][@"facebookId"]
                                 history:nil
                                password:nil];
}

-(void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID {
    NSLog(@"sender: %@ message: %@ occupant: %@",sender,message,occupantJID);
    NSString *msg = [[message elementForName:@"body"] stringValue];
    
    BBMessage *bbMessage = [[BBMessage alloc] initIncomingWithText:[[message elementForName:@"body"] stringValue]
                                                          senderId:[[message attributeForName:@"senderId"] stringValue]
                                                       displayName:[[message attributeForName:@"displayName"] stringValue]
                                                              date:[NSDate dateWithTimeIntervalSince1970:[[message attributeForName:@"date"] stringValue].floatValue]];
    
    
    if ([msg length]) {
        [self.messageDelegate newMessageReceived:bbMessage];
    }
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence {
    [self.chatOccupantDelegate newUserJoinedChatroom];
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender{
    [self.chatOccupantDelegate currentUserConnectedToChatroom];
}

#pragma mark - Send Message

- (void) sendMessage: (BBMessage *)message {
    if([message.text length] > 0) {
        
        XMPPMessage *xMessage = [[XMPPMessage alloc] init];
        [xMessage addAttributeWithName:@"senderId" stringValue:[PFUser currentUser][@"facebookId"]];
        [xMessage addAttributeWithName:@"displayName" stringValue:[PFUser currentUser][@"name"]];
        NSString *dateTimeInterval = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
        [xMessage addAttributeWithName:@"date" stringValue:dateTimeInterval];
        [xMessage addBody:message.text];
        [self.xmppRoom sendMessage:xMessage];
    }
}

#pragma mark - Dealloc
- (void)dealloc {
    [self.xmppStream removeDelegate:self];
    [self.xmppRoom removeDelegate:self];
}
@end
