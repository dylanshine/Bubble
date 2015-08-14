#import "EventDetailsViewController.h"
#import "UILabel+AutoresizeFontMultiLine.h"
#import "WebViewController.h"
#import <Masonry/Masonry.h>
#import <Parse.h>


@interface EventDetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *eventTitle;
@property (weak, nonatomic) IBOutlet UILabel *eventStartTime;
@property (weak, nonatomic) IBOutlet UILabel *eventVenueName;
@property (weak, nonatomic) IBOutlet UILabel *eventAddress;
@property (weak, nonatomic) IBOutlet UILabel *eventTicketsTitle;
@property (weak, nonatomic) IBOutlet UILabel *eventTickets;
@end

@implementation EventDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeTranslucentBackground];
}

- (void)makeTranslucentBackground {
    
    UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    
    [self.view insertSubview:view atIndex:0];
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.left.equalTo(@0);
        make.top.equalTo(@0);
    }];
}

- (void)adjustFontSize {
    
    if (self.view.frame.size.width == 320) {
        
        [self.eventTitle adjustFontSizeToFitWithMaxSize:18];
        self.eventStartTime.font = [self.eventStartTime.font fontWithSize:12];
        self.eventAddress.font = [self.eventAddress.font fontWithSize:12];
        self.eventVenueName.font = [self.eventVenueName.font fontWithSize:self.eventTitle.font.pointSize];
        self.eventTicketsTitle.font = [self.eventTicketsTitle.font fontWithSize:self.eventTitle.font.pointSize];
        self.eventTickets.font = [self.eventTickets.font fontWithSize:12];
        
    } else if (self.view.frame.size.width == 375){
        
        [self.eventTitle adjustFontSizeToFitWithMaxSize:22];
        self.eventStartTime.font = [self.eventStartTime.font fontWithSize:14];
        self.eventAddress.font = [self.eventAddress.font fontWithSize:14];
        self.eventVenueName.font = [self.eventVenueName.font fontWithSize:self.eventTitle.font.pointSize];
        self.eventTicketsTitle.font = [self.eventTicketsTitle.font fontWithSize:self.eventTitle.font.pointSize];
        self.eventTickets.font = [self.eventTickets.font fontWithSize:14];
        
    } else {
        
        [self.eventTitle adjustFontSizeToFitWithMaxSize:26];
        self.eventStartTime.font = [self.eventStartTime.font fontWithSize:14];
        self.eventAddress.font = [self.eventAddress.font fontWithSize:16];
        self.eventVenueName.font = [self.eventVenueName.font fontWithSize:self.eventTitle.font.pointSize];
        self.eventTicketsTitle.font = [self.eventTicketsTitle.font fontWithSize:self.eventTitle.font.pointSize];
        self.eventTickets.font = [self.eventTickets.font fontWithSize:16];
    }
}

- (void)setEvent:(EventObject *)event{
    _event = event;
    [self updateEventLabels];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EventChanged" object:self];
}

- (void)updateEventLabels {
    self.eventTitle.text = self.event.eventTitle;
    
    self.eventStartTime.text = [NSString stringWithFormat:@"Start time: %@",self.event.eventTime];
    
    self.eventVenueName.text = self.event.venueName;
    
    self.eventAddress.text = [NSString stringWithFormat:@"%@\n%@, %@ %@",self.event.addressStreet,self.event.addressCity,self.event.addressState,self.event.addressZip];
    
    self.eventTickets.text = [NSString stringWithFormat:@"%@\n\n%@\n%@\n%@",self.event.ticketsAvailable,self.event.ticketPriceAvg,self.event.ticketPriceHigh,self.event.ticketPriceLow];
    
    if (self.eventTitle.text.length > 20) {
        self.eventTitle.numberOfLines = 2;
        self.eventTitle.minimumScaleFactor = 0.8;
        self.eventTitle.lineBreakMode = NSLineBreakByTruncatingTail;
        
    } else {
        self.eventTitle.numberOfLines = 1;
        self.eventTitle.minimumScaleFactor = .7;
        self.eventTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    
    [self adjustFontSize];
}


- (IBAction)getDirectionsTapped:(id)sender {
    
    if ([self googleMapsInstalled]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?saddr=%f,%f&daddr=%f,%f&directionsmode=driving",
                                                                         self.currentLocation.latitude,
                                                                         self.currentLocation.longitude,
                                                                         self.event.eventLocation.coordinate.latitude,
                                                                         self.event.eventLocation.coordinate.longitude]]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.apple.com/?saddr=%f,%f&daddr=%f,%f",
                                                                         self.currentLocation.latitude,
                                                                         self.currentLocation.longitude,
                                                                         self.event.eventLocation.coordinate.latitude,
                                                                         self.event.eventLocation.coordinate.longitude]]];
    }
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

- (BOOL) googleMapsInstalled {
    //    NSURL *url = [NSURL URLWithString:@"comgooglemaps://"];
    //    return [[UIApplication sharedApplication] canOpenURL:url];
    return NO;
}

@end
