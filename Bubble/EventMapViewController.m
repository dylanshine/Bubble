//
//  ViewController.m
//  Bubble
//
//  Created by Lukas Thoms on 7/27/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "EventMapViewController.h"
#import <MapKit/MapKit.h>
#import <Masonry/Masonry.h>
#import "BBAnnotation.h"
#import "AFDataStore.h"
#import "EventObject.h"
#import "UISearchBar+EnableReturnKey.h"
#import <INTULocationManager.h>
#import "EventDetailsViewController.h"
#import "BBAnnotation.h"
#import "XMPPManager.h"
#import "BBChatViewController.h"
#import "LoginViewController.h"
#import <SVProgressHUD.h>
#import <IGLDropDownMenu.h>
#import "BBSearchViewPassThrough.h"

@interface EventMapViewController () <MKMapViewDelegate, AFDataStoreDelegate, UIScrollViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate, IGLDropDownMenuDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *eventDetailContainer;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIImageView *eventImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *eventImageTopConstraint;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *scrollViewTapRecognizer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarXConstraint;
@property (weak, nonatomic) IBOutlet BBSearchViewPassThrough *searchContainer;

@property (weak, nonatomic) IBOutlet UIButton *dateSelectorButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSelectorConstraint;
@property (weak, nonatomic) IBOutlet UIButton *nextDayButton;
@property (weak, nonatomic) IBOutlet UIButton *previousDayButton;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *datePickerCenterConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *datePickerXConstraint;
@property (strong, nonatomic) UIView *pickerBackground;
@property (strong, nonatomic) NSDate *date;

@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IGLDropDownMenu *menu;
@property (strong, nonatomic) NSMutableArray *menuItems;

@property (nonatomic, strong) EventDetailsViewController *eventDetailsVC;
@property (nonatomic, strong) NSArray *eventsArray;

@property (nonatomic) AFDataStore *dataStore;
@property (nonatomic) XMPPManager *xmppManager;

@property (nonatomic) CLLocation *currentLocation;
@property (assign, nonatomic) INTULocationRequestID locationRequestID;
@property (nonatomic) BOOL loaded;
@property (nonatomic) BBAnnotation *selectedAnnotation;

@property (nonatomic, assign) CGFloat scrollViewStartingPosition;
@property (nonatomic, assign) CGFloat scrollViewDetailedPosition;


- (void) plotEvents;
- (void) moveMapToClosestAnnotation;

@end

@implementation EventMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataStore = [AFDataStore sharedData];
    self.dataStore.delegate = self;
    
    self.xmppManager = [XMPPManager sharedManager];
    
    self.mapView.delegate = self;
    
    self.date = [NSDate date];
    [self setupDateSelector];
    
    [self setupMenuScrollView];
    [self setupSearchBar];
    
    [self startLocationUpdateSubscription];
    
    [self menuSetup];
    
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDragMap:)];
    [panRecognizer setDelegate:self];
    [self.mapView addGestureRecognizer:panRecognizer];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    if (velocity.y >= 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.4 animations:^{
                [scrollView setContentOffset:CGPointMake(0, self.scrollViewDetailedPosition) animated:NO];
                
                self.eventImageTopConstraint.constant = 0;
                [self.eventImage layoutIfNeeded];
            }];
        });
        
    } else if (velocity.y < 0) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.4 animations:^{
                [scrollView setContentOffset:CGPointMake(0, self.scrollViewStartingPosition * -1) animated:NO];
                self.eventImageTopConstraint.constant = self.eventImage.frame.size.height + 500;
                [self.eventImage layoutIfNeeded];
            }];
        });
    }
}


- (void) toggleScrollViewLocation {
    
    if (self.scrollView.contentOffset.y != self.scrollViewDetailedPosition) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.4 animations:^{
                [self.scrollView setContentOffset:CGPointMake(0, self.scrollViewDetailedPosition) animated:NO];
                
                self.eventImageTopConstraint.constant = 0;
                [self.eventImage layoutIfNeeded];
            }];
        });
        
    } else {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.4 animations:^{
                [self.scrollView setContentOffset:CGPointMake(0, self.scrollViewStartingPosition * -1) animated:NO];
                
                self.eventImageTopConstraint.constant = self.eventImage.frame.size.height + 500;
                [self.eventImage layoutIfNeeded];
            }];
        });
    }
}

