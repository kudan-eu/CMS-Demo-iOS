#import "CMSUtilityFunctions.h"

@implementation CMSUtilityFunctions


+ (NSDate *)getDateFromString:(NSString*)dateString
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    return [dateFormat dateFromString:dateString];
}

+ (BOOL)compareDate:(NSString *)dateLocal withDate:(NSString *)dateRemote
{
    NSDate *dateL = [self getDateFromString:dateLocal];
    NSDate *dateR = [self getDateFromString:dateRemote];
    if ([dateL compare:dateR] == NSOrderedAscending) {
        return YES;
    }
    return NO;
}

+ (NSString *)getDateFromJsonFile:(NSData *)data
{
    if (data) {
        NSDictionary *result = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSString *date = result[@"lastUpdated"];
        return date;
    }
    return nil;
}

@end
