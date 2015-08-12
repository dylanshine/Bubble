#import <Foundation/Foundation.h>
#import <JSQMessageData.h>

@interface BBMessage : NSObject <JSQMessageData>
@property (strong, nonatomic) NSString *text;
@property (nonatomic) NSInteger messageHash;
@property (assign, nonatomic) BOOL isMediaMessage;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *senderId;
@property (strong, nonatomic) NSString *senderDisplayName;

-(instancetype) initWithText: (NSString*)text;
-(instancetype) initIncomingWithText: (NSString *)text senderId:(NSString*)Id displayName:(NSString*)displayName date:(NSDate *)date;
@end
