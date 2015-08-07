//
//  TestViewController.m
//  Bubble
//
//  Created by Dylan Shine on 8/7/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "TestViewController.h"
#import "FriendsListView.h"
#import <Masonry.h>

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    FriendsListView *flView = [[[NSBundle mainBundle] loadNibNamed:@"FriendsListView" owner:self options:nil] objectAtIndex:0];
    FriendsListView *flView = [[[NSBundle mainBundle] loadNibNamed:@"FriendsListView" owner:self options:nil] lastObject];
    [self.view addSubview:flView];
    [flView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
