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
#import "ChatDataManager.h"
#import "BBChatViewController.h"
#import "LoginViewController.h"
#import <SVProgressHUD.h>
#import <IGLDropDownMenu.h>
#import "BBSearchViewPassThrough.h"
#import "ILTranslucentView.h"
#import <Parse.h>
#import "CoreDataStack.h"
#import "SubscribedEvent.h"
#import "BBDropDownItem.h"
#import "MKMapView+ZoomLevel.h"

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
@property (weak, nonatomic) IBOutlet UIButton *chatBubbleButton;
@property (weak, nonatomic) IBOutlet UILabel *numberParticipantsLabel;
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
@property (nonatomic, getter=isMenuOpen) BOOL menuOpen;
@property (weak, nonatomic) IBOutlet UIButton *chatBubbleBookmarkButton;
@property (nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) EventDetailsViewController *eventDetailsVC;
@property (strong, nonatomic) NSArray *eventsArray;
@property (strong, nonatomic) AFDataStore *dataStore;
@property (strong, nonatomic) XMPPManager *xmppManager;
@property (strong, nonatomic) ChatDataManager *chatManager;
@property (strong, nonatomic) CoreDataStack *coreDataStack;
@property (assign, nonatomic) INTULocationRequestID locationRequestID;
@property (assign, nonatomic) BOOL loaded;
@property (strong, nonatomic) BBAnnotation *selectedAnnotation;
@property (assign, nonatomic) CGFloat scrollViewStartingPosition;
@property (assign, nonatomic) CGFloat scrollViewMiniViewPosition;
@property (assign, nonatomic) CGFloat scrollViewDetailedPosition;
@property (nonatomic, assign) BOOL annotationSelected;
@end

@implementation EventMapViewController

#pragma mark - View Controller Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataStore = [AFDataStore sharedData];
    self.dataStore.delegate = self;
    
    self.xmppManager = [XMPPManager sharedManager];
    self.chatManager = [ChatDataManager sharedManager];
    self.coreDataStack = [CoreDataStack sharedStack];
    
    self.mapView.delegate = self;
    
    self.date = [NSDate date];
    [self setupDateSelector];
    
    [self setupTray];
    [self setupSearchBar];
    [self translucentHeaderSetup];
    [self startLocationUpdateSubscription];
    [self mapSetup];
    [self menuSetup];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDragMap:)];
    [panRecognizer setDelegate:self];
    [self.mapView addGestureRecognizer:panRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventDetailChanged)
                                                 name:@"EventChanged"
                                               object:nil];
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(didPinchMap:)];
    [pinchRecognizer setDelegate:self];
    [self.mapView addGestureRecognizer:pinchRecognizer];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Location Manager & Events

- (void)startLocationUpdateSubscription {
    __weak __typeof(self) weakSelf = self;
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    self.locationRequestID = [locMgr subscribeToLocationUpdatesWithBlock:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        __typeof(weakSelf) strongSelf = weakSelf;
        
        if (status == INTULocationStatusSuccess) {
            strongSelf.currentLocation = currentLocation;
            strongSelf.eventDetailsVC.currentLocation = currentLocation.coordinate;
            
            if (!strongSelf.loaded) {
                strongSelf.loaded = YES;
                
                [strongSelf.dataStore getAllEventsWithLocation:strongSelf.currentLocation date:[NSDate date]];
                
                [strongSelf.mapView setRegion:MKCoordinateRegionMake(strongSelf.currentLocation.coordinate, MKCoordinateSpanMake(.1, .1)) animated:NO];
                [self mapSetup];
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
        [self changeSearchBarWithColor:[UIColor redColor]];
            }
    else{
        [self changeSearchBarWithColor:[UIColor grayColor]];
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
        annotation.eventScore = event.eventScore;
        
        [self.mapView addAnnotation:annotation];
    }
    [SVProgressHUD dismiss];
}

#pragma mark - Prepare for segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"chatSegue"]) {
        UINavigationController *destination = [segue destinationViewController];
        BBChatViewController *chatVC = destination.viewControllers.firstObject;
        chatVC.eventTitle = self.eventDetailsVC.event.eventTitle;
        chatVC.roomID = self.eventDetailsVC.event.eventID;
        if (![chatVC.roomID isEqualToString:self.xmppManager.currentRoomId]) {
            [self.chatManager.messages removeAllObjects];
        }
        chatVC.eventLocation = self.selectedAnnotation.event.eventLocation;
        chatVC.currentUserLocation = self.currentLocation;
    }
}

