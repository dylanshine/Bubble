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

@implementation BBLoginAlertView

-(void) showLoginAlertViewOn: (UIViewController *)controller withCompletion:(void (^)(PFUser *currentUser))block {
    [self addButton:@"Login" actionBlock:^{
        NSArray *permissions = @[ @"email", @"user_likes", @"public_profile", @"user_friends" ];
        [PFFacebookUtils logInInBackgroundWithReadPermissions:permissions block:^(PFUser *user, NSError *error) {
            if (!user) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else if (user.isNew) {
                FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
                [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                    if (!error) {
                        NSDictionary *userData = (NSDictionary *)result;

                        PFUser *currentUser = [PFUser currentUser];
                        currentUser[@"name"] = userData[@"name"];
                        currentUser[@"friends"] = userData[@"user_friends"];
                        currentUser[@"likes"] = userData[@"user_likes"];
                        [currentUser saveInBackground];
                        NSLog(@"User logged in through Facebook!");
                    }
                }];

                NSLog(@"User signed up and logged in through Facebook!");
            } else {
                PFUser *currentUser = [PFUser currentUser];
                FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
                FBSDKGraphRequest *requestFriends = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends" parameters:nil];
                FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
                [connection addRequest:request completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                    NSDictionary *userData = (NSDictionary *)result;
                    currentUser[@"name"] = userData[@"name"];
                }];
                [connection addRequest:requestFriends completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                    NSDictionary *userData = (NSDictionary *)result;
                    NSLog(@"Friends: %@", userData);
                    currentUser[@"friends"] = userData[@"data"];
                }];
                
                [connection start];
            }

        }];
    }];
    [self showCustom:controller image:[UIImage imageNamed:@"FBLogo-blue_512_cropped"] color:[UIColor colorWithRed:59.0/255.0 green:89.0/255.0 blue:152.0/255.0 alpha:1] title:@"Login with Facebook" subTitle:@"Facebook login is required to participate in Bubble Events" closeButtonTitle:nil duration:0.0f];
}

@end
