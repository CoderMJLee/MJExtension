//
//  NSString+MJExtension.m
//  MJExtensionExample
//
//  Created by MJ Lee on 15/6/7.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "NSString+MJExtension.h"
#import <locale>

@implementation NSString (MJExtension)
- (NSString *)mj_underlineFromCamel
{
    if (self.length == 0) return self;
    NSMutableString *string = [NSMutableString string];
    for (NSUInteger i = 0; i<self.length; i++) {
        unichar c = [self characterAtIndex:i];
        NSString *cString = [NSString stringWithFormat:@"%c", c];
        NSString *cStringLower = [cString lowercaseString];
        if ([cString isEqualToString:cStringLower]) {
            [string appendString:cStringLower];
        } else {
            [string appendString:@"_"];
            [string appendString:cStringLower];
        }
    }
    return string;
}

- (NSString *)mj_camelFromUnderline
{
    if (self.length == 0) return self;
    NSMutableString *string = [NSMutableString string];
    NSArray *cmps = [self componentsSeparatedByString:@"_"];
    for (NSUInteger i = 0; i<cmps.count; i++) {
        NSString *cmp = cmps[i];
        if (i && cmp.length) {
            [string appendString:[NSString stringWithFormat:@"%c", [cmp characterAtIndex:0]].uppercaseString];
            if (cmp.length >= 2) [string appendString:[cmp substringFromIndex:1]];
        } else {
            [string appendString:cmp];
        }
    }
    return string;
}

- (NSString *)mj_firstCharLower
{
    if (self.length == 0) return self;
    return [NSString stringWithFormat:@"%@%@", [self substringToIndex:1].lowercaseString, [self substringFromIndex:1]];
}

- (NSString *)mj_firstCharUpper
{
    if (self.length == 0) return self;
    return [NSString stringWithFormat:@"%@%@", [self substringToIndex:1].uppercaseString, [self substringFromIndex:1]];
}

- (SEL)mj_defaultSetter {
    NSString *setterName = [NSString stringWithFormat:@"set%@%@:", [self substringToIndex:1].uppercaseString, [self substringFromIndex:1]];
    return NSSelectorFromString(setterName);
}

- (BOOL)mj_isPureInt
{
    NSScanner *scan = [NSScanner scannerWithString:self];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

- (NSURL *)mj_url
{
//    [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"!$&'()*+,-./:;=?@_~%#[]"]];
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    return [NSURL URLWithString:(NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]", NULL,kCFStringEncodingUTF8))];
#pragma clang diagnostic pop
}

- (long double)mj_longDoubleValueWithLocale:(NSLocale *)locale {
    const char *str = [self cStringUsingEncoding:NSUTF8StringEncoding];
    const char *localeIdentifier = [locale.localeIdentifier cStringUsingEncoding:NSUTF8StringEncoding];
    locale_t loc = newlocale(LC_ALL_MASK, localeIdentifier, nil);
    long double num = strtold_l(str, NULL, loc);
    freelocale(loc);
    return num;
}

- (long double)mj_longDoubleValue {
    return [self mj_longDoubleValueWithLocale:nil];
}

- (NSDate *)mj_date {
    static NSArray<NSDateFormatter *> *formatters;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *_formatters = [NSMutableArray arrayWithCapacity:7];
        // Reference: https://developer.apple.com/library/archive/qa/qa1480/
        NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        
        NSArray<NSString *> *strings = @[@"yyyy-MM-dd",
                                        @"yyyy-MM-dd'T'HH:mm:ss",
                                        @"yyyy-MM-dd'T'HH:mm:ss.SSS",
                                        @"yyyy-MM-dd'T'HH:mm:ssZ",
                                        @"yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        ];
        for (NSString *formatterString in strings) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.locale = locale;
            formatter.timeZone = timeZone;
            formatter.dateFormat = formatterString;
            [_formatters addObject:formatter];
        }
        
        formatters = _formatters.copy;
    });
    /// "yyyy-MM-dd"
    /// "yyyy-MM-dd'T'HH:mm:ss"
    /// "yyyy-MM-dd'T'HH:mm:ss.SSS"
    /// "yyyy-MM-dd'T'HH:mm:ssZ"
    /// "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    typedef NS_ENUM(NSUInteger, FormatterString) {
        FormatterStringShort = 10,
        FormatterStringLong = 19,
        FormatterStringLongMSec = 23,
        FormatterStringFull = 20,
        FormatterStringFullOrMSec = 24,
        FormatterStringFull1 = 25,
        FormatterStringFullMSec = 28,
        FormatterStringFullMSec1 = 29,
    };
    NSDateFormatter *shortFormatter = formatters[0];
    NSDateFormatter *longFormatter = formatters[1];
    NSDateFormatter *longMSecFormatter = formatters[2];
    NSDateFormatter *fullFormatter = formatters[3];
    NSDateFormatter *fullMSecFormatter = formatters[4];
    switch (self.length) {
        case FormatterStringShort:
            return [shortFormatter dateFromString:self];
        case FormatterStringLong:
            return [longFormatter dateFromString:self];
        case FormatterStringLongMSec:
            return [longMSecFormatter dateFromString:self];
        case FormatterStringFull:
        case FormatterStringFull1:
            return [fullFormatter dateFromString:self];
        case FormatterStringFullOrMSec:
            return [fullFormatter dateFromString:self] ?: [fullMSecFormatter dateFromString:self];
        case FormatterStringFullMSec:
        case FormatterStringFullMSec1:
            return [fullMSecFormatter dateFromString:self];
        default: return nil;
    }
}
@end
