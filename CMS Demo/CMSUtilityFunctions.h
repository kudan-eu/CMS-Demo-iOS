#import <Foundation/Foundation.h>

@interface CMSUtilityFunctions : NSObject

/// Returns YES if the dateLocal is older than  dateRemote
+ (BOOL)compareDate:(NSString *)dateLocal withDate:(NSString *)dateRemote;

+ (NSDate *)getDateFromString:(NSString *)dateString;

+ (NSString *)getDateFromJsonFile:(NSData *)data;

@end
