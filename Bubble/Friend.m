#import "Friend.h"

@implementation Friend

-(instancetype)initWithName:(NSString *)name FacebookId:(NSString *)facebookId {
    if (self = [super init]) {
        _name = name;
        _facebookId = facebookId;
    }
    return self;
}

@end
