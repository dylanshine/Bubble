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
#import <Parse.h>
#import "WebViewController.h"

@interface EventDetailsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *eventTitle;
@property (weak, nonatomic) IBOutlet UILabel *eventStartTime;
@property (weak, nonatomic) IBOutlet UILabel *eventParticipants;
@property (weak, nonatomic) IBOutlet UILabel *eventVenueName;
@property (weak, nonatomic) IBOutlet UILabel *eventAddress;
- (IBAction)getTicketsTapped:(id)sender;

@end

@implementation EventDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self makeTranslucentBackground];
    [self adjustFontForDeviceSize];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:YES];
    [self fetchChatParticipantCount];
}

- (void) makeTranslucentBackground {
    
    ILTranslucentView *translucentView = [[ILTranslucentView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height)];
    
    translucentView.translucentAlpha = 1;
    translucentView.translucentStyle = UIStatusBarStyleDefault;
    
    [self.view insertSubview:translucentView atIndex:0];
    
    [translucentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.left.equalTo(@0);
        make.top.equalTo(@0);
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
    [self updateEventLabels];
}

- (void) updateEventLabels {
    self.eventTitle.text = self.event.eventTitle;
    self.eventStartTime.text = [NSString stringWithFormat:@"Start time: %@",self.event.eventTime];
    self.eventVenueName.text = self.event.venueName;
    self.eventAddress.text = [NSString stringWithFormat:@"%@\n%@, %@ %@",self.event.addressStreet,self.event.addressCity,self.event.addressState,self.event.addressZip];
    
    [self fetchChatParticipantCount];
}

- (void) fetchChatParticipantCount {

    if (self.event.eventID) {
        PFQuery *query = [PFUser query];
        [query whereKey:@"eventID" equalTo:self.event.eventID];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.eventParticipants.text = [NSString stringWithFormat:@"%lu participants",objects.count];
            } else {
                NSLog(@"Error fetching users in event");
            }
        }];
    }
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

- (IBAction)getTicketsTapped:(id)sender {
    if ([self seatGeekInstalled]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"seatgeek://events/%@",self.event.eventID]]];
    } else {
        [self performSegueWithIdentifier:@"webViewSegueID" sender:self];
    }
}

- (BOOL) seatGeekInstalled {
    NSURL *url = [NSURL URLWithString:@"seatgeek://app"];
    return [[UIApplication sharedApplication] canOpenURL:url];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    WebViewController *webviewVC = segue.destinationViewController;

    webviewVC.ticketURL = self.event.ticketURL;

}
@end
