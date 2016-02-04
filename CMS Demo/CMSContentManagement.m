#import "CMSContentManagement.h"
#import "CMSTrackable.h"
#import "CMSNetworking.h"
#import "CMSLoadTrackablesFromFiles.h"

@interface CMSContentManagement ()
@property (nonatomic, strong) NSArray *trackableArray;
@end

@implementation CMSContentManagement

/* Tries to download trackable files from the internet if it is unable to do so or the files are up to date
 it attempts to load the files from the apps cache directory */

- (NSDictionary *)getTrackables
{    
    BOOL didFinishWithInternet = [self.downloadTask downloadFiles];
    self.trackableArray = [CMSLoadTrackablesFromFiles getTrackables];
    NSDictionary *dataDict = @{@"Trackables": self.trackableArray,
                               @"InternetConncection": [NSNumber numberWithBool:didFinishWithInternet]};
    return dataDict;
}


#pragma mark file management

+ (void)saveJSONFileToFolder:(NSData *)data
{
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"JSON"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    if (error != NULL) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    NSString *filePath = [dataPath stringByAppendingPathComponent:@"/data.json"];
    [data writeToFile:filePath options:NSDataWritingAtomic error:&error];
    if (error != NULL) {
        NSLog(@"%@", [error localizedDescription]);
    }
}

+ (void)writeCompletedFileToDirectory:(NSString *)directory
{
    NSString *completedFile = [directory stringByAppendingPathComponent:@"completed.txt"];
    [[NSFileManager defaultManager] createFileAtPath:completedFile contents:nil attributes:nil];
}

+ (NSString *)getFileDirectoryFromID:(NSNumber *)fileID
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *bundleRoot = [paths firstObject];
    NSString *fileDirectory = [bundleRoot stringByAppendingPathComponent:[NSString stringWithFormat:@"Assets/%d/", fileID.intValue]];
    return fileDirectory;
}

+ (void)cleanTrackableFileDirectory:(CMSTrackable *)trackable
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *directory = [self getFileDirectoryFromID:trackable.tId];
    NSArray *fileArray = [fileManager contentsOfDirectoryAtPath:directory error:nil];
    
    for (NSString *filename in fileArray) {
        if ([filename isEqualToString:trackable.markerFileName] || [filename isEqualToString:trackable.augmentationFileName]) {
            
        }
        else {
            [fileManager removeItemAtPath:[directory stringByAppendingPathComponent:filename] error:NULL];
        }
    }
}

@end
