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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)getTicketsTapped:(id)sender {
    if (![self.event.eventType isEqualToString:@"meetup"] && [self seatGeekInstalled]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"seatgeek://events/%@",self.event.eventID]]];
    }
    else if ([self.event.eventType isEqualToString:@"meetup"] &&[self meetupInstalled]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"meetup://events/%@",self.event.eventID]]];
    }
    else {
        WebViewController *webVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"webViewController"];
        webVC.ticketURL = self.event.ticketURL;
        
        [self presentViewController:webVC animated:YES completion:^{}];
    }
}

- (BOOL) seatGeekInstalled {
    NSURL *url = [NSURL URLWithString:@"seatgeek://app"];
    return [[UIApplication sharedApplication] canOpenURL:url];
}
- (BOOL) meetupInstalled {
    NSURL *url = [NSURL URLWithString:@"meetup://app"];
    return [[UIApplication sharedApplication] canOpenURL:url];
}

@end
