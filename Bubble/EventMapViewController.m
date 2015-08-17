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
#import <Parse.h>
#import "CoreDataStack.h"
#import "SubscribedEvent+setPropertiesWithEvent.h"
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *refreshButtonConstraint;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *datePickerCenterConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *datePickerXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchViewContainerYConstraint;
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
                [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
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
    [self hideRefreshButton];
}

- (IBAction)refreshButtonTapped:(id)sender {
    [SVProgressHUD show];
    [self.dataStore getAllEventsWithLocation:[self mapCenter] date:self.date];
}

-(void)showRefreshButton {
    [UIView animateWithDuration:.7 animations:^{
        self.refreshButtonConstraint.constant = 8;
        [self.view layoutIfNeeded];
    }];
}

-(void)hideRefreshButton {
    [UIView animateWithDuration:.7 animations:^{
        self.refreshButtonConstraint.constant = -50;
        [self.view layoutIfNeeded];
    }];
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
    MKMapRect visibleRect = self.mapView.visibleMapRect;
    NSSet *visibleAnnotations = [self.mapView annotationsInMapRect:visibleRect];
    if (visibleAnnotations.count == 0 && [self.searchBar.text isEqualToString:@""]) {
        [self showRefreshButton];
    }
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
    
    [self.mapView setCamera:mapCamera animated:NO];
}

- (void) centerOnSelectedAnnotation {
    
    if (self.mapView.camera.altitude < 2500) {
        [self.mapView setCenterCoordinate:self.selectedAnnotation.coordinate animated:YES];
        
    } else {
        MKMapCamera *mapCamera = [MKMapCamera cameraLookingAtCenterCoordinate:self.selectedAnnotation.coordinate fromEyeCoordinate:self.currentLocation.coordinate eyeAltitude:2500];
        mapCamera.heading = 0;
        mapCamera.pitch = 0;
        [self.mapView setCamera:mapCamera animated:YES];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    [self resizeAnnotation];
}


- (void)didDragMap:(UIGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        MKMapRect visibleRect = self.mapView.visibleMapRect;
        NSSet *visibleAnnotations = [self.mapView annotationsInMapRect:visibleRect];
        if (visibleAnnotations.count == 0 && [self.searchBar.text isEqualToString:@""]) {
            [self showRefreshButton];
        }
        
    }
}
-(void)didPinchMap:(UIGestureRecognizer*)gestureRecognizer{
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self hideMiniVC];
        [self hideSearchBar];
        
        // Prevents inadvertant selection of different annotation while pinching
        self.mapView.userInteractionEnabled = NO;
        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        
        [self showMiniVCAndSearchBar];
        self.mapView.userInteractionEnabled = YES;
    }
}

- (void) resizeAnnotation {
    
    for (id <MKAnnotation>annotation in self.mapView.annotations) {
        
        if ([annotation isKindOfClass:[MKUserLocation class]])
            continue;
        if ([annotation isKindOfClass:[BBAnnotation class]]) {
            double zoomLevel = [self.mapView currentZoomLevel];
            
            if (zoomLevel < 14) {
                zoomLevel = 8;
            }
            
            // Max zoom is 18, zoom level above 14 will make annotation larger than default size
            double scale = (zoomLevel / 14);
            
            MKAnnotationView *pinView = [self.mapView viewForAnnotation:annotation];
            
            [UIView animateWithDuration:.4 animations:^{
                pinView.transform = CGAffineTransformMakeScale(scale, scale);
            }];
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
    [self.mapView setRegion:MKCoordinateRegionMake(closestAnnotation.coordinate, MKCoordinateSpanMake(.02, .02)) animated:YES];
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
        [self centerOnSelectedAnnotation];
        [self showMiniVC];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    self.selectedAnnotation = nil;
    [self hideMiniVC];
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
    
    UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    
    [self.searchContainer insertSubview:view atIndex:0];
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.equalTo(@0);
        make.top.equalTo(@0).offset(-20);
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
    
    self.scrollViewStartingPosition = -1 * (self.view.frame.size.height + 50);
    self.scrollViewMiniViewPosition = -1 * (self.view.frame.size.height - 100);
    
    self.scrollView.scrollEnabled = NO;
    self.scrollView.pagingEnabled = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.alwaysBounceHorizontal = NO;
    self.scrollView.contentInset = UIEdgeInsetsMake(self.scrollViewStartingPosition * -1, 0, 0, 0);
    [self.scrollViewTapRecognizer addTarget:self action:@selector(toggleScrollViewLocation)];
    
    self.chatBubbleButton.alpha = 0;
    self.eventDetailsVC = self.childViewControllers[0];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    if (velocity.y >= 0) {
        [self showDetailedVC];
    } else {
        [self hideDetailedVC];
    }
}

- (void) toggleScrollViewLocation {
    
    if (self.scrollView.contentOffset.y < -400) {
        [self showDetailedVC];
    } else {
        [self hideDetailedVC];
    }
}

- (void) showMiniVCAndSearchBar {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
        [self showMiniVC];
        [self showSearchBar];
    });
}

