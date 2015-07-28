//
//  BBAnnotation.h
//  Bubble
//
//  Created by Jordan Guggenheim on 7/28/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface BBAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

//- (instancetype) initWithEventObject:(BBEventModel *) model;


@end
