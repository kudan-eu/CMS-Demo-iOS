#import "CMSTrackable.h"

@implementation CMSTrackable

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _tId = dict[@"id"];
        _markerFileURL = dict[@"marker"];
        _augmentationFileURL = dict[@"augmentation"];
        _markerFileName = dict[@"markerFileName"];
        _augmentationFileName = dict[@"augmentationFileName"];
        _lastUpdated = dict[@"lastUpdated"];
        _displayFade = dict[@"displayFade"];
        _resetTime = dict[@"resetTime"];
        _augmentationRotation = dict[@"augmentationRotation"];
        NSNumber *tBool = dict[@"fillMarker"];
        _fillMarker = [tBool boolValue];
        _augmentationType = dict[@"augmentationType"];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *bundleRoot = [paths firstObject];
        
        _markerFilePath = [bundleRoot stringByAppendingPathComponent:[NSString stringWithFormat:@"Assets/%@/%@", _tId, _markerFileName]];
        _augmentationFilePath = [bundleRoot stringByAppendingPathComponent:[NSString stringWithFormat:@"Assets/%@/%@", _tId, _augmentationFileName]];
        _markerComplete = NO;
        _augmentationComplete = NO;
    }
    
    return self;
}

@end