- (void)startLocationUpdateSubscription {
    __weak __typeof(self) weakSelf = self;
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    self.locationRequestID = [locMgr subscribeToLocationUpdatesWithBlock:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        __typeof(weakSelf) strongSelf = weakSelf;
        
        if (status == INTULocationStatusSuccess) {
            strongSelf.currentLocation = currentLocation;
            if (!strongSelf.loaded) {
                strongSelf.loaded = YES;
                [strongSelf.dataStore getSeatgeekEventsWithLocation:strongSelf.currentLocation];
                [strongSelf.dataStore getMeetupEventsWithLocation:strongSelf.currentLocation date:[NSDate date]];
                [strongSelf.mapView setRegion:MKCoordinateRegionMake(strongSelf.currentLocation.coordinate, MKCoordinateSpanMake(.1, .1)) animated:NO];
            }
        }
        else {
            strongSelf.locationRequestID = NSNotFound;
        }
    }];

}

- (void)dataStore:(AFDataStore *)datastore didLoadEvents:(NSArray *)eventsArray{
    
    self.eventsArray = eventsArray;
    if ([self.eventsArray isEqual:@[]]) {
        [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
            [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
                self.searchBar.barStyle = UIBarStyleBlack;
            }];
            [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
                self.searchBar.barTintColor = [UIColor whiteColor];
            }];
        } completion:^(BOOL finished) { }];
    }

}

- (void)setEventsArray:(NSArray *)eventsArray{
    
    _eventsArray = eventsArray;
    
    [self plotEvents];
}

