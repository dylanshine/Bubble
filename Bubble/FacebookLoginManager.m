#import "FacebookLoginManager.h"
#import <Parse.h>

@implementation FacebookLoginManager

+ (instancetype)sharedManager {
    static FacebookLoginManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}


- (void)facebookLoginRequestWithCompletion:(void (^)(PFUser *currentUser))block  {
    NSArray *permissions = @[ @"email", @"user_likes", @"public_profile", @"user_friends" ];
    
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissions block:^(PFUser *user, NSError *error) {
        
        PFUser *currentUser = [PFUser currentUser];
        
        if (!user) {
            // put code here if you want to execute something if the user cancels login
            
        } else {
            
            FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
            
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
            FBSDKGraphRequest *requestFriends = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends" parameters:nil];
            
            [connection addRequest:request completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                NSDictionary *userData = (NSDictionary *)result;
                currentUser[@"name"] = userData[@"name"];
                currentUser[@"facebookId"] = userData[@"id"];
            }];
            
            [connection addRequest:requestFriends completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                NSDictionary *userData = (NSDictionary *)result;
                currentUser[@"friends"] = userData[@"data"];
                block(currentUser);
            }];

            [connection start];
        }
    }];
}

@end
