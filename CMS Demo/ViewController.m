#import "ViewController.h"
#import "CMSFileDownloadMeta.h"
#import "CMSTrackable.h"
#import "Reachability.h"
#import "CMSContentManagement.h"

@interface ViewController()

@property (nonatomic, strong) NSDictionary *contentDictionary;
@property (nonatomic, strong) NSArray *arrTrackableArray;
@property (nonatomic, strong) CMSContentManagement *appContent;

@property (nonatomic, weak) IBOutlet UILabel *downloadLabel;
@property (nonatomic, weak) IBOutlet UIProgressView *downloadProgressView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activitySpinner;
@property (nonatomic, weak) IBOutlet UIView *loadingSplashScreen;
@property (nonatomic, weak) IBOutlet UILabel *trackableTextLabel;
@property (nonatomic, weak) IBOutlet UIView *downloadInfoView;

@end

@implementation ViewController

#pragma mark - Setup
/// Sets up content to be displayed by the ARCameraViewController
- (void)setupContent
{
    self.appContent = [CMSContentManagement new];
    self.appContent.downloadTask = [CMSNetworking new];
    self.appContent.downloadTask.progressDelegate = self;
    
    self.contentDictionary = [self.appContent getTrackables];
    self.arrTrackableArray = self.contentDictionary[@"Trackables"];
    
    [self setDownloadProgressHidden];
    
    if (![self.contentDictionary[@"InternetConncection"] boolValue]) {
        [self showLackOfConnectivityAlert];
    }
    
    [self setupTrackers];
    [self setLoadingProgressHidden];
}

#pragma mark - AR
/// Adds trackables to the tracker manager
- (void)setupTrackers
{
    ARImageTrackerManager *trackerManager = [ARImageTrackerManager getInstance];
    [trackerManager initialise];
    
    for (CMSTrackable *trackable in self.arrTrackableArray) {
        if (trackable.augmentationComplete && trackable.markerComplete) {
            [self setupTrackableSet:trackable];
        }
    }
}

- (void)setupTrackableSet:(CMSTrackable *)cmsTrackable
{
    ARImageTrackerManager *trackerManager = [ARImageTrackerManager getInstance];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:cmsTrackable.markerFilePath] ||
        ![[NSFileManager defaultManager] fileExistsAtPath:cmsTrackable.augmentationFilePath]) {
        NSLog(@"Local files have been removed");
    }
    else {
        ARImageTrackableSet *trackableSet = [[ARImageTrackableSet alloc] initWithPath:cmsTrackable.markerFilePath];
        
        for (ARImageTrackable *trackable in trackableSet.trackables) {
            
            if ([cmsTrackable.augmentationType isEqualToString:@"video"]) {
                ARVideoNode *videoNode = [[ARVideoNode alloc] initWithBundledFile:cmsTrackable.augmentationFilePath];
                
                [trackable.world addChild:videoNode];
                [videoNode rotateByDegrees:[cmsTrackable.augmentationRotation floatValue] axisX:0 y:0 z:1];
                float scaleFactor = 1;
                
                if (cmsTrackable.fillMarker) {
                    if ([cmsTrackable.augmentationRotation intValue] == 90) {
                        scaleFactor = (float)trackable.width / videoNode.videoTexture.height;
                    }
                    else {
                        scaleFactor = (float)trackable.width / videoNode.videoTexture.width; 
                    }
                    [videoNode scaleByUniform:scaleFactor];
                }
                videoNode.videoTextureMaterial.fadeInTime = [cmsTrackable.displayFade floatValue];
                videoNode.videoTexture.resetThreshold = [cmsTrackable.resetTime doubleValue];
                [videoNode play];
            }
            else {
                [trackable addTrackingEventTarget:self action:@selector(textTracking:) forEvent:ARImageTrackableEventDetected];
                [trackable addTrackingEventTarget:self action:@selector(textLost:) forEvent:ARImageTrackableEventLost];
            }
        }
        [trackerManager addTrackableSet:trackableSet];
    }
}

- (void)textTracking:(ARImageTrackable *)trackable
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.trackableTextLabel.text = trackable.name;
        self.trackableTextLabel.hidden = NO;
    });
    
}

- (void)textLost:(ARImageTrackable *)trackable
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.trackableTextLabel.text = @"";
        self.trackableTextLabel.hidden = YES;
    });
}

#pragma mark UI
/// Shows alert if app not connected to internet
- (void)showLackOfConnectivityAlert
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"No network connection"
                                  message:@"Please connect to the internet to download new markers"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil, nil];
        [alertView show];
    }];
}

/// Recieves delegate callback and updates progress view
- (void)updateProgressView:(NSNumber *)percentage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.downloadProgressView.progress = [percentage doubleValue];
    });
}

- (void)setDownloadProgressHidden
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            self.downloadInfoView.alpha = 0.f;
        }];
    });
}

- (void)setLoadingProgressHidden
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            self.loadingSplashScreen.alpha = 0.f;
        }];
    });
}

- (void)downloadFinishedLoadTrackable
{
    [self setDownloadProgressHidden];
}

@end
