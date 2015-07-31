//
//  BBLoginAlertView.m
//  Bubble
//
//  Created by Lukas Thoms on 7/29/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "BBLoginAlertView.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit.h>
#import <CWStatusBarNotification.h>

@implementation BBLoginAlertView

-(void) showLoginAlertViewOn: (UIViewController *)controller withCompletion:(void (^)(PFUser *currentUser))block {
    
    UIColor *facebookBlue = [UIColor colorWithRed:59.0/255.0 green:89.0/255.0 blue:152.0/255.0 alpha:1];
    
    CWStatusBarNotification *notification = [CWStatusBarNotification new];
    notification.notificationLabelBackgroundColor = facebookBlue;
    notification.notificationLabelTextColor = [UIColor whiteColor];
    
    [self addButton:@"Login" actionBlock:^{
        
        NSArray *permissions = @[ @"email", @"user_likes", @"public_profile", @"user_friends" ];
        
        [PFFacebookUtils logInInBackgroundWithReadPermissions:permissions block:^(PFUser *user, NSError *error) {
            
            PFUser *currentUser = [PFUser currentUser];
            
            if (!user) {
                // put code here if you want to execute something if the user cancels login
                
            } else if (user.isNew) {
                
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
                    [notification displayNotificationWithMessage:@"Successfully signed up with Facebook" forDuration:3.0f];
                    block(currentUser);
                }];

                [connection start];

            }
        }];
    }];
    
    [self showCustom:controller image:[UIImage imageNamed:@"FBLogo-blue_512_cropped"] color:facebookBlue title:@"Login with Facebook" subTitle:@"Facebook login is required to participate in Bubble Events" closeButtonTitle:nil duration:0.0f];
}

@end
