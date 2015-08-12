#import "BBDropDownItem.h"

@implementation BBDropDownItem

-(instancetype)initWithEvent:(SubscribedEvent *)event {
    if (self = [super init]) {
        _event = event;
        [self commonInit];
    }
    return self;
}

-(void)commonInit {
    [self setText:self.event.eventTitle];
}

@end
