//
//  NSObject+MJProperty.h
//  MJExtensionExample
//
//  Created by MJ Lee on 15/4/17.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MJProperty;

/**
 *  遍历所有类的block（父类）
 */
typedef void (^MJClassesBlock)(Class c, BOOL *stop);

/**
 *  遍历成员变量用的block
 *
 *  @param property 成员的包装对象
 *  @param stop   YES代表停止遍历，NO代表继续遍历
 */
typedef void (^MJPropertiesBlock)(MJProperty *property, BOOL *stop);

/** 将属性名换为其他key去字典中取值 */
typedef NSDictionary * (^ReplacedKeyFromPropertyName)();
/** 数组中需要转换的模型类 */
typedef NSDictionary * (^ObjectClassInArray)();


/** 这个数组中的属性名才会进行字典和模型的转换 */
typedef NSArray * (^AllowedPropertyNames)();
/** 这个数组中的属性名才会进行归档 */
typedef NSArray * (^AllowedCodingPropertyNames)();

/** 这个数组中的属性名将会被忽略：不进行字典和模型的转换 */
typedef NSArray * (^IgnoredPropertyNames)();
/** 这个数组中的属性名将会被忽略：不进行归档 */
typedef NSArray * (^IgnoredCodingPropertyNames)();

@interface NSObject (MJProperty)

/**
 *  遍历所有的成员
 */
+ (void)enumeratePropertiesWithBlock:(MJPropertiesBlock)block;

/**
 *  遍历所有的类
 */
+ (void)enumerateClassesWithBlock:(MJClassesBlock)block;

/**
 *  配置模型属性
 *
 *  @param replacedKeyFromPropertyName 将属性名换为其他key去字典中取值
 *  @param objectClassInArray          数组中需要转换的模型类
 */
+ (void)setupReplacedKeyFromPropertyName:(ReplacedKeyFromPropertyName)replacedKeyFromPropertyName objectClassInArray:(ObjectClassInArray)objectClassInArray;

/**
 *  配置模型属性
 *
 *  @param replacedKeyFromPropertyName 将属性名换为其他key去字典中取值
 */
+ (void)setupReplacedKeyFromPropertyName:(ReplacedKeyFromPropertyName)replacedKeyFromPropertyName;

/**
 *  配置模型属性
 *
 *  @param objectClassInArray          数组中需要转换的模型类
 */
+ (void)setupObjectClassInArray:(ObjectClassInArray)objectClassInArray;

/**
 *  配置模型属性
 *
 *  @param allowedPropertyNames          这个数组中的属性名才会进行字典和模型的转换
 */
+ (void)setupAllowedPropertyNames:(AllowedPropertyNames)allowedPropertyNames;

/**
 *  这个数组中的属性名才会进行字典和模型的转换
 */
+ (NSArray *)totalAllowedPropertyNames;

/**
 *  配置模型属性
 *
 *  @param allowedCodingPropertyNames          这个数组中的属性名才会进行归档
 */
+ (void)setupAllowedCodingPropertyNames:(AllowedCodingPropertyNames)allowedCodingPropertyNames;

/**
 *  这个数组中的属性名才会进行字典和模型的转换
 */
+ (NSArray *)totalAllowedCodingPropertyNames;

/**
 *  配置模型属性
 *
 *  @param ignoredPropertyNames          这个数组中的属性名将会被忽略：不进行字典和模型的转换
 */
+ (void)setupIgnoredPropertyNames:(IgnoredPropertyNames)ignoredPropertyNames;

/**
 *  这个数组中的属性名将会被忽略：不进行字典和模型的转换
 */
+ (NSArray *)totalIgnoredPropertyNames;

/**
 *  配置模型属性
 *
 *  @param ignoredCodingPropertyNames          这个数组中的属性名将会被忽略：不进行归档
 */
+ (void)setupIgnoredCodingPropertyNames:(IgnoredCodingPropertyNames)ignoredCodingPropertyNames;

/**
 *  这个数组中的属性名将会被忽略：不进行归档
 */
+ (NSArray *)totalIgnoredCodingPropertyNames;
@end