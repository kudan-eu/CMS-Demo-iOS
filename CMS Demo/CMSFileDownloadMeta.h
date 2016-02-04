#import <Foundation/Foundation.h>

/// Holds additional information about download tasks being performed
@interface CMSFileDownloadMeta : NSObject

@property (nonatomic, strong) NSString *fileTitle;
@property (nonatomic, strong) NSNumber *fileId;
@property (nonatomic, strong) NSString *downloadSource;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSData *taskResumeData;
@property (nonatomic) double downloadProgress;
@property (nonatomic) BOOL isDownloading;
@property (nonatomic) BOOL downloadComplete;
@property (nonatomic) NSInteger taskIdentifier;

- (instancetype)initWithFileTitle:(NSString *)title andDownloadSource:(NSString *)source andFileId:(NSNumber *)fileID;

@end