- (void) plotEvents {
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    for (EventObject *event in self.eventsArray) {
        
        BBAnnotation *annotation = [[BBAnnotation alloc] init];
        
        annotation.coordinate = event.coordinate;
        annotation.event = event;
        annotation.title = event.eventTitle;
        annotation.eventImageName = [annotation getEventImageName:annotation.event];
        
        [self.mapView addAnnotation:annotation];
    }
    [SVProgressHUD dismiss];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    BBAnnotation *annotation = view.annotation;
    
    self.eventDetailsVC.event = annotation.event;
    self.eventImage.image = annotation.event.eventImage;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    static NSString *const eventAnnotationReuseID = @"eventAnnotation";
    
    MKAnnotationView *annotationView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:eventAnnotationReuseID];
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    //annotationView = nil;  //annotations are reused and the below code is never entered to change the event type image.  Need to clear annotations or change bellow code
    
    if (!annotationView) {
        
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:eventAnnotationReuseID];
        
        annotationView.canShowCallout = YES;
        annotationView.highlighted = YES;
        
        BBAnnotation *eventAnnotation = annotation;
        annotationView.image = [UIImage imageNamed:[eventAnnotation getEventImageName:eventAnnotation.event]];
        annotationView.frame = CGRectMake(0,0,30,30);

        UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        detailButton.frame = CGRectMake(0,0,30,30);
        [detailButton setImage:[UIImage imageNamed:@"Bubble-White"] forState:UIControlStateNormal];
        detailButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        detailButton.enabled = YES;
        [detailButton setTitle:annotation.title forState:UIControlStateNormal];
        
        NSArray *imageArray = @[
                                [UIImage imageNamed:@"Bubble-White"],
                                [UIImage imageNamed:@"Bubble-Blue"],
                                [UIImage imageNamed:@"Bubble-Orange"],
                                [UIImage imageNamed:@"Bubble-Purple"],
                                [UIImage imageNamed:@"Bubble-Yellow"],
                                ];
        
        [detailButton.imageView setAnimationImages:imageArray];
        [detailButton.imageView setAnimationDuration:3];
        [detailButton.imageView startAnimating];
        
        annotationView.rightCalloutAccessoryView = detailButton;
        
    } else {
        annotationView.annotation = annotation;
        BBAnnotation *eventAnnotation = annotation;
        annotationView.image = [UIImage imageNamed:[eventAnnotation getEventImageName:eventAnnotation.event]];
        annotationView.frame = CGRectMake(0,0,30,30);
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    self.selectedAnnotation = (BBAnnotation *)view.annotation;
    [self performSegueWithIdentifier:@"chatSegue" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"chatSegue"]) {
        UINavigationController *destination = [segue destinationViewController];
        BBChatViewController *chatVC = destination.viewControllers.firstObject;
        chatVC.eventTitle = self.selectedAnnotation.event.eventTitle;
        chatVC.roomID = self.selectedAnnotation.event.eventID; //stringValue];  //meet up event crash here, event id is already a string
        chatVC.eventLocation = self.selectedAnnotation.event.eventLocation;
        chatVC.currentUserLocation = self.currentLocation;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (self.mapView.annotations.count > 1){
        [self moveMapToClosestAnnotation];
    }
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if ([self.mapView.selectedAnnotations[0] isMemberOfClass:[MKUserLocation class]]) {
        [self.mapView deselectAnnotation:self.mapView.selectedAnnotations[0] animated:YES];
    }
    [self.dataStore searchEvents:searchBar.text withScope:searchBar.selectedScopeButtonIndex];
    if(self.mapView.annotations.count == 1){
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"No matches found"
                                              message:@"Please try again!"
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                   }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    if(self.searchBar.text.length > 0){
        [self searchBar:searchBar textDidChange:self.searchBar.text];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsScopeBar = YES;
    
    [UIView animateWithDuration:.25 animations:^{
        self.searchBar.alpha = 1;
        
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    MKUserLocation *annotation = [[MKUserLocation alloc] init];
    if ([self.mapView.selectedAnnotations[0] isMemberOfClass:[MKUserLocation class]]) {
        annotation = self.mapView.selectedAnnotations[0];
    }
    for (UIView * txt in self.view.subviews){
        if ([txt isKindOfClass:[UISearchBar class]] && [txt isFirstResponder]) {
            [self.searchBar resignFirstResponder];
            self.searchBar.showsScopeBar = NO;
            [UIView animateWithDuration:.25 animations:^{
                self.searchBar.alpha = 0.9;
                
            }];
        }
    }
    annotation.title = @"Current Location";
}

- (void) moveMapToClosestAnnotation {
    
    MKPointAnnotation *closestAnnotation = self.mapView.annotations.firstObject;
    if ([closestAnnotation isMemberOfClass:[MKUserLocation class]]) {
        closestAnnotation = self.mapView.annotations.lastObject;
    }
    
    for (MKPointAnnotation *annotation in self.mapView.annotations) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
        CLLocation *closestLocation = [[CLLocation alloc] initWithLatitude:closestAnnotation.coordinate.latitude
                                                                 longitude:closestAnnotation.coordinate.longitude];
        if ([self.currentLocation distanceFromLocation:location] < [self.currentLocation distanceFromLocation:closestLocation] && ![annotation isMemberOfClass:[MKUserLocation class]]) {
            closestAnnotation = annotation;
        }
    }
    if ([closestAnnotation isMemberOfClass:[MKUserLocation class]]) {
        closestAnnotation.title = @"😱 No Events Found 😱";
    }
    [self.mapView selectAnnotation:closestAnnotation animated:YES];
    [self.mapView setRegion:MKCoordinateRegionMake(closestAnnotation.coordinate, MKCoordinateSpanMake(.075, .075)) animated:YES];
}

-(void)setupSearchBar {
    self.searchBar.delegate = self;
    self.searchBar.backgroundColor = [UIColor whiteColor];
    self.searchBar.layer.cornerRadius = 10;
    self.searchBar.clipsToBounds = YES;
    self.searchBar.alpha = .9;
    self.searchBar.returnKeyType = UIReturnKeyGo;
    [self.searchBar alwaysEnableReturn];
}

-(void)setupMenuScrollView {
    self.scrollView.delegate = self;
    self.scrollViewStartingPosition = self.view.frame.size.height - 80;
    
    if (self.view.frame.size.width == 320) {
        self.scrollViewDetailedPosition = -self.eventImage.frame.size.height + 62;
        
    } else if (self.view.frame.size.width == 375){
        self.scrollViewDetailedPosition = -self.eventImage.frame.size.height + 22;
        
    } else {
        self.scrollViewDetailedPosition = -self.eventImage.frame.size.height - 8;
    }
    
    self.scrollView.pagingEnabled = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.alwaysBounceHorizontal = NO;
    self.scrollView.contentInset = UIEdgeInsetsMake(self.scrollViewStartingPosition,0, 0, 0);
    self.eventDetailsVC = self.childViewControllers[0];
    [self.scrollViewTapRecognizer addTarget:self action:@selector(toggleScrollViewLocation)];
}

#pragma mark date-search

-(void) setupDateSelector {
    self.dateSelectorButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.dateSelectorButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setDateSelectorTitle];
    self.dateSelectorButton.alpha = 0.9;
    self.dateSelectorButton.layer.cornerRadius = 10;
    self.dateSelectorButton.backgroundColor = [UIColor whiteColor];
    self.previousDayButton.layer.cornerRadius = 10;
    self.previousDayButton.backgroundColor = [UIColor whiteColor];
    self.nextDayButton.layer.cornerRadius = 10;
    self.nextDayButton.backgroundColor = [UIColor whiteColor];
    self.datePicker.alpha = 0;
    self.datePicker.minimumDate = [NSDate date];
    self.datePickerCenterConstraint.constant = -400;
    self.pickerBackground.userInteractionEnabled = NO;
    UIView *datePickerBackground = [[UIView alloc] init];
    datePickerBackground.backgroundColor = [UIColor whiteColor];
    datePickerBackground.alpha = 0.0;
    [self.mapView addSubview:datePickerBackground];
    [datePickerBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width);
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.searchBar.mas_bottom).with.offset(6);
        make.height.equalTo(@36);
    }];
    self.pickerBackground = datePickerBackground;
    
}

