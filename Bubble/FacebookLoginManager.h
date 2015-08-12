#import <FBSDKCoreKit.h>
#import <Foundation/Foundation.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

@interface FacebookLoginManager : NSObject
+ (instancetype)sharedManager;
- (void) facebookLoginRequestWithCompletion:(void (^)(PFUser *currentUser))block;
@end
