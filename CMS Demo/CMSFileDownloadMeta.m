#import "CMSFileDownloadMeta.h"

@implementation CMSFileDownloadMeta

- (instancetype)initWithFileTitle:(NSString *)title andDownloadSource:(NSString *)source andFileId:(NSNumber *)fileID
{
    self = [super init];
    if (self) {
        _fileTitle = [title copy];
        _fileId = fileID;
        _downloadSource = [source copy];
        _downloadProgress = 0.0;
        _isDownloading = NO;
        _downloadComplete = NO;
        _taskIdentifier = -1;
    }
    
    return self;
}

@end