-(void) setDateSelectorTitle {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"EEE MMM dd";
    NSString *dateString = [formatter stringFromDate:self.date];
    if ([dateString isEqual:[formatter stringFromDate:[NSDate date]]]) {
        [self.dateSelectorButton setTitle:@"Today" forState:UIControlStateNormal];
    } else if ([dateString isEqual:[formatter stringFromDate:[NSDate dateWithTimeInterval:60*60*24 sinceDate:[NSDate date]]]]) {
        [self.dateSelectorButton setTitle:@"Tomorrow" forState:UIControlStateNormal];
    } else {
        [self.dateSelectorButton setTitle:[formatter stringFromDate:self.date] forState:UIControlStateNormal];
    }
}

- (IBAction)previousDayTapped:(id)sender {
    self.date = [self.date dateByAddingTimeInterval:-(60*60*24)];
    [SVProgressHUD show];
    [self.dataStore getSeatgeekEventsWithLocation:self.currentLocation date:self.date];
    [self.dataStore getMeetupEventsWithLocation:self.currentLocation date:self.date];
    [self setDateSelectorTitle];
    
}

- (IBAction)nextDayTapped:(id)sender {
    self.date = [self.date dateByAddingTimeInterval:(60*60*24)];
    [SVProgressHUD show];
    [self.dataStore getSeatgeekEventsWithLocation:self.currentLocation date:self.date];
    [self.dataStore getMeetupEventsWithLocation:self.currentLocation date:self.date];
    [self setDateSelectorTitle];
}

