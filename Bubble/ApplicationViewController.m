#import "ApplicationViewController.h"
#import "EventMapViewController.h"
#import <Masonry/Masonry.h>
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

@end
