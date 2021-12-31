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
- (NSString *)mj_underlineFromCamel;
/**
 *  下划线转驼峰（love_you -> loveYou）
 */
- (NSString *)mj_camelFromUnderline;
/**
 * 首字母变大写
 */
- (NSString *)mj_firstCharUpper;
/**
 * 首字母变小写
 */
- (NSString *)mj_firstCharLower;

- (SEL)mj_defaultSetter;

- (BOOL)mj_isPureInt;

- (NSURL *)mj_url;

/// The same with `[self mj_longDoubleValueWithLocale:nil];`
- (long double)mj_longDoubleValue;
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
- (NSDate *)mj_date;
@end
