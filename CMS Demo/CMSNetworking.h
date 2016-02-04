#import <Foundation/Foundation.h>

//#define KUDAN_SERVER

#ifndef KUDAN_SERVER
static NSString * const kJSONURL = @"URL OF JSON FILE ON YOUR SERVER";
#else
static NSString * const kJSONURL = @"https://api.kudan.eu/CMS/JSON/test.json";
#endif


@protocol CMSDownloadProgress <NSObject>
@required
- (void)updateProgressView:(NSNumber *)percentage;

@end


@interface CMSNetworking : NSObject <NSURLConnectionDataDelegate, NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, weak) id <CMSDownloadProgress> progressDelegate;

/// Returns YES if it was possible to check the remote server and download updated content
- (BOOL)downloadFiles;

@end
