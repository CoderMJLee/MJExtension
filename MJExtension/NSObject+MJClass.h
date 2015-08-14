//
//  NSObject+MJClass.h
//  MJExtensionExample
//
//  Created by MJ Lee on 15/8/11.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  遍历所有类的block（父类）
 */
typedef void (^MJClassesEnumeration)(Class c, BOOL *stop);

/** 这个数组中的属性名才会进行字典和模型的转换 */
typedef NSArray * (^MJAllowedPropertyNames)();
/** 这个数组中的属性名才会进行归档 */
typedef NSArray * (^MJAllowedCodingPropertyNames)();

/** 这个数组中的属性名将会被忽略：不进行字典和模型的转换 */
typedef NSArray * (^MJIgnoredPropertyNames)();
/** 这个数组中的属性名将会被忽略：不进行归档 */
typedef NSArray * (^MJIgnoredCodingPropertyNames)();

/**
 * 类相关的扩展
 */
@interface NSObject (MJClass)
/**
 *  遍历所有的类
 */
+ (void)enumerateClasses:(MJClassesEnumeration)enumeration;
+ (void)enumerateAllClasses:(MJClassesEnumeration)enumeration;

#pragma mark - 属性白名单配置
/**
 *  这个数组中的属性名才会进行字典和模型的转换
 *
 *  @param allowedPropertyNames          这个数组中的属性名才会进行字典和模型的转换
 */
+ (void)setupAllowedPropertyNames:(MJAllowedPropertyNames)allowedPropertyNames;

/**
 *  这个数组中的属性名才会进行字典和模型的转换
 */
+ (NSMutableArray *)totalAllowedPropertyNames;

#pragma mark - 属性黑名单配置
/**
 *  这个数组中的属性名将会被忽略：不进行字典和模型的转换
 *
 *  @param ignoredPropertyNames          这个数组中的属性名将会被忽略：不进行字典和模型的转换
 */
+ (void)setupIgnoredPropertyNames:(MJIgnoredPropertyNames)ignoredPropertyNames;

/**
 *  这个数组中的属性名将会被忽略：不进行字典和模型的转换
 */
+ (NSMutableArray *)totalIgnoredPropertyNames;

#pragma mark - 归档属性白名单配置
/**
 *  这个数组中的属性名才会进行归档
 *
 *  @param allowedCodingPropertyNames          这个数组中的属性名才会进行归档
 */
+ (void)setupAllowedCodingPropertyNames:(MJAllowedCodingPropertyNames)allowedCodingPropertyNames;

/**
 *  这个数组中的属性名才会进行字典和模型的转换
 */
+ (NSMutableArray *)totalAllowedCodingPropertyNames;

#pragma mark - 归档属性黑名单配置
/**
 *  这个数组中的属性名将会被忽略：不进行归档
 *
 *  @param ignoredCodingPropertyNames          这个数组中的属性名将会被忽略：不进行归档
 */
+ (void)setupIgnoredCodingPropertyNames:(MJIgnoredCodingPropertyNames)ignoredCodingPropertyNames;

/**
 *  这个数组中的属性名将会被忽略：不进行归档
 */
+ (NSMutableArray *)totalIgnoredCodingPropertyNames;

#pragma mark - 内部使用
+ (void)setupBlockReturnValue:(id (^)())block key:(const char *)key dict:(NSMutableDictionary *)dict;
@end
