#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@class AFDataStore;

@protocol AFDataStoreDelegate <NSObject>
@required
- (void) dataStore:(AFDataStore *)datastore didLoadEvents:(NSArray *)eventsArray;
@end

@interface AFDataStore : NSObject
@property (weak, nonatomic) id<AFDataStoreDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *eventsArray;

+ (instancetype)sharedData;
- (void) searchEvents: (NSString *)searchTerm withScope:(NSInteger)index;
- (void) getAllEventsWithLocation:(CLLocation *)currentLocation date:(NSDate *)date;
@end
