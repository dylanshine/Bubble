#import "EventDetailsViewController.h"
#import "UILabel+AutoresizeFontMultiLine.h"
#import "WebViewController.h"
#import <Masonry/Masonry.h>
#import <Parse.h>


@interface EventDetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *eventTitle;
@property (weak, nonatomic) IBOutlet UILabel *eventStartTime;
@property (weak, nonatomic) IBOutlet UILabel *eventVenueInfo;
@property (weak, nonatomic) IBOutlet UILabel *eventInfo;

@end

@implementation EventDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeTranslucentBackground];
}

- (void)setEvent:(EventObject *)event{
    _event = event;
    [self updateEventLabels];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EventChanged" object:self];
}

- (void)updateEventLabels {
    
    [self formatEventName];
    
    self.eventStartTime.text = [NSString stringWithFormat:@"Start time: %@",self.event.eventTime];
    
    self.eventVenueInfo.attributedText = [self formatVenueInfo];
    
    self.eventInfo.attributedText = [self formatEventInfo];
}


- (void)formatEventName {
    
    self.eventTitle.text = self.event.eventTitle;
    
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
        [self.eventTitle adjustFontSizeToFitWithMaxSize:18];
        
    } else if (self.view.frame.size.width == 375){
        [self.eventTitle adjustFontSizeToFitWithMaxSize:22];
        
    } else {
        [self.eventTitle adjustFontSizeToFitWithMaxSize:26];
    }
}

- (NSAttributedString *) formatVenueInfo {
    
    UIFont *headerFont = [[UIFont alloc] init];
    UIFont *bodyFont = [[UIFont alloc] init];
    
    if (self.view.frame.size.width == 320) {
        headerFont = [UIFont fontWithName:@"Avenir-Heavy" size:fminf(16, self.eventTitle.font.pointSize)];
        bodyFont = [UIFont fontWithName:@"Avenir-Book" size:14];
    } else {
        headerFont = [UIFont fontWithName:@"Avenir-Heavy" size:fminf(20, self.eventTitle.font.pointSize)];
        bodyFont = [UIFont fontWithName:@"Avenir-Book" size:18];
    }
    
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:headerFont forKey:NSFontAttributeName];
    
    NSMutableAttributedString *venueInfo = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@\n%@, %@ %@",
                                                                                              self.event.venueName,
                                                                                              self.event.addressStreet,
                                                                                              self.event.addressCity,
                                                                                              self.event.addressState,
                                                                                              self.event.addressZip]
                                            
                                                                                  attributes:attrsDictionary];
    [venueInfo beginEditing];
    
    NSRange bodyRange = NSMakeRange(self.event.venueName.length, venueInfo.length - self.event.venueName.length);
    
    [venueInfo addAttribute:NSFontAttributeName
                      value:bodyFont
                      range:bodyRange];
    
    [venueInfo endEditing];
    
    return [venueInfo copy];
}

- (NSAttributedString *) formatEventInfo {
    
    UIFont *headerFont = [[UIFont alloc] init];
    UIFont *bodyFont = [[UIFont alloc] init];
    
    if (self.view.frame.size.width == 320) {
        headerFont = [UIFont fontWithName:@"Avenir-Heavy" size:fminf(16, self.eventTitle.font.pointSize)];
        bodyFont = [UIFont fontWithName:@"Avenir-Book" size:14];
    } else {
        headerFont = [UIFont fontWithName:@"Avenir-Heavy" size:fminf(20, self.eventTitle.font.pointSize)];
        bodyFont = [UIFont fontWithName:@"Avenir-Book" size:18];
    }
    
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:headerFont forKey:NSFontAttributeName];
    if([self.event.eventType isEqualToString:@"meetup"]){
        NSMutableAttributedString *ticketInfo = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Attendees\n%@\n%@\n%@",
                                                                                                   self.event.rsvpYes,
                                                                                                   self.event.rsvpMaybe,
                                                                                                   self.event.ticketPriceAvg]
                                                 
                                                                                       attributes:attrsDictionary];
        [ticketInfo beginEditing];
        
        NSRange bodyRange = NSMakeRange(9, ticketInfo.length - 9);
        
        [ticketInfo addAttribute:NSFontAttributeName
                           value:bodyFont
                           range:bodyRange];
        
        [ticketInfo endEditing];
        return [ticketInfo copy];
    }else{
        NSMutableAttributedString *ticketInfo = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Tickets\n%@\n%@\n%@\n%@",
                                                                                                   self.event.ticketsAvailable,
                                                                                                   self.event.ticketPriceAvg,
                                                                                                   self.event.ticketPriceHigh,
                                                                                                   self.event.ticketPriceLow]
                                                 
                                                                                       attributes:attrsDictionary];
        [ticketInfo beginEditing];
        
        NSRange bodyRange = NSMakeRange(7, ticketInfo.length - 7);
        
        [ticketInfo addAttribute:NSFontAttributeName
                           value:bodyFont
                           range:bodyRange];
        
        [ticketInfo endEditing];
        return [ticketInfo copy];
    }
    
    
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

- (void)makeTranslucentBackground {
    
    UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    
    [self.view insertSubview:view atIndex:0];
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.left.equalTo(@0);
        make.top.equalTo(@0);
    }];
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
