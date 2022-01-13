//
//  NSDate+MJExtension.m
//  MJExtension
//
//  Created by Frank on 2021/12/31.
//  Copyright © 2021 MJ Lee. All rights reserved.
//

#import "NSDate+MJExtension.h"

@implementation NSDate (MJExtension)

- (NSString *)mj_defaultString {
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    });
    NSString *dateString = [formatter stringFromDate:self];
    return dateString;
}

- (NSString *)mj_stringWithFormatter:(NSDateFormatter *)formatter {
    return [formatter stringFromDate:self];
}

@end
