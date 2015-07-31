//
//  EventDetailsViewController.m
//  Bubble
//
//  Created by Jordan Guggenheim on 7/29/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "EventDetailsViewController.h"
#import "ILTranslucentView.h"
#import <Masonry/Masonry.h>

@interface EventDetailsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *eventTitle;
@property (weak, nonatomic) IBOutlet UILabel *eventSubtitle;

@end

@implementation EventDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self makeTranslucentBackground];
    
    [self adjustFontForDeviceSize];
}

- (void) makeTranslucentBackground {
    
    ILTranslucentView *translucentView = [[ILTranslucentView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height)];
    
    translucentView.translucentAlpha = .99;
    translucentView.translucentStyle = UIBarStyleDefault;
    
    [self.view insertSubview:translucentView atIndex:0];
    
    [translucentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
}

- (void) adjustFontForDeviceSize {

    if (self.view.frame.size.width == 320) {
        self.eventTitle.font = [self.eventTitle.font fontWithSize:28];
        
    } else if (self.view.frame.size.width == 375) {
        self.eventTitle.font = [self.eventTitle.font fontWithSize:34];
        
    }
}

- (void)setEvent:(EventObject *)event{
    
    _event = event;
    self.eventTitle.text = event.eventTitle;
    self.eventSubtitle.text = event.eventType;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