- (IBAction)dateSelectorTapped:(id)sender {

    if ([self.dateSelectorButton.titleLabel.text isEqual:@"Set Date"]) {
        [SVProgressHUD show];
        
        if (![self.date isEqual:self.datePicker.date]) {
            self.date = self.datePicker.date;
            [self.dataStore getSeatgeekEventsWithLocation:[self mapCenter] date:self.date];
            [self.dataStore getMeetupEventsWithLocation:[self mapCenter] date:self.date];
        }
        [self setDateSelectorTitle];
        [UIView animateWithDuration:0.5 animations:^{
            self.previousDayButton.alpha = 0.9;
            self.nextDayButton.alpha = 0.9;
            self.dateSelectorButton.alpha = 0.9;
            self.datePicker.alpha = 0;
            self.datePickerCenterConstraint.constant = -400;
            self.pickerBackground.alpha = 0;
            self.dateSelectorConstraint.constant = 52;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) { }];
        
    } else {
        self.datePicker.date = self.date;
        [self.dateSelectorButton setTitle:@"Set Date" forState:UIControlStateNormal];
        [UIView animateWithDuration:0.5 animations:^{
            self.previousDayButton.alpha = 0.0;
            self.nextDayButton.alpha = 0.0;
            self.datePicker.alpha = 1;
            self.dateSelectorButton.alpha = 1;
            self.pickerBackground.alpha = 0.95;
            self.datePickerCenterConstraint.constant = 0;
            self.dateSelectorConstraint.constant = 174;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)didDragMap:(UIGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        MKMapRect visibleRect = self.mapView.visibleMapRect;
        NSSet *visibleAnnotations = [self.mapView annotationsInMapRect:visibleRect];
        if (visibleAnnotations.count < 2) {
            NSLog(@"Making Seatgeek Call");
            [self.dataStore getSeatgeekEventsWithLocation:[self mapCenter] date:self.date];
        }
        
    }
}

-(CLLocation *)mapCenter {
    CLLocation *center = [[CLLocation alloc] initWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
    return center;
}

-(void) menuSetup {
    self.menuItems = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i<4; i++) {
        IGLDropDownItem *preferences = [[IGLDropDownItem alloc] init];
        [preferences setText:@"Menu Item"];
        [self.menuItems addObject:preferences];
    }

    self.menu = [[IGLDropDownMenu alloc] init];
    [self.menu setFrame:CGRectMake(self.searchContainer.frame.origin.x-200, self.menuButton.frame.origin.y, 200, self.searchBar.frame.size.height)];
    self.menu.menuText = @"Dismiss";
    self.menu.type = IGLDropDownMenuTypeSlidingInFromLeft;
    self.menu.useSpringAnimation = NO;
    self.menu.dropDownItems = self.menuItems;
    self.menu.gutterY = 5;
    self.menu.paddingLeft = 15;
    self.menu.slidingInOffset = 0;
    self.menu.delegate = self;
    [self.menu.menuButton addTarget:self action:@selector(dismissMenu) forControlEvents:UIControlEventTouchUpInside];
//    self.menu.menuIconImage = [UIImage imageNamed:@"menu.png"];
    [self.menu reloadView];
    [self.searchContainer addSubview:self.menu];
    
}

- (IBAction)menuButtonTapped:(id)sender {
    
    [UIView animateWithDuration:.6 animations:^{
        [self.menu setFrame:CGRectMake(self.searchContainer.frame.origin.x, self.menuButton.frame.origin.y, 200, self.searchBar.frame.size.height)];
        self.datePickerXConstraint.constant = -400;
        self.searchBarXConstraint.constant = -400;
        [self.view layoutIfNeeded];
    }];
    self.menu.expanding = YES;
//    [self.menu toggleView];
}

- (void)dropDownMenu:(IGLDropDownMenu *)dropDownMenu selectedItemAtIndex:(NSInteger)index {
    
    [self dismissMenu];
//    IGLDropDownItem *item = dropDownMenu.dropDownItems[index];
}

-(void) dismissMenu {
    [UIView animateWithDuration:.6 animations:^{
        [self.menu setFrame:CGRectMake(self.searchContainer.frame.origin.x-200, self.menuButton.frame.origin.y, 200, self.searchBar.frame.size.height)];
        self.datePickerXConstraint.constant = 0;
        self.searchBarXConstraint.constant = -20;
        [self.view layoutIfNeeded];
    }];
    self.menu.menuText = @"Dismiss";
}


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

@end
