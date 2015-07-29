//
//  ViewController.m
//  Bubble
//
//  Created by Lukas Thoms on 7/27/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "BBAnnotation.h"
#import "AFDataStore.h"
#import "EventObject.h"
#import "BBLoginAlertView.h"
#import "UISearchBar+EnableReturnKey.h"
#import <INTULocationManager.h>

@interface ViewController () <MKMapViewDelegate, AFDataStoreDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) AFDataStore *dataStore;
@property (nonatomic, strong) NSArray *eventsArray;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (assign, nonatomic) INTULocationRequestID locationRequestID;
@property (nonatomic) CLLocation *currentLocation;
@property (nonatomic) BOOL loaded;

- (void) plotEvents;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataStore = [AFDataStore sharedData];
    
    self.dataStore.delegate = self;

    self.mapView.delegate = self;
    
    self.searchBar.delegate = self;
    self.searchBar.scopeButtonTitles = @[ @"Name", @"Venue", @"Performer" ];
    self.searchBar.backgroundColor = [UIColor whiteColor];
    self.searchBar.showsScopeBar = NO;
    self.searchBar.returnKeyType = UIReturnKeyDone;
    [self.searchBar alwaysEnableReturn];


    
    [self.dataStore getSeatgeekEvents];
    //[self.dataStore getSeatgeekEvents];
    [self startLocationUpdateSubscription];
}

- (void)startLocationUpdateSubscription {
    __weak __typeof(self) weakSelf = self;
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    self.locationRequestID = [locMgr subscribeToLocationUpdatesWithBlock:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        __typeof(weakSelf) strongSelf = weakSelf;
        
        if (status == INTULocationStatusSuccess) {
            // A new updated location is available in currentLocation, and achievedAccuracy indicates how accurate this particular location is
            strongSelf.currentLocation = currentLocation;
            if (!strongSelf.loaded) {
                //[self centerMapOnLocation:self.currentLocation];
                //[self getCurrentCity];
                //[strongSelf setupMap];
                [self.dataStore getSeatgeekEventsWithLocation:self.currentLocation];
                strongSelf.loaded = YES;
                
                //[SVProgressHUD showWithStatus:@"Loading Nearby Restaurants..." maskType:SVProgressHUDMaskTypeBlack];
                
            }
            NSLog(@"%@",self.currentLocation);
        }
        else {
            // An error occurred, which causes the subscription to cancel automatically (this block will not execute again unless it is used to start a new subscription).
            strongSelf.locationRequestID = NSNotFound;
            //NSLog(@"%@", [strongSelf getErrorDescription:status]);
        }
    }];
}

- (void)dataStore:(AFDataStore *)datastore didLoadEvents:(NSArray *)eventsArray{

    self.eventsArray = eventsArray;
}

- (void)setEventsArray:(NSArray *)eventsArray{
    
    _eventsArray = eventsArray;
    
    [self plotEvents];
} 


- (void)viewDidAppear:(BOOL)animated {

//    uncomment the logOut to test login flow
//    [PFUser logOut];
    
    if (![PFUser currentUser]) {
        BBLoginAlertView *login = [[BBLoginAlertView alloc] init];
        [login showLoginAlertViewOn:self withCompletion:^(PFUser *currentUser) {
            [currentUser saveInBackground];
        }];
    }
}

- (void) plotEvents {
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    for (EventObject *event in self.eventsArray) {

            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            
            annotation.coordinate = event.coordinate;
            annotation.title = event.eventTitle;
            [self.mapView addAnnotation:annotation];
    }
    
    // Move this logic to search functionality
//    for (MKPointAnnotation *annotation in self.mapView.annotations) {
//        
//        if ([annotation.title isEqualToString:@"Amateur Night At The Apollo"]) {
//            
//            [self.mapView selectAnnotation:annotation animated:YES];
//            
//            self.mapView.region = MKCoordinateRegionMake(annotation.coordinate, MKCoordinateSpanMake(.05, .05));
//        }
//    }
    self.mapView.region = MKCoordinateRegionMake(self.currentLocation.coordinate, MKCoordinateSpanMake(.1, .1));
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    static NSString *const eventAnnotationReuseID = @"eventAnnotation";
    
    MKAnnotationView *annotationView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:eventAnnotationReuseID];
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    if (!annotationView) {
        
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:eventAnnotationReuseID];
        
        annotationView.canShowCallout = YES;
        annotationView.highlighted = YES;
        
        // Replace this
        annotationView.image = [UIImage imageNamed:@"Bubble-Red"];

        
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
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    
    // Perform Bubble Segue Here
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    
    self.searchBar.showsScopeBar = NO;
    
    [UIView animateWithDuration:.25 animations:^{
        self.searchBar.alpha = 0.8;
    }];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    [self.dataStore searchEvents:searchBar.text];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    self.searchBar.showsScopeBar = YES;

    [UIView animateWithDuration:.25 animations:^{
        self.searchBar.alpha = 1;

    }];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

@end
