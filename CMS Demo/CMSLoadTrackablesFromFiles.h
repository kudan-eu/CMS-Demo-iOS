#import <Foundation/Foundation.h>
#import "CMSTrackable.h"

@interface CMSLoadTrackablesFromFiles : NSObject

/*
 Fetches trackables from local JSON file, trackables are checked to see whether they are safe to download by checking that all files exist
 within the trackables directory. They are then added to a trackable array.
 */
+ (NSArray *)getTrackables;

@property (nonatomic, strong) NSMutableArray *arrTrackables;

@end
