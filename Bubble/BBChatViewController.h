//
//  BBChatViewController.h
//  Bubble
//
//  Created by Lukas Thoms on 7/30/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import <JSQMessagesViewController.h>
#import <CoreLocation/CoreLocation.h>

@interface BBChatViewController : JSQMessagesViewController

@property (nonatomic) NSString *roomID;
@property (nonatomic) CLLocation *eventLocation;
@property (nonatomic) CLLocation *currentUserLocation;
@property (nonatomic) NSString *eventTitle;
@property (nonatomic, strong) NSMutableArray *friendsAtEvent;

@end
