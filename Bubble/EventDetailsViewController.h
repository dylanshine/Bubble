#import "EventObject.h"
#import <UIKit/UIKit.h>

@interface EventDetailsViewController : UIViewController // <BBScrollViewNotifying>
@property (strong, nonatomic) EventObject *event;
@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;
@end
