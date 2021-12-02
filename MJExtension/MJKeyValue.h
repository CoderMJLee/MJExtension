//
//  MJKeyValue.h
//  MJExtension
//
//  Created by Frank on 2021/12/1.
//  Copyright © 2021 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  KeyValue协议
 */
@protocol MJKeyValue <NSObject>
@optional
/**
 *  只有这个数组中的属性名才允许进行字典和模型的转换
 */
+ (NSArray *)mj_allowedPropertyNames;

/**
 *  这个数组中的属性名将会被忽略：不进行字典和模型的转换
 */
+ (NSArray *)mj_ignoredPropertyNames;

/**
 *  将属性名换为其他key去字典中取值
 *
 *  @return 字典中的key是属性名，value是从字典中取值用的key
 */
+ (NSDictionary *)mj_replacedKeyFromPropertyName;

/**
 *  将属性名换为其他key去字典中取值
 *
 *  @return 从字典中取值用的key
 */
+ (id)mj_replacedKeyFromPropertyName121:(NSString *)propertyName;

/**
 *  数组中需要转换的模型类
 *
 *  @return 字典中的key是数组属性名，value是数组中存放模型的Class（Class类型或者NSString类型）
 */
+ (NSDictionary *)mj_objectClassInArray;


/** 特殊地区在字符串格式化数字时使用 */
+ (NSLocale *)mj_numberLocale;

/// Inherits configurations from super class or not.
/// If not configurate, default value is YES.
+ (BOOL)mj_shouldAutoInheritConfigurations;

/**
 *  旧值换新值，用于过滤字典中的值
 *
 *  @param oldValue 旧值
 *
 *  @return 新值
 */
- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property;

/**
 *  当字典转模型完毕时调用
 */
- (void)mj_keyValuesDidFinishConvertingToObject MJExtensionDeprecated("请使用`mj_didConvertToObjectWithKeyValues:`替代");
- (void)mj_keyValuesDidFinishConvertingToObject:(NSDictionary *)keyValues MJExtensionDeprecated("请使用`mj_didConvertToObjectWithKeyValues:`替代");
- (void)mj_didConvertToObjectWithKeyValues:(NSDictionary *)keyValues;

/**
 *  当模型转字典完毕时调用
 */
- (void)mj_objectDidFinishConvertingToKeyValues MJExtensionDeprecated("请使用`mj_objectDidConvertToKeyValues:`替代");
- (void)mj_objectDidConvertToKeyValues:(NSMutableDictionary *)keyValues;

@end
