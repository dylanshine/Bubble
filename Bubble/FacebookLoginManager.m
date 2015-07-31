//
//  FacebookLoginManager.m
//  Bubble
//
//  Created by Jordan Guggenheim on 7/31/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "FacebookLoginManager.h"



@implementation FacebookLoginManager

+ (instancetype)sharedManager {
    static FacebookLoginManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}


- (void) facebookLoginRequestWithCompletion:(void (^)(PFUser *currentUser))block  {
    NSArray *permissions = @[ @"email", @"user_likes", @"public_profile", @"user_friends" ];
    
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissions block:^(PFUser *user, NSError *error) {
        
        PFUser *currentUser = [PFUser currentUser];
        
        if (!user) {
            // put code here if you want to execute something if the user cancels login
            
        } else {
            
            // Add NSOperation Queue to eliminate possible race condition.
            
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
            FBSDKGraphRequest *requestFriends = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends" parameters:nil];
            FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
            
            [connection addRequest:request completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                NSDictionary *userData = (NSDictionary *)result;
                currentUser[@"name"] = userData[@"name"];
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
