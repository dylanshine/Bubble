//
//  FriendsListView.m
//  Bubble
//
//  Created by Dylan Shine on 8/7/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "FriendsListView.h"
#import "FriendTableViewCell.h"
#import <Masonry.h>

@interface FriendsListView() <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *friendsListView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FriendsListView

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
    self.friends = [[NSMutableArray alloc] initWithObjects:@"1", nil];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [[NSBundle mainBundle] loadNibNamed:@"FriendsListView"
                                  owner:self
                                options:nil];

    
    [self addSubview:self.friendsListView];
    [self.friendsListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friends.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];
    
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"FriendTableViewCell" bundle:nil] forCellReuseIdentifier:@"friendCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];
    }
    
    cell.profileImageView.image = [UIImage imageNamed:@"Bubble-Red"];
    
    return cell;
}



@end
