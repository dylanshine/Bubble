//
//  ChatDataManager.h
//  Bubble
//
//  Created by Dylan Shine on 8/6/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ChatDataManager : NSObject
@property (nonatomic) NSMutableArray *messages;
@property (nonatomic) NSMutableDictionary *avatars;

+(instancetype)sharedManager;
-(void)fetchUserProfilePictureWithFaceBookId:(NSString *)fbID Completion:(void (^)(UIImage *profileImage))block;
@end
