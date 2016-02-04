#import <Foundation/Foundation.h>

@interface CMSTrackable : NSObject

@property (nonatomic, strong) NSNumber *tId;
@property (nonatomic, strong) NSString *markerFileURL;
@property (nonatomic, strong) NSString *augmentationFileURL;
@property (nonatomic, strong) NSString *markerFilePath;
@property (nonatomic, strong) NSString *augmentationFilePath;
@property (nonatomic, strong) NSString *markerFileName;
@property (nonatomic, strong) NSString *augmentationFileName;
@property (nonatomic, strong) NSString *lastUpdated;
@property (nonatomic, strong) NSNumber *displayFade;
@property (nonatomic, strong) NSNumber *resetTime;
@property (nonatomic, strong) NSNumber *augmentationRotation;
@property (nonatomic) BOOL augmentationComplete;
@property (nonatomic) BOOL markerComplete;
@property (nonatomic) BOOL fillMarker;
@property (nonatomic) NSString *augmentationType;

/* Trackable object created from a dictionary in a JSON file includes all the information stored in the dictionary,
 the file paths of the marker and augmentation files and whether or not they have finished downloading */
- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