#pragma mark - Search Bar

- (void)setupSearchBar {
    self.searchBar.delegate = self;
    self.searchBar.backgroundColor = [UIColor clearColor];
    self.searchBar.layer.cornerRadius = 10;
    self.searchBar.clipsToBounds = YES;
    self.searchBar.alpha = .9;
    self.searchBar.returnKeyType = UIReturnKeyGo;
    [self.searchBar alwaysEnableReturn];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (self.mapView.annotations.count > 1){
        [self moveMapToClosestAnnotation];
    }
    [self.view endEditing:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if ([self.mapView.selectedAnnotations[0] isMemberOfClass:[MKUserLocation class]]) {
        [self.mapView deselectAnnotation:self.mapView.selectedAnnotations[0] animated:YES];
    }
    [self.dataStore searchEvents:searchBar.text withScope:searchBar.selectedScopeButtonIndex];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsScopeBar = YES;
    
    [UIView animateWithDuration:.25 animations:^{
        self.searchBar.alpha = 1;
        
    }];
}

- (void)changeSearchBarWithColor:(UIColor*)color{
    [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
            self.searchBar.tintColor = color;
            
            for (UIView *subView in self.searchBar.subviews)
            {
                for (UIView *secondLevelSubview in subView.subviews){
                    if ([secondLevelSubview isKindOfClass:[UITextField class]])
                    {
                        UITextField *searchBarTextField = (UITextField *)secondLevelSubview;
                        searchBarTextField.textColor = color;
                    }
                }
            }
        }];
    } completion:^(BOOL finished) { }];
}

#pragma mark - Map

- (void) mapSetup {
    MKMapCamera *mapCamera = [MKMapCamera cameraLookingAtCenterCoordinate:self.mapView.centerCoordinate fromEyeCoordinate:self.mapView.centerCoordinate eyeAltitude:9500];
    mapCamera.heading = 28.25;
    [self.mapView setCamera:mapCamera animated:NO];
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
            [self.dataStore getAllEventsWithLocation:[self mapCenter] date:self.date];
        }
        
    }
}
-(void)didPinchMap:(UIGestureRecognizer*)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
//        NSLog(@"%d", [self.mapView currentZoomLevel]);
        double newAnnotationSize = [self.mapView currentZoomLevel] * 2;
        double sizeMultiplier;
        if (newAnnotationSize/2 > 13){
            newAnnotationSize = newAnnotationSize * 1.25;
        }
        else if(newAnnotationSize/2 < 13){
            newAnnotationSize = newAnnotationSize * 0.7;
        }
        
        for (id <MKAnnotation>annotation in self.mapView.annotations) {
            
            if ([annotation isKindOfClass:[MKUserLocation class]])
                continue;
            if ([annotation isKindOfClass:[BBAnnotation class]])
            {
                BBAnnotation * annon = annotation;
                if ([annon.eventScore doubleValue] > 100){
                    sizeMultiplier = 1.25;
                }
                else if ([annon.eventScore doubleValue] < 1 && [annon.eventScore doubleValue] > 0.65){
                    sizeMultiplier = 1.25;
                }
                else{
                    sizeMultiplier = 1;
                }
                MKAnnotationView *pinView = [self.mapView viewForAnnotation:annotation];
                pinView.frame = CGRectMake(0,0,newAnnotationSize * sizeMultiplier,newAnnotationSize * sizeMultiplier);
            }
        }
    }
}

