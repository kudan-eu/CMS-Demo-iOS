#import "CMSLoadTrackablesFromFiles.h"
#import "CMSContentManagement.h"

@implementation CMSLoadTrackablesFromFiles

+ (NSArray *)getTrackables
{
    NSMutableArray *arrTrackables= [NSMutableArray new];
    NSArray *jsonArray = [self getLocalArrayFromJSON:[self getLocalJson]];
    
    for (NSDictionary *data in jsonArray) {
        CMSTrackable *tr = [[CMSTrackable alloc] initWithDictionary:data];
        
        if ([self trackableIsSafeToAdd:tr]) {
            tr.markerComplete = YES;
            tr.augmentationComplete = YES;
            [arrTrackables addObject: tr];
        }

    }
    return [arrTrackables copy];
}

+ (NSData *)getLocalJson
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *bundleRoot = [paths objectAtIndex:0];
    NSString *jsonPath = [bundleRoot stringByAppendingPathComponent:@"JSON/data.json"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:jsonPath]) {
        return [NSData dataWithContentsOfFile:jsonPath];
    }
    return nil;
}

+ (NSArray *)getLocalArrayFromJSON:(NSData *)data
{
    if (data != nil) {
        id deserialisedJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if ([deserialisedJSON isKindOfClass:[NSDictionary class]]) {
            NSArray *dataArray = [deserialisedJSON valueForKey:@"results"];
            return dataArray;
        }
    }
    return nil;
}

+ (BOOL)trackableIsSafeToAdd:(CMSTrackable *)trackable
{
    NSString *rootDirectory = [CMSContentManagement getFileDirectoryFromID:trackable.tId];
    NSString *markerDirectory = [rootDirectory stringByAppendingPathComponent:trackable.markerFileName];
    NSString *augmentationDirectory = [rootDirectory stringByAppendingPathComponent:trackable.augmentationFileName];
    NSString *completedDirectory = [rootDirectory stringByAppendingPathComponent:@"completed.txt"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:markerDirectory] &&
       [[NSFileManager defaultManager] fileExistsAtPath:augmentationDirectory] &&
       [[NSFileManager defaultManager] fileExistsAtPath:completedDirectory])
    {
        return true;
    }
    return false;
}

@end
