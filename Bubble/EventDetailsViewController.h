//
//  EventDetailsViewController.h
//  Bubble
//
//  Created by Jordan Guggenheim on 7/29/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventObject.h"
//#import "BBScrollViewNotifying.h"

@interface EventDetailsViewController : UIViewController // <BBScrollViewNotifying>

@property (nonatomic, strong) EventObject *event;

@end
