#import "EventObject.h"
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface BBAnnotation : MKPointAnnotation
@property (strong, nonatomic) EventObject *event;
@property (strong, nonatomic) NSString *eventImageName;
@property (nonatomic, strong) NSNumber *eventScore;

- (NSString*)getEventImageName:(EventObject*)eventName;
@end

