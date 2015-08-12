#import "BBMessage.h"
#import "XMPP.h"
#import "XMPPRoomMemoryStorage.h"
#import <Foundation/Foundation.h>

@protocol MessageDelegate <NSObject>
@required
- (void)newMessageReceived:(BBMessage *)messageContent;
@end

@protocol ChatOccupantDelegate <NSObject>
@required
- (void)currentUserConnectedToChatroom;
- (void)newUserJoinedChatroom;
@end

@interface XMPPManager : NSObject
@property (weak, nonatomic) id<MessageDelegate>messageDelegate;
@property (weak, nonatomic) id<ChatOccupantDelegate>chatOccupantDelegate;
@property (strong, nonatomic) XMPPStream *xmppStream;
@property (strong, nonatomic) XMPPRoom *xmppRoom;
@property (strong, nonatomic) NSString *currentRoomId;

+ (instancetype)sharedManager;
- (BOOL)connect;
- (void)disconnect;
- (void)joinOrCreateRoom:(NSString *)room;
- (void) sendMessage: (BBMessage *)message;
@end
