//
//  NSString+MJExtension.h
//  MJExtensionExample
//
//  Created by MJ Lee on 15/6/7.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtensionPredefine.h"

@interface NSString (MJExtension)

/// From camel style to underline. (loveYou -> love_you)
@property (nonatomic, readonly) NSString *mj_underlineFromCamel;
/// From underline style to camel . (love_you -> loveYou)
@property (nonatomic, readonly) NSString *mj_camelFromUnderline;
/// First character becomes upper case.
@property (nonatomic, readonly) NSString *mj_firstCharUpper;
/// First character becomes lower case.
@property (nonatomic, readonly) NSString *mj_firstCharLower;

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

/// Convert string to double value based on locale.
/// @param locale locale should be considered
/// @discussion 100,3 is 100.3 in French.
///
/// 100,3 will be parsed as 100 by default. 100ab3 will be parsed as 100 by default.
- (double)mj_doubleValueWithLocale:(NSLocale *)locale;
/// Convert string to double value
/// @discussion 100,3 will be parsed as 100 by default. 100ab3 will be parsed as 100 by default.
@property (nonatomic, readonly) double mj_doubleValue;
@end
