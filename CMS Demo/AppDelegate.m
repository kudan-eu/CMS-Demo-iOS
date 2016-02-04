#import "AppDelegate.h"
#import <KudanAR/ARAPIKey.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[ARAPIKey sharedInstance] setAPIKey:@"GAXAE-F9AU4-58C4L-35HMV-EY6C9-GD6XG-2RJKX-BACQZ-A9KQB-XYYXC-7LCB2-8UUN2-FEXW5-W6CVL-27QYS-QU"];
    
    // Override point for customization after application launch.
    return YES;
}

@end
