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
#import "UILabel+AutoresizeFontMultiLine.h"

@interface EventDetailsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *eventTitle;
@property (weak, nonatomic) IBOutlet UILabel *eventStartTime;
@property (weak, nonatomic) IBOutlet UILabel *eventVenueName;
@property (weak, nonatomic) IBOutlet UILabel *eventAddress;
@property (weak, nonatomic) IBOutlet UILabel *eventTicketsTitle;
@property (weak, nonatomic) IBOutlet UILabel *eventTickets;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *getDirectionsIconWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *getTicketsIconWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ticketHeaderTop;

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
    
    if (self.eventTitle.text.length > 20) {
        self.eventTitle.numberOfLines = 2;
        self.eventTitle.minimumScaleFactor = 0.8;
        self.eventTitle.lineBreakMode = NSLineBreakByTruncatingTail;
        
    } else {
        self.eventTitle.numberOfLines = 1;
        self.eventTitle.minimumScaleFactor = .7;
        self.eventTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    
    if (self.view.frame.size.width == 320) {
        [self.eventTitle adjustFontSizeToFitWithMaxSize:26];
        self.eventStartTime.font = [self.eventStartTime.font fontWithSize:14];
        self.eventAddress.font = [self.eventAddress.font fontWithSize:14];
        self.eventVenueName.font = [self.eventVenueName.font fontWithSize:16];
        self.eventTicketsTitle.font = [self.eventTicketsTitle.font fontWithSize:16];
        self.eventTickets.font = [self.eventTickets.font fontWithSize:14];
        
        self.ticketHeaderTop.constant = 14;
        self.getTicketsIconWidth.constant = 80;
        self.getDirectionsIconWidth.constant = 80;
        
    } else if (self.view.frame.size.width == 375) {
        [self.eventTitle adjustFontSizeToFitWithMaxSize:36];
        self.eventStartTime.font = [self.eventStartTime.font fontWithSize:14];
        self.eventAddress.font = [self.eventAddress.font fontWithSize:16];
        self.eventVenueName.font = [self.eventVenueName.font fontWithSize:22];
        self.eventTicketsTitle.font = [self.eventTicketsTitle.font fontWithSize:22];
        self.eventTickets.font = [self.eventTickets.font fontWithSize:16];

        self.getTicketsIconWidth.constant = 110;
        self.getDirectionsIconWidth.constant = 110;
        
    } else {
        [self.eventTitle adjustFontSizeToFitWithMaxSize:40];
        self.eventStartTime.font = [self.eventStartTime.font fontWithSize:14];
        self.eventAddress.font = [self.eventAddress.font fontWithSize:18];
        self.eventVenueName.font = [self.eventVenueName.font fontWithSize:24];
        self.eventTicketsTitle.font = [self.eventTicketsTitle.font fontWithSize:24];
        self.eventTickets.font = [self.eventTickets.font fontWithSize:18];
        
        self.getTicketsIconWidth.constant = 100;
        self.getDirectionsIconWidth.constant = 110;
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

    self.eventTickets.text = [NSString stringWithFormat:@"%@\n\n%@\n%@\n%@",self.event.ticketsAvailable,self.event.ticketPriceAvg,self.event.ticketPriceHigh,self.event.ticketPriceLow];
    
    [self adjustFontForDeviceSize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)getTicketsTapped:(id)sender {
    
    if ([self seatGeekInstalled]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"seatgeek://events/%@",self.event.eventID]]];
        
    } else {
        WebViewController *webVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"webViewController"];
        webVC.ticketURL = self.event.ticketURL;
        
        [self presentViewController:webVC animated:YES completion:^{}];
    }
}

- (BOOL) seatGeekInstalled {
    NSURL *url = [NSURL URLWithString:@"seatgeek://app"];
    return [[UIApplication sharedApplication] canOpenURL:url];
}

@end
