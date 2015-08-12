#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Friend : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *facebookId;
@property (strong, nonatomic) UIImage *image;

- (instancetype)initWithName:(NSString *)name FacebookId:(NSString *)facebookId;
@end
