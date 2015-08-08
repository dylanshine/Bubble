//
//  WebViewController.m
//  Bubble
//
//  Created by Val Osipenko on 8/7/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webPage;
@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.ticketURL]];
    
    [self.webPage loadRequest:request];
}

- (IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
