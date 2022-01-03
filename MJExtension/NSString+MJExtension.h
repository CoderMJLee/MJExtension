//
//  NSString+MJExtension.h
//  MJExtensionExample
//
//  Created by MJ Lee on 15/6/7.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtensionConst.h"

@interface NSString (MJExtension)
/**
 *  驼峰转下划线（loveYou -> love_you）
 */
@property (nonatomic, readonly) NSString *mj_underlineFromCamel;
/**
 *  下划线转驼峰（love_you -> loveYou）
 */
@property (nonatomic, readonly) NSString *mj_camelFromUnderline;
/**
 * 首字母变大写
 */
@property (nonatomic, readonly) NSString *mj_firstCharUpper;
/**
 * 首字母变小写
 */
@property (nonatomic, readonly) NSString *mj_firstCharLower;

@property (nonatomic, readonly) SEL mj_defaultSetter;

@property (nonatomic, readonly) BOOL mj_isPureInt;

@property (nonatomic, readonly) NSURL *mj_url;

/// The same with `[self mj_longDoubleValueWithLocale:nil];`
@property (nonatomic, readonly) long double mj_longDoubleValue;
/// Use `strtold_l` method to convert the string.
/// @param locale maybe Franch number need this.
- (long double)mj_longDoubleValueWithLocale:(NSLocale *)locale;

/// Convert `String` to `Date`
/// @discussion Following formatters are recognized.
/// @code
/// "yyyy-MM-dd"
/// "yyyy-MM-dd'T'HH:mm:ss"
/// "yyyy-MM-dd'T'HH:mm:ss.SSS"
/// "yyyy-MM-dd'T'HH:mm:ssZ"
/// "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
/// @endcode
@property (nonatomic, readonly) NSDate *mj_date;

- (double)mj_doubleValueWithLocale:(NSLocale *)locale;
@property (nonatomic, readonly) double mj_doubleValue;
@end