- (CLLocation *)mapCenter {
    CLLocation *center = [[CLLocation alloc] initWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
    return center;
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
    
    [self.view endEditing:YES];
}

- (void)moveMapToClosestAnnotation {
    
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

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    BBAnnotation *annotation = view.annotation;
    if (![self.mapView.selectedAnnotations[0] isMemberOfClass:[MKUserLocation class]]) {
        self.scrollView.scrollEnabled = YES;
        self.selectedAnnotation = annotation;
        self.eventDetailsVC.event = annotation.event;
        self.eventDetailsVC.currentLocation = self.currentLocation.coordinate;
        self.eventImage.image = annotation.event.eventImage;
        
        [self fetchChatParticipantCount];
        
        if (![annotation.event isToday]) {
            [self.chatBubbleButton setImage:[UIImage imageNamed:@"bookmark.png"] forState:UIControlStateNormal];
        } else {
            [self.chatBubbleButton setImage:[UIImage imageNamed:@"Blue-Bubble"] forState:UIControlStateNormal];
        }
        if (self.chatBubbleButton.alpha == 0) {
            [UIView animateWithDuration:.5
                             animations:^{
                                 self.chatBubbleButton.alpha = 1;
                             }];
        }
    }
    [self.mapView setCenterCoordinate:annotation.coordinate animated:YES];
    [self showDetailedVC];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    [self hideDetailedVC];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    static NSString *const eventAnnotationReuseID = @"eventAnnotation";
    
    MKAnnotationView *annotationView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:eventAnnotationReuseID];
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    double mapZoomLevel = [self.mapView currentZoomLevel] * 2;
    double sizeMultiplier = 1.25;
    
    if (!annotationView) {
        
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:eventAnnotationReuseID];
        annotationView.canShowCallout = YES;
        annotationView.highlighted = YES;
        
        BBAnnotation *eventAnnotation = annotation;
        annotationView.image = [UIImage imageNamed:[eventAnnotation getEventImageName:eventAnnotation.event]];
        if ([eventAnnotation.eventScore doubleValue] > 100){
            annotationView.frame = CGRectMake(0,0,mapZoomLevel * sizeMultiplier, mapZoomLevel * sizeMultiplier);
        }
        else if ([eventAnnotation.eventScore doubleValue] < 1 && [eventAnnotation.eventScore doubleValue] > 0.65){
            annotationView.frame = CGRectMake(0,0,mapZoomLevel * sizeMultiplier, mapZoomLevel * sizeMultiplier);
        }
        else{
            annotationView.frame = CGRectMake(0,0,mapZoomLevel, mapZoomLevel);
        }
        
    } else {
        annotationView.annotation = annotation;
        BBAnnotation *eventAnnotation = annotation;
        annotationView.image = [UIImage imageNamed:[eventAnnotation getEventImageName:eventAnnotation.event]];
        annotationView.frame = CGRectMake(0,0,30,30);
    }
    
    return annotationView;
}

#pragma mark Date Search

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
    [self.dataStore getAllEventsWithLocation:self.currentLocation date:self.date];
    [self setDateSelectorTitle];
    
}

- (IBAction)nextDayTapped:(id)sender {
    self.date = [self.date dateByAddingTimeInterval:(60*60*24)];
    [SVProgressHUD show];
    [self.dataStore getAllEventsWithLocation:self.currentLocation date:self.date];
    [self setDateSelectorTitle];
}

