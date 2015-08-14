#import "FacebookLoginManager.h"
#import "LoginViewController.h"
#import <FBSDKLoginButton.h>
#import <Masonry/Masonry.h>
#import <Parse.h>
#import <SVProgressHUD.h>

@interface LoginViewController ()
@property (strong, nonatomic) FacebookLoginManager *loginManager;
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
    
    UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    
    [self.view addSubview:view];
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.left.equalTo(@0);
        make.top.equalTo(@0);
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

@end
