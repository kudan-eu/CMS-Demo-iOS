#import <Foundation/Foundation.h>
#import "CMSTrackable.h"

@class CMSNetworking;

@interface CMSContentManagement : NSObject

@property (nonatomic, strong) CMSNetworking *downloadTask;

/// Places an empty text document in the directory to indicate the full completion of a download
+ (void)writeCompletedFileToDirectory:(NSString *)directory;

/// Saves the data to the app's Cache directory
+ (void)saveJSONFileToFolder:(NSData *)data;

/// Delete the files that are stored for the trackable in the Cache directory
+ (void)cleanTrackableFileDirectory:(CMSTrackable * )trackable;

+ (NSString *)getFileDirectoryFromID:(NSNumber *)fileID;

- (NSDictionary *)getTrackables;

@end