- (IBAction)dateSelectorTapped:(id)sender {
    
    if ([self.dateSelectorButton.titleLabel.text isEqual:@"Set Date"]) {
        
        if (![self.date isEqual:self.datePicker.date]) {
            self.date = self.datePicker.date;
            [SVProgressHUD show];
            [self.dataStore getAllEventsWithLocation:[self mapCenter] date:self.date];
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

#pragma mark - Subscription Menu

-(void) menuSetup {
    self.menu = [[IGLDropDownMenu alloc] init];
    [self fetchSubscribedEvents];
    [self.menu setFrame:CGRectMake(self.searchContainer.frame.origin.x-300, self.menuButton.frame.origin.y + self.menuButton.frame.size.height + 10, 300, self.searchBar.frame.size.height)];
    self.menu.menuText = @"  Bookmarked Events";
    self.menu.type = IGLDropDownMenuTypeSlidingInFromLeft;
    self.menu.useSpringAnimation = NO;
    self.menu.gutterY = 5;
    self.menu.slidingInOffset = 0;
    self.menu.delegate = self;
    [self.menu.menuButton addTarget:self action:@selector(dismissMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.menu reloadView];
    [self.searchContainer addSubview:self.menu];
    self.menuOpen = NO;
    
}

- (void) translucentHeaderSetup {
    
    ILTranslucentView *translucentView = [[ILTranslucentView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, 50)];
    
    translucentView.translucentAlpha = 1;
    translucentView.translucentStyle = UIStatusBarStyleDefault;
    
    [self.view insertSubview:translucentView aboveSubview:self.mapView];
    
    [translucentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.left.equalTo(@0);
        make.height.equalTo(@65);
    }];
}

- (IBAction)menuButtonTapped:(id)sender {
    if (self.isMenuOpen) {
        [self dismissMenu];
    } else {
        [self openMenu];
    }
}

- (void)dropDownMenu:(IGLDropDownMenu *)dropDownMenu selectedItemAtIndex:(NSInteger)index {
    
    [self dismissMenu];
    BBDropDownItem *item = dropDownMenu.dropDownItems[index];
    self.eventDetailsVC.event = [[EventObject alloc] initWithSubscribedEvent:item.event];
    [self eventDetailChanged];
    if (self.chatBubbleButton.alpha == 0) {
        [UIView animateWithDuration:.5
                         animations:^{
                             self.chatBubbleButton.alpha = 1;
                         }];
    }
    [self toggleScrollViewLocation];
}

-(void) dismissMenu {
    [UIView animateWithDuration:.6 animations:^{
        [self.menu setFrame:CGRectMake(self.searchContainer.frame.origin.x-300, self.menuButton.frame.origin.y + self.menuButton.frame.size.height + 10, 200, self.searchBar.frame.size.height)];
        self.datePickerXConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
    self.menu.menuText = @"  Bookmarked Events";
    self.menuOpen = NO;
}

-(void) openMenu {
    [UIView animateWithDuration:.6 animations:^{
        [self.menu setFrame:CGRectMake(self.searchContainer.frame.origin.x, self.menuButton.frame.origin.y + self.menuButton.frame.size.height + 10, 300, self.searchBar.frame.size.height)];
        self.datePickerXConstraint.constant = -400;
        [self.view layoutIfNeeded];
    }];
    
    self.menu.expanding = YES;
    self.menuOpen = YES;
}

- (IBAction)chatBubbleTapped:(id)sender {
    
    BOOL match = NO;
    for (BBDropDownItem *item in self.menu.dropDownItems) {
        if ([item.event.eventID isEqual:self.eventDetailsVC.event.eventID]) {
            match = YES;
        }
    }
    if (match == NO) {
        [self createSubscriptionToEvent:self.eventDetailsVC.event];
    }
    
    if ([self.eventDetailsVC.event isToday]) {
        [self performSegueWithIdentifier:@"chatSegue" sender:self];
    } else if (match == YES) {
        [self removeSubscriptionToEvent:self.eventDetailsVC.event];
    }
    
}

#pragma mark - Tray

- (void)setupTray {
    self.scrollView.delegate = self;
    
    self.scrollViewStartingPosition = self.view.frame.size.height + 50;
    self.scrollViewMiniViewPosition = self.view.frame.size.height - 120;
    
    if (self.view.frame.size.width == 320) {
        self.scrollViewDetailedPosition = -self.eventImage.frame.size.height + 62;
        
    } else if (self.view.frame.size.width == 375){
        self.scrollViewDetailedPosition = -self.eventImage.frame.size.height + 22;
        
    } else {
        self.scrollViewDetailedPosition = -self.eventImage.frame.size.height - 8;
    }
    
    self.scrollView.scrollEnabled = NO;
    self.scrollView.pagingEnabled = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.alwaysBounceHorizontal = NO;
    self.scrollView.contentInset = UIEdgeInsetsMake(self.scrollViewStartingPosition,0, 0, 0);
    self.eventDetailsVC = self.childViewControllers[0];
    [self.scrollViewTapRecognizer addTarget:self action:@selector(toggleScrollViewLocation)];
    
    self.chatBubbleButton.alpha = 0;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    if (velocity.y >= 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.3 animations:^{
                [scrollView setContentOffset:CGPointMake(0, self.scrollViewDetailedPosition) animated:NO];
                
                self.eventImageTopConstraint.constant = 0;
                [self.eventImage layoutIfNeeded];
            }];
        });
        
    } else {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.3 animations:^{
                [scrollView setContentOffset:CGPointMake(0, self.scrollViewMiniViewPosition * -1) animated:NO];
                self.eventImageTopConstraint.constant = self.eventImage.frame.size.height + 500;
                [self.eventImage layoutIfNeeded];
            }];
        });
    }
}

- (void) toggleScrollViewLocation {
    
    if (self.scrollView.contentOffset.y != self.scrollViewDetailedPosition) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.3 animations:^{
                [self.scrollView setContentOffset:CGPointMake(0, self.scrollViewDetailedPosition) animated:NO];
                
                self.eventImageTopConstraint.constant = 0;
                [self.eventImage layoutIfNeeded];
            }];
        });
        
    } else {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.3 animations:^{
                [self.scrollView setContentOffset:CGPointMake(0, self.scrollViewMiniViewPosition * -1) animated:NO];
                
                self.eventImageTopConstraint.constant = self.eventImage.frame.size.height + 500;
                [self.eventImage layoutIfNeeded];
            }];
        });
    }
}

- (void) showDetailedVC {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:.25 animations:^{
            [self.scrollView setContentOffset:CGPointMake(0, self.scrollViewMiniViewPosition * -1) animated:NO];
            
        }];
    });
}

