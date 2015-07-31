//
//  ApplicationViewController.m
//  Bubble
//
//  Created by Jordan Guggenheim on 7/31/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "ApplicationViewController.h"
#import "EventMapViewController.h"
#import <Parse.h>
#import <SVProgressHUD.h>

@interface ApplicationViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation ApplicationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queueViewController)
                                                 name:@"loginComplete"
                                               object:nil];
    
    [self queueViewController];
}


- (void)viewDidAppear:(BOOL)animated{
    
}


- (void) queueViewController {
    [SVProgressHUD dismiss];
    if ([PFUser currentUser]) {
        
        UIViewController *mainVC =  [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"eventVC"];
        
        [self displayViewController:mainVC];
        
    } else {
        
        UIViewController *mainVC =  [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateInitialViewController];
        
        [self displayViewController:mainVC];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void) displayViewController:(UIViewController *) vc {
    
    UIViewController *childVC = self.childViewControllers.firstObject;
    
    if (childVC == vc) {
        return;
    }
    
    if (childVC) {

        [childVC willMoveToParentViewController:nil];
        
        if (childVC.isViewLoaded) {
            
            [childVC.view removeFromSuperview];
        }
        
        [childVC removeFromParentViewController];
    }
    
    if (!vc) {
        return;
    }
    
    [self addChildViewController:vc];
    [self.containerView addSubview:vc.view];
    
    [vc.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
    [vc didMoveToParentViewController:self];
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
