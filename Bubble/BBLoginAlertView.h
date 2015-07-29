//
//  BBLoginAlertView.h
//  Bubble
//
//  Created by Lukas Thoms on 7/29/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "SCLAlertView.h"
#import <Parse.h>

@interface BBLoginAlertView : SCLAlertView

-(void) showLoginAlertViewOn: (UIViewController *)controller withCompletion:(void (^)(PFUser *currentUser))block;

@end
