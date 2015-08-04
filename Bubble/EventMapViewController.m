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
#import "BBLoginAlertView.h"
#import "UISearchBar+EnableReturnKey.h"
#import <INTULocationManager.h>
#import "EventDetailsViewController.h"
#import "BBAnnotation.h"
#import "XMPPManager.h"
#import "BBChatViewController.h"
#import "LoginViewController.h"

@interface EventMapViewController () <MKMapViewDelegate, AFDataStoreDelegate, UIScrollViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *eventDetailContainer;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIImageView *eventImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *eventImageTopConstraint;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *scrollViewTapRecognizer;

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
    
    [self setupMenuScrollView];
    [self setupSearchBar];
    

    [self startLocationUpdateSubscription];
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
                [self.dataStore getSeatgeekEventsWithLocation:self.currentLocation];
                strongSelf.loaded = YES;
                [self.mapView setRegion:MKCoordinateRegionMake(self.currentLocation.coordinate, MKCoordinateSpanMake(.1, .1)) animated:NO];
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
    self.mapView.region = MKCoordinateRegionMake(self.currentLocation.coordinate, MKCoordinateSpanMake(.1, .1));
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
        chatVC.roomID = [self.selectedAnnotation.event.eventID stringValue];
        chatVC.eventLocation = self.selectedAnnotation.event.eventLocation;
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


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

@end
