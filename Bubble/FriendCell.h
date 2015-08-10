//
//  FriendCellTableViewCell.h
//  Bubble
//
//  Created by Dylan Shine on 8/10/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *friendImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
