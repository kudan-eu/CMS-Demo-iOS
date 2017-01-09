#import "CMSNetworking.h"
#import "CMSFileDownloadMeta.h"
#import "Reachability.h"
#import "CMSContentManagement.h"
#import "CMSTrackable.h"
#import "CMSUtilityFunctions.h"

@interface CMSNetworking ()

@property (nonatomic, strong) NSData *jsonData;
@property (nonatomic, strong) NSData *locaJSONData;
@property (nonatomic, strong) NSArray *jsonRemoteArray;
@property (nonatomic, strong) NSArray *jsonLocalArray;
@property (nonatomic, strong) NSArray *arrFileDownloadData;
@property (nonatomic, strong) NSArray *arrTrackables;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic) BOOL didCompleteWithInternet;

@end


@implementation CMSNetworking


- (BOOL)downloadFiles
{
    self.didCompleteWithInternet = YES;
    [self setupSession];
    [self downloadJSONFile];
    [self initializeFileDownloadDataArray];
    [self updateProgress:^(){
        [CMSContentManagement saveJSONFileToFolder:self.jsonData];
    }];
    
    return self.didCompleteWithInternet;
}


/// Sends message to delegate to update progress view
- (void)updateProgress:(void (^)(void))completionHandler
{
    while (![self checkAllFilesCompleted]) {
        double progress = 0;
        for (CMSFileDownloadMeta *tDl in self.arrFileDownloadData) {
            progress += tDl.downloadProgress;
        }
        progress = progress/(double)self.arrFileDownloadData.count;
        NSAssert(self.progressDelegate && [self.progressDelegate respondsToSelector:@selector(updateProgressView:)],
                 @"CMSNetworking requires a delegate which responds to updateProgressView:");
        [self.progressDelegate updateProgressView:[NSNumber numberWithDouble:progress]];
    }
    completionHandler();
}


- (void)setupSession
{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.JSONAR"];
    sessionConfiguration.HTTPMaximumConnectionsPerHost = 5;
    self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                 delegate:self
                                            delegateQueue:nil];
}


// Starts downloads
- (void)initializeFileDownloadDataArray
{
    [self loadDownloadFileInformation];
    for (CMSFileDownloadMeta *toDl in self.arrFileDownloadData) {
        toDl.downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:toDl.downloadSource]];
        toDl.taskIdentifier = toDl.downloadTask.taskIdentifier;
        [toDl.downloadTask resume];
        toDl.isDownloading = YES;
    }
}


/*
 Checks to see if a local JSON file has been saved. If one exists it compares the date it was last updated with the date of the JSON file downloaded.
 If the JSON file downloaded is newer it checks to see which objects in the dictionary have been updated and downloads them.
 */
- (void)loadDownloadFileInformation
{
    [self setLocalJson];
    [self setTrackablesFromArray:self.jsonRemoteArray];
    NSMutableArray *temp = [NSMutableArray new];

    /// If we have a local JSON file, lets iterate through it to see if there is newer data on server
    if (self.locaJSONData != nil) {
        
        /// Check if the JSON response on remote is newer than the locally held copy
        if ([CMSUtilityFunctions compareDate:[CMSUtilityFunctions getDateFromJsonFile:self.locaJSONData] withDate:[CMSUtilityFunctions getDateFromJsonFile:self.jsonData]]) {
            
            for (CMSTrackable *trackable in self.arrTrackables) {
                
                /// Check if the augment's data is newer on remote
                if ([CMSUtilityFunctions compareDate:[CMSUtilityFunctions getDateFromJsonFile:self.locaJSONData] withDate:trackable.lastUpdated]) {
                    [self addTrackable:trackable toDownloadList:temp];
                }
            }
        }
    }
    else {
        for (CMSTrackable *trackable in self.arrTrackables) {
            [self addTrackable:trackable toDownloadList:temp];
        }
    }
    self.arrFileDownloadData = [temp copy];
}

- (void)addTrackable:(CMSTrackable *)trackable toDownloadList:(NSMutableArray *)array
{
    // Because text augments do not have a file to download, we do not add a superflous and empty item to the download array
    if (![trackable.augmentationType isEqualToString:@"text"]) {
        [array addObject:[[CMSFileDownloadMeta alloc] initWithFileTitle:trackable.augmentationFileName andDownloadSource:trackable.augmentationFileURL andFileId:trackable.tId]];
    }
    [array addObject:[[CMSFileDownloadMeta alloc] initWithFileTitle:trackable.markerFileName andDownloadSource:trackable.markerFileURL andFileId:trackable.tId]];
}


