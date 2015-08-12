#import "ChatDataManager.h"
#import <AFNetworking.h>

@implementation ChatDataManager

+ (instancetype)sharedManager {
    static ChatDataManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

-(instancetype)init {
    if (self=[super init]) {
        _messages = [[NSMutableArray alloc] init];
        _avatars = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)fetchUserProfilePictureWithFaceBookId:(NSString *)fbID
                                  Completion:(void (^)(UIImage *profileImage))block {
    if (![fbID isEqualToString:@""]) {
        
        NSString *url = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", fbID];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFImageResponseSerializer serializer];
        [manager GET:url parameters:nil
         
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 
                 block(responseObject);
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 
                 // Need to add placeholder image on failure
                 
                 NSLog(@"Error: %@", error);
                 
        }];
    }
}

@end
