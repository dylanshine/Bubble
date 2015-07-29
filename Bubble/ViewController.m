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
#import "BBAnnotation.h"
#import "AFDataStore.h"


@interface ViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) AFDataStore *dataStore;

- (void) plotEvents;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataStore = [AFDataStore sharedData];
    [self.dataStore getSeatgeekEvents];
    
    
    
    self.mapView.delegate = self;
    [self plotEvents];
}

-(void)viewDidAppear:(BOOL)animated {
    [PFUser logOut];
    if (![PFUser currentUser]) {
        
        UIAlertController *loginAlert = [UIAlertController alertControllerWithTitle:@"Login with Facebook" message:@"We use Facebook to personalize your Bubble account." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *login = [UIAlertAction actionWithTitle:@"Login" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSArray *permissions = @[ @"email", @"user_likes", @"public_profile", @"user_friends" ];
            [PFFacebookUtils logInInBackgroundWithReadPermissions:permissions block:^(PFUser *user, NSError *error) {
                if (!user) {
                    NSLog(@"Uh oh. The user cancelled the Facebook login.");
                } else if (user.isNew) {
                    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
                    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                        if (!error) {
                            NSDictionary *userData = (NSDictionary *)result;
                            
                            PFUser *currentUser = [PFUser currentUser];
                            currentUser[@"name"] = userData[@"name"];
                            currentUser[@"friends"] = userData[@"user_friends"];
                            currentUser[@"likes"] = userData[@"user_likes"];
                            [currentUser saveInBackground];
                            NSLog(@"User logged in through Facebook!");
                        }
                    }];
                    
                    NSLog(@"User signed up and logged in through Facebook!");
                } else {
                    PFUser *currentUser = [PFUser currentUser];
                    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
                    FBSDKGraphRequest *requestFriends = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends" parameters:nil];
                    FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
                    [connection addRequest:request completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                        NSDictionary *userData = (NSDictionary *)result;
                        currentUser[@"name"] = userData[@"name"];
                        [currentUser saveInBackground];
                    }];
                    [connection addRequest:requestFriends completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                        NSDictionary *userData = (NSDictionary *)result;
                        NSLog(@"Friends: %@", userData);
                        currentUser[@"friends"] = userData[@"data"];
                        [currentUser saveInBackground];
                    }];
                    
                    [connection start];
                }
            }];
            
        }];

               [loginAlert addAction:login];
        [self presentViewController:loginAlert animated:YES completion:nil];
    }
}

- (void) plotEvents {
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = 40.766238;
    coordinate.longitude = -73.977520;
    
    self.mapView.region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(.08, .05));
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = coordinate;
    annotation.title = @"Central Park";
    annotation.subtitle = @"430 bubblers";
    [self.mapView addAnnotation:annotation];
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
        
        //Replace this
        annotationView.image = [UIImage imageNamed:@"Concert"];
        
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
    
    //Perform Bubble Segue Here
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
