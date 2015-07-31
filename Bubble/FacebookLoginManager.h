//
//  FacebookLoginManager.h
//  Bubble
//
//  Created by Jordan Guggenheim on 7/31/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit.h>

@interface FacebookLoginManager : NSObject

+ (instancetype)sharedManager;

- (void) facebookLoginRequestWithCompletion:(void (^)(PFUser *currentUser))block;

@end
