//
//  Friend.h
//  Bubble
//
//  Created by Dylan Shine on 8/10/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Friend : NSObject
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *facebookId;
@property (nonatomic) UIImage *image;

-(instancetype)initWithName:(NSString *)name FacebookId:(NSString *)facebookId;
@end
