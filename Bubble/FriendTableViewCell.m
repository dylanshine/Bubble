//
//  FriendTableViewCell.m
//  Bubble
//
//  Created by Dylan Shine on 8/7/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "FriendTableViewCell.h"
#import <Masonry.h>

@interface FriendTableViewCell()
@property (weak, nonatomic) IBOutlet UIView *cellView;
@end

@implementation FriendTableViewCell

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void) commonInit {
    
    [[NSBundle mainBundle] loadNibNamed:@"FriendTableViewCell"
                                  owner:self
                                options:nil];
    
    
    [self addSubview:self.cellView];
    [self.cellView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
