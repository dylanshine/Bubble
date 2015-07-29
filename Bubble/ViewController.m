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
#import "EventObject.h"


@interface ViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) AFDataStore *dataStore;
@property (nonatomic, strong) NSArray *eventsArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataStore = [AFDataStore sharedData];

//    NSArray *permissions = @[ @"email", @"user_likes", @"public_profile", @"user_friends" ];
//    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissions block:^(PFUser *user, NSError *error) {
//        if (!user) {
//            NSLog(@"Uh oh. The user cancelled the Facebook login.");
//        } else if (user.isNew) {
//            NSLog(@"User signed up and logged in through Facebook!");
//        } else {
//            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
//            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//                if (!error) {
//                    NSDictionary *userData = (NSDictionary *)result;
//                    
//                    PFUser *currentUser = [PFUser currentUser];
//                    currentUser[@"name"] = userData[@"name"];
//                    currentUser[@"]
//                }
//            }]
//            NSLog(@"User logged in through Facebook!");
//        }
//    }];

    self.mapView.delegate = self;
    
    [self populateEventArray];
}


- (void) populateEventArray {

    [self.dataStore getSeatgeekEvents:^(NSArray *returnArray) {
        
        self.eventsArray = returnArray;
    }];
}

- (void)setEventsArray:(NSArray *)eventsArray{
    
    _eventsArray = eventsArray;
    
    [self plotEvents];
}


- (void) plotEvents {
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    for (EventObject *event in self.eventsArray) {

            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            
            annotation.coordinate = event.coordinate;
            annotation.title = event.eventTitle;
            
            [self.mapView addAnnotation:annotation];
    }
    
    //Move this logic to search functionality
    for (MKPointAnnotation *annotation in self.mapView.annotations) {
        
        if ([annotation.title isEqualToString:@"Amateur Night At The Apollo"]) {
            
            [self.mapView selectAnnotation:annotation animated:YES];
            
            self.mapView.region = MKCoordinateRegionMake(annotation.coordinate, MKCoordinateSpanMake(.05, .05));
        }
    }
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
    
    //Perform Bubble Segue Here
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

@end
