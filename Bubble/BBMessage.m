#import "BBMessage.h"
#import <Parse.h>

@implementation BBMessage

- (instancetype) initWithText: (NSString*)text {
    if (self = [super init]) {
        _date = [NSDate date];
        _isMediaMessage = NO;
        _text = text;
        _senderDisplayName = [PFUser currentUser][@"name"];
        _senderId = [PFUser currentUser][@"facebookId"];
        NSMutableString *hashString = [text mutableCopy];
        [hashString appendString:[NSDate date].description];
        _messageHash = [hashString hash];
    }
    return self;
}

- (instancetype) initIncomingWithText: (NSString *)text senderId:(NSString*)Id displayName:(NSString*)displayName date:(NSDate *)date {
    if (self = [super init]) {
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
