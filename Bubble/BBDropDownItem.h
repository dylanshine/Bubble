#import "IGLDropDownItem.h"
#import "SubscribedEvent.h"

@interface BBDropDownItem : IGLDropDownItem
@property (strong, nonatomic) SubscribedEvent *event;

-(instancetype)initWithEvent:(SubscribedEvent *)event;
@end
