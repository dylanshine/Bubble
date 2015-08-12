#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ChatDataManager : NSObject
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong ,nonatomic) NSMutableDictionary *avatars;

+ (instancetype)sharedManager;
- (void)fetchUserProfilePictureWithFaceBookId:(NSString *)fbID Completion:(void (^)(UIImage *profileImage))block;
@end