/*
 When the file has finished downloading it checks to see that a similar file
 does not exist at its target directory, if it does the file is deleted.
 It then sets the file download information to display that the download has finished and marks the
 corresponding file as completed in the trackable array
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSInteger index = [self getFileDownloadMetaIndexWithTaskIdentifier:downloadTask.taskIdentifier];
    CMSFileDownloadMeta *fileDownloadInfo = [self.arrFileDownloadData objectAtIndex:index];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *bundleRoot = [paths firstObject];
    
    if (fileDownloadInfo != nil) {
        
        NSString *dataPath2 = [bundleRoot stringByAppendingPathComponent:[NSString stringWithFormat:@"Assets/%@",fileDownloadInfo.fileId]];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath2]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath2 withIntermediateDirectories:YES attributes:nil error:&error];
        }
        else {
            [CMSContentManagement cleanTrackableFileDirectory:[self getTrackableFromTrackableDownload:fileDownloadInfo]];
        }
        NSString *destinationDir = [bundleRoot stringByAppendingPathComponent:[NSString stringWithFormat:@"Assets/%@/%@", fileDownloadInfo.fileId,fileDownloadInfo.fileTitle]];
        
        if ([fileManager fileExistsAtPath:destinationDir]) {
            [fileManager removeItemAtPath:destinationDir error:&error];
        }
        
        NSURL *destinationURL = [NSURL fileURLWithPath:destinationDir];
        if (error != NULL) {
            NSLog(@"Unable to copy temp file. Error: %@", [error localizedDescription]);
        }
        
        BOOL success = [fileManager copyItemAtURL:location
                                            toURL:destinationURL
                                            error:&error];
        
        // If file has been copied to the directory location successfully
        if (success) {
            fileDownloadInfo.isDownloading = NO;
            fileDownloadInfo.downloadComplete = YES;
            fileDownloadInfo.taskIdentifier = -1;
            fileDownloadInfo.taskResumeData = nil;
            [self setTrackableCompleted:fileDownloadInfo];
        }
        else {
            NSLog(@"Unable to copy temp file. Error: %@", [error localizedDescription]);
        }
    }
}


/// Keeps track of what percentage of a file has been downloaded
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if (totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown) {
        NSLog(@"Unknown transfer size");
    }
    else {
        // Locate the FileDownloadInfo object among all based on the taskIdentifier property of the task.
        NSInteger index = [self getFileDownloadMetaIndexWithTaskIdentifier:downloadTask.taskIdentifier];
        CMSFileDownloadMeta *fdi = self.arrFileDownloadData[index];
        fdi.downloadProgress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    }
}


- (void)downloadJSONFile
{
    NSURL *url = [NSURL URLWithString:kJSONURL];
    self.jsonData = [NSData dataWithContentsOfURL:url];
    
    if (self.jsonData != nil) {
        NSDictionary *tempJsonArray = [NSJSONSerialization JSONObjectWithData:self.jsonData options:0 error:nil];
        self.jsonRemoteArray = [NSArray arrayWithArray:tempJsonArray[@"results"]];
    }
    else {
        self.didCompleteWithInternet = NO;
    }
}


/// Returns true if all files have finished downloading
- (BOOL)checkAllFilesCompleted
{
    NSUInteger completedCount = 0;
    for (CMSFileDownloadMeta *tDl in self.arrFileDownloadData) {
        if (tDl.downloadComplete) {
            completedCount++;
        }
    }
    
    if (completedCount == self.arrFileDownloadData.count) {
        return YES;
    }
    return NO;
}


/// Returns true if connected to the internet
- (BOOL)isConnectedToInternet
{
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        return NO;
    }
    return YES;
}


/// Returns the trackable file from a download task
- (CMSTrackable *)getTrackableFromTrackableDownload:(CMSFileDownloadMeta *)trackableDl
{
    NSNumber *trId = trackableDl.fileId;
    NSInteger index = 0;
    for (NSUInteger i = 0; i < self.arrTrackables.count; i++) {
        CMSTrackable *fdi = self.arrTrackables[i];
        if (fdi.tId.integerValue == trId.integerValue) {
            index = i;
            break;
        }
    }
    return self.arrTrackables[index];
}


/// Sets marker completed or augmentation completed depending on what file has been downloaded
- (void)setTrackableCompleted:(CMSFileDownloadMeta *)trackableDl
{
    CMSTrackable *trackable = [self getTrackableFromTrackableDownload:trackableDl];
    
    if ([trackableDl.fileTitle rangeOfString:@".KARMarker"].location == NSNotFound) {
        trackable.augmentationComplete = YES;
    }
    else {
        trackable.markerComplete = YES;
        if ([trackable.augmentationType isEqualToString:@"text"]) {
            trackable.augmentationComplete = YES;
        }
    }
    
    if (trackable.markerComplete == YES && trackable.markerComplete == YES) {
        NSString *completionDirectory = [CMSContentManagement getFileDirectoryFromID:trackable.tId];
        [CMSContentManagement cleanTrackableFileDirectory:trackable];
        [CMSContentManagement writeCompletedFileToDirectory:completionDirectory];
    }
}


- (void)setArrayFromLocalJSON
{
    NSArray *tempJsonArray = [NSJSONSerialization JSONObjectWithData:self.locaJSONData options:0 error:nil];
    self.jsonLocalArray = [NSArray arrayWithArray:[tempJsonArray valueForKey:@"results"]];
}


- (void)setTrackablesFromArray:(NSArray *)jsonArray
{
    NSMutableArray *temp = [NSMutableArray new];
    for (NSDictionary *data in jsonArray) {
        [temp addObject:[[CMSTrackable alloc] initWithDictionary:data]];
    }
    self.arrTrackables = [temp copy];
}


- (void)setLocalJson
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *bundleRoot = [paths objectAtIndex:0];
    NSString *jsonPath = [bundleRoot stringByAppendingPathComponent:@"JSON/data.json"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:jsonPath]) {
        self.locaJSONData = [NSData dataWithContentsOfFile:jsonPath];
    }
}


/// Gets file download meta from a the task identifier of a download task
- (NSInteger)getFileDownloadMetaIndexWithTaskIdentifier:(NSUInteger)taskIdentifier
{
    NSInteger index = 0;
    for (NSUInteger i = 0; i < self.arrFileDownloadData.count; i++) {
        CMSFileDownloadMeta *fdi = [self.arrFileDownloadData objectAtIndex:i];
        if (fdi.taskIdentifier == taskIdentifier) {
            index = i;
            break;
        }
    }
    return index;
}

@end