- (void) showMiniVC {
    
    if (self.selectedAnnotation != nil) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.25 animations:^{
                [self.scrollView setContentOffset:CGPointMake(0, self.scrollViewMiniViewPosition) animated:NO];
            }];
        });
    }
}

- (void) hideMiniVC {
    
    if (self.scrollView.contentOffset.y != self.scrollViewStartingPosition) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.25 animations:^{
                [self.scrollView setContentOffset:CGPointMake(0, self.scrollViewStartingPosition) animated:NO];
            }];
        });
    }
}

- (void) showDetailedVC {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:.3 animations:^{
            [self.scrollView setContentOffset:CGPointMake(0, -self.eventImage.frame.size.height) animated:NO];
            self.mapView.userInteractionEnabled = NO;
            self.eventImageTopConstraint.constant = 0;
            [self.eventImage layoutIfNeeded];
        }];
    });
}

- (void) hideDetailedVC {
    
    if (self.scrollView.contentOffset.y != self.scrollViewMiniViewPosition) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.25 animations:^{
                [self.scrollView setContentOffset:CGPointMake(0, self.scrollViewMiniViewPosition) animated:NO];
                self.mapView.userInteractionEnabled = YES;
                self.eventImageTopConstraint.constant = self.eventImage.frame.size.height + 500;
                [self.eventImage layoutIfNeeded];
            }];
        });
    }
}

- (void) showSearchBar {
    
    if (self.searchViewContainerYConstraint.constant != 0) {
        [UIView animateWithDuration:.25 animations:^{
            self.searchViewContainerYConstraint.constant = 0;
            [self.searchContainer layoutIfNeeded];
        }];
    }
}

- (void) hideSearchBar {
    
    if (self.searchViewContainerYConstraint.constant != -100) {
        [UIView animateWithDuration:.25 animations:^{
            self.searchViewContainerYConstraint.constant = -100;
            [self.searchContainer layoutIfNeeded];
        }];
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

-(void)eventDetailChanged {
    EventObject *event = self.eventDetailsVC.event;
    for (BBDropDownItem *item in self.menu.dropDownItems) {
        if ([item.event.eventID isEqual:self.eventDetailsVC.event.eventID]) {
            self.eventDetailsVC.event.subscribed = YES;
        }
    }
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
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyMMdd";
        BOOL saveNeeded = NO;
        for (SubscribedEvent *event in result) {
            if ([[formatter stringFromDate:event.date] integerValue] < [[formatter stringFromDate:[NSDate date]] integerValue]) {
                [[self.coreDataStack managedObjectContext] deleteObject:event];
                saveNeeded = YES;
            } else {
                BBDropDownItem *item = [[BBDropDownItem alloc] initWithEvent:event];
                [events addObject:item];
            }
        }
        if (saveNeeded) {
            NSError *error = nil;
            [[self.coreDataStack managedObjectContext] save:&error];
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
    if (self.menuOpen) {
        [self openMenu];
    }
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
            if (self.menuOpen) {
                [self openMenu];
            }
        }
    }
    event.subscribed = NO;
    [self eventDetailChanged];
    
}

- (IBAction)chatBubbleBookmarkTapped:(id)sender {
    if (self.eventDetailsVC.event.subscribed) {
        [self removeSubscriptionToEvent:self.eventDetailsVC.event];
    } else {
        [self createSubscriptionToEvent:self.eventDetailsVC.event];
    }
}

@end
