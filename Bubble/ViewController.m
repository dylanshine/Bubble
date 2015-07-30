//
//  ViewController.m
//  Bubble
//
//  Created by Lukas Thoms on 7/27/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "ViewController.h"
#import <FBSDKLoginKit.h>
#import <FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <MapKit/MapKit.h>
#import <Masonry/Masonry.h>
#import "BBAnnotation.h"
#import "AFDataStore.h"
#import "EventObject.h"
#import "BBLoginAlertView.h"
#import <INTULocationManager.h>
#import "EventDetailsViewController.h"
#import "BBAnnotation.h"

@interface ViewController () <MKMapViewDelegate, AFDataStoreDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic, strong) EventDetailsViewController *eventDetailsVC;

@property (nonatomic, strong) NSArray *eventsArray;
@property (nonatomic) AFDataStore *dataStore;

@property (nonatomic) CLLocation *currentLocation;
@property (assign, nonatomic) INTULocationRequestID locationRequestID;

@property (nonatomic) BOOL loaded;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataStore = [AFDataStore sharedData];
    
    self.dataStore.delegate = self;

    self.mapView.delegate = self;
    
    self.scrollView.delegate = self;
    self.scrollView.clipsToBounds = YES;
    self.scrollView.pagingEnabled = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    CGSize scrollableSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    [self.scrollView setContentSize:scrollableSize];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.bottom.and.right.equalTo(@0);
        make.top.equalTo(self.view.mas_centerY);
    }];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(@0);
        make.height.width.equalTo(self.view);
    }];
    
    self.eventDetailsVC = self.childViewControllers[0];
    
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

        BBAnnotation *annotation = [[BBAnnotation alloc] init];

        annotation.coordinate = event.coordinate;
        annotation.event = event;
        annotation.title = event.eventTitle;
        
        
            [self.mapView addAnnotation:annotation];
    }
    
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

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {

    BBAnnotation *annotation = view.annotation;
    
//    self.eventDetailsVC.eventTitle.text = annotation.event.eventTitle;
    
    NSLog(@"%@",annotation.event.eventType);
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"detailSegue"]) {
//        self.eventDetailsVC = segue.destinationViewController;
    }
}
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

@end
