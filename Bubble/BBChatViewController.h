#import <CoreLocation/CoreLocation.h>
#import <JSQMessagesViewController.h>

@interface BBChatViewController : JSQMessagesViewController
@property (strong, nonatomic) NSString *roomID;
@property (strong, nonatomic) CLLocation *eventLocation;
@property (strong, nonatomic) CLLocation *currentUserLocation;
@property (strong, nonatomic) NSString *eventTitle;
@property (strong, nonatomic) NSMutableArray *friendsAtEvent;
@end
