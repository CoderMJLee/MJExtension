//
//  NSDate+MJExtension.m
//  MJExtensionExample
//
//  Created by ricky on 15/9/7.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "NSDate+MJExtension.h"

static NSDateFormatter * _theFormatter = nil;
static NSMutableSet * _registedDateStrings = nil;

@implementation NSDate (MJExtension)

+ (void)load
{
    _theFormatter = [[NSDateFormatter alloc] init];
    _theFormatter.locale = [NSLocale currentLocale];
    _theFormatter.timeZone = [NSTimeZone localTimeZone];

    _registedDateStrings = [NSMutableSet setWithObjects:
                            @"yyyy-MM-dd'T'HH:mm:ss.SSSZ",
                            @"yyyy-MM-dd'T'HH:mm:ssZ",
                            @"yyyy-MM-dd HH:mm:ss Z",
                            @"yyyy-MM-dd HH:mm:ss",
                            @"yyyy-MM-dd HH:mm",
                            @"yyyy-MM-dd",
                            @"EEE, MMM d, yyyy", nil];
}

+ (instancetype)mj_dateWithString:(NSString *)aString
{
    __block NSDate *date = nil;
    [_registedDateStrings enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        _theFormatter.dateFormat = obj;
        date = [_theFormatter dateFromString:aString];
        if (date) {
            *stop = YES;
        }
    }];
    if (!date) {
        NSLog(@"Can't convert String:%@ to Date", aString);
    }
    return date;
}

+ (void)mj_registerDateFormat:(NSString *)format
{
    [_registedDateStrings addObject:format];
}

@end
