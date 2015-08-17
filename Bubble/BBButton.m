#import "BBButton.h"

@implementation BBButton

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent*)event {
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, -100, -50);
    return CGRectContainsPoint(bounds, point);
}

@end
