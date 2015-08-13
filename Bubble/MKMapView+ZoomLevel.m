//
//  MKMapView+ZoomLevel.m
//  Bubble
//
//  Created by Val Osipenko on 8/12/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "MKMapView+ZoomLevel.h"

#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395
#define MAX_GOOGLE_LEVELS 20

@implementation MKMapView (ZoomLevel)

- (int)currentZoomLevel
{
    CLLocationDegrees longitudeDelta = self.region.span.longitudeDelta;
    CGFloat mapWidthInPixels = self.bounds.size.width*2;//2 is for retina display
    double zoomScale = longitudeDelta * MERCATOR_RADIUS * M_PI / (180.0 * mapWidthInPixels);
    double zoomer = MAX_GOOGLE_LEVELS - log2( zoomScale );
    if ( zoomer < 0 ) zoomer = 0;
    zoomer = round(zoomer);
    return (int)zoomer;
}
@end