- (void) hideDetailedVC {
    
    if (self.scrollView.contentOffset.y != self.scrollViewStartingPosition * -1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.25 animations:^{
                [self.scrollView setContentOffset:CGPointMake(0, self.scrollViewStartingPosition * -1) animated:NO];
                
            }];
        });
    }
}

- (void) fetchChatParticipantCount {
    
    if (self.selectedAnnotation.event.eventID) {
        PFQuery *query = [PFUser query];
        [query whereKey:@"eventID" equalTo:self.selectedAnnotation.event.eventID];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.numberParticipantsLabel.text = [NSString stringWithFormat:@"%lu participants",(unsigned long)objects.count];
            } else {
                NSLog(@"Error fetching users in event");
            }
        }];
    }
}


#pragma mark - Core Data Event Subscription Methods

- (void)fetchSubscribedEvents {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SubscribedEvent"
                                              inManagedObjectContext:[self.coreDataStack managedObjectContext]];
    
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *result = [[self.coreDataStack managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    } else {
        NSMutableArray *events = [[NSMutableArray alloc] init];
        for (SubscribedEvent *event in result) {
            BBDropDownItem *item = [[BBDropDownItem alloc] initWithEvent:event];
            [events addObject:item];
        }
        self.menu.dropDownItems = [events copy];
        [self.menu reloadView];
    }
}


-(void)createSubscriptionToEvent:(EventObject *)event {
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"SubscribedEvent"
                                                         inManagedObjectContext:[self.coreDataStack managedObjectContext]];
    
    SubscribedEvent *subEvent = [[SubscribedEvent alloc] initWithEntity:entityDescription
                                         insertIntoManagedObjectContext:[self.coreDataStack managedObjectContext]];
    
    [subEvent setPropertiesWithEvent:event];
    BBDropDownItem *dropDownItem = [[BBDropDownItem alloc] initWithEvent:subEvent];
    NSMutableArray *menuItems = [self.menu.dropDownItems mutableCopy];
    [menuItems addObject:dropDownItem];
    self.menu.dropDownItems = [menuItems copy];
    [self.menu reloadView];
    NSError *error = nil;
    event.subscribed = YES;
    [self eventDetailChanged];
    if (![subEvent.managedObjectContext save:&error]) {
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
}

-(void)removeSubscriptionToEvent:(EventObject *)event {
    for (BBDropDownItem *item in self.menu.dropDownItems) {
        if ([item.event.eventID isEqual:event.eventID]) {
            [[self.coreDataStack managedObjectContext] deleteObject:item.event];
            NSError *error = nil;
            if (![[self.coreDataStack managedObjectContext] save:&error]) {
                NSLog(@"Unable to save managed object context.");
                NSLog(@"%@, %@", error, error.localizedDescription);
            }
            NSMutableArray *items = [self.menu.dropDownItems mutableCopy];
            [items removeObject:item];
            self.menu.dropDownItems = [items copy];
            [self.menu reloadView];
        }
    }
    event.subscribed = NO;
    [self eventDetailChanged];
    
}

- (IBAction)chatBubbleBookmarkTapped:(id)sender {
    if (self.eventDetailsVC.event.subscribed) {
        [self removeSubscriptionToEvent:self.eventDetailsVC.event];
        [self eventDetailChanged];
    } else {
        [self createSubscriptionToEvent:self.eventDetailsVC.event];
        [self eventDetailChanged];
    }
    
}

-(void)eventDetailChanged {
    EventObject *event = self.eventDetailsVC.event;
    if ([event isToday]) {
        [self.chatBubbleButton setImage:[UIImage imageNamed:@"Blue-Bubble"] forState:UIControlStateNormal];
        self.chatBubbleBookmarkButton.hidden = NO;
        if (event.subscribed) {
            [self.chatBubbleBookmarkButton setImage:[UIImage imageNamed:@"bookmark-filled"] forState:UIControlStateNormal];
        } else {
            [self.chatBubbleBookmarkButton setImage:[UIImage imageNamed:@"bookmark"] forState:UIControlStateNormal];
        }
    } else {
        self.chatBubbleBookmarkButton.hidden = YES;
        if (event.subscribed) {
            [self.chatBubbleButton setImage:[UIImage imageNamed:@"bookmark-filled"] forState:UIControlStateNormal];
        } else {
            [self.chatBubbleButton setImage:[UIImage imageNamed:@"bookmark"] forState:UIControlStateNormal];
        }
        
    }
}


@end
