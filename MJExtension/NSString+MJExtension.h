//
//  NSString+MJExtension.h
//  MJExtensionExample
//
//  Created by MJ Lee on 15/6/7.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MJExtension)
/**
 *  驼峰转下划线（loveYou -> love_you）
 */
- (NSString *)underlineFromCamel;
/**
 *  下划线转驼峰（love_you -> loveYou）
 */
- (NSString *)camelFromUnderline;
/**
 * 首字母变大写
 */
- (NSString *)firstCharUpper;
/**
 * 首字母变小写
 */
- (NSString *)firstCharLower;

- (BOOL)isPureInt;
@end
