//
//  LoginViewController.m
//  Bubble
//
//  Created by Jordan Guggenheim on 7/31/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//
#import <Masonry/Masonry.h>
#import "LoginViewController.h"
#import "ILTranslucentView.h"
#import "FacebookLoginManager.h"
#import <Parse.h>
#import <FBSDKLoginButton.h>
#import <SVProgressHUD.h>

@interface LoginViewController ()

@property (nonatomic, strong) FacebookLoginManager *loginManager;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loginManager = [FacebookLoginManager sharedManager];
    
    [self makeBackgroundImage];
    [self makeTranslucentBackground];
    [self makeBubbleLogo];
    [self makeLoginButton];
}

- (void) makeBackgroundImage {
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Yankee-Stadium"]];
    
    backgroundImage.contentMode = UIViewContentModeCenter;
    
    [self.view addSubview:backgroundImage];
    
    [backgroundImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
}


- (void) makeTranslucentBackground {
    
    ILTranslucentView *translucentView = [[ILTranslucentView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height)];
    
    translucentView.translucentAlpha = 1;
    translucentView.translucentStyle = UIBarStyleBlack;
    
//    [self.view insertSubview:translucentView atIndex:1];
    
    [self.view addSubview:translucentView];
    
    [translucentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
}

- (void) makeBubbleLogo {
    
    
    UIImageView *bubbleLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bubble-Logo"]];
    
    bubbleLogo.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.view addSubview:bubbleLogo];
    
    [bubbleLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(@300);
        make.centerX.equalTo(self.view);
        make.top.equalTo(@50);
    }];
}

- (void) makeLoginButton {
    
    FBSDKLoginButton *button = [[FBSDKLoginButton alloc] init];
    
    [button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [button addTarget:self action:@selector(loginToFacebook) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view).multipliedBy(.7);
        make.centerY.equalTo(self.view).offset(150);
        make.centerX.equalTo(self.view);
    }];
    
}

- (void) loginToFacebook {
    
    [SVProgressHUD show];
    
    [self.loginManager facebookLoginRequestWithCompletion:^(PFUser *currentUser) {
        [currentUser saveInBackground];
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation addUniqueObject:[PFUser currentUser].objectId forKey:@"channels"];
        [currentInstallation saveInBackground];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginComplete" object:nil];
        
        
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
