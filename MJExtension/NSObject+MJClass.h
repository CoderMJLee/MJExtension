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

/** 这个数组中的属性名才会进行JSON序列化 */
typedef NSArray * (^MJJSONSerializationPropertyNames)();
/** 这个数组中的属性名才会序列化到object中 */
typedef NSArray * (^MJObjectMappingPropertyNames)();

/** 这个数组中的属性名会被忽略：不会进行JSON序列化 */
typedef NSArray * (^MJIgnoredJSONSerializationPropertyNames)();
/** 这个数组中的属性名会被忽略：才会序列化到object中 */
typedef NSArray * (^MJIgnoredObjectMappingPropertyNames)();

/**
 * 类相关的扩展
 */
@interface NSObject (MJClass)
/**
 *  遍历所有的类
 */
+ (void)mj_enumerateClasses:(MJClassesEnumeration)enumeration;
+ (void)mj_enumerateAllClasses:(MJClassesEnumeration)enumeration;

#pragma mark - 属性白名单配置
/**
 *  这个数组中的属性名才会进行字典和模型的转换
 *
 *  @param allowedPropertyNames          这个数组中的属性名才会进行字典和模型的转换
 */
+ (void)mj_setupAllowedPropertyNames:(MJAllowedPropertyNames)allowedPropertyNames;

/**
 *  这个数组中的属性名才会进行字典和模型的转换
 */
+ (NSMutableArray *)mj_totalAllowedPropertyNames;

#pragma mark - 属性黑名单配置
/**
 *  这个数组中的属性名将会被忽略：不进行字典和模型的转换
 *
 *  @param ignoredPropertyNames          这个数组中的属性名将会被忽略：不进行字典和模型的转换
 */
+ (void)mj_setupIgnoredPropertyNames:(MJIgnoredPropertyNames)ignoredPropertyNames;

/**
 *  这个数组中的属性名将会被忽略：不进行字典和模型的转换
 */
+ (NSMutableArray *)mj_totalIgnoredPropertyNames;

#pragma mark - 归档属性白名单配置
/**
 *  这个数组中的属性名才会进行归档
 *
 *  @param allowedCodingPropertyNames          这个数组中的属性名才会进行归档
 */
+ (void)mj_setupAllowedCodingPropertyNames:(MJAllowedCodingPropertyNames)allowedCodingPropertyNames;

/**
 *  这个数组中的属性名才会进行字典和模型的转换
 */
+ (NSMutableArray *)mj_totalAllowedCodingPropertyNames;

#pragma mark - 归档属性黑名单配置
/**
 *  这个数组中的属性名将会被忽略：不进行归档
 *
 *  @param ignoredCodingPropertyNames          这个数组中的属性名将会被忽略：不进行归档
 */
+ (void)mj_setupIgnoredCodingPropertyNames:(MJIgnoredCodingPropertyNames)ignoredCodingPropertyNames;

/**
 *  这个数组中的属性名将会被忽略：不进行归档
 */
+ (NSMutableArray *)mj_totalIgnoredCodingPropertyNames;

#pragma mark - 序列化映射白名单配置
/**
 *  这个数组中的属性名才会进行JSON序列化
 *
 *  @param ignoredCodingPropertyNames          这个数组中的属性名将会被忽略：不进行归档
 */
+ (void)mj_setupJSONSerializationPropertyNames:(MJJSONSerializationPropertyNames)jsonSerializationPropertyNames;

/**
 *  这个数组中的属性名将会被忽略：不进行归档
 */
+ (NSMutableArray *)mj_totalJSONSerializationPropertyNames;
/**
 *  这个数组中的属性名才会序列化到object中
 *
 *  @param ignoredCodingPropertyNames          这个数组中的属性名将会被忽略：不进行归档
 */
+ (void)mj_setupObjectMappingPropertyNames:(MJObjectMappingPropertyNames)objectMappingPropertyNames;

/**
 *  这个数组中的属性名才会序列化到object中
 */
+ (NSMutableArray *)mj_totalObjectMappingPropertyNames;

#pragma mark - 序列化黑名单配置

/**
 * 这个数组中的属性名会被忽略：不会序列化到object中
*/
+ (void)mj_setupIgnoreObjectMappingPropertyNames:(MJIgnoredObjectMappingPropertyNames)ignoredObjectMappingPropertyNames;

/**
 * 这个数组中的属性名会被忽略：不会序列化到object中
 */
+ (NSMutableArray *)mj_totalIgnoredObjectMappingPropertyNames;

/*
 * 这个数组中的属性名会被忽略：不会进行JSON序列化
 */
+ (void)mj_setupIgnoredJSONSerializationPropertyNames:(MJIgnoredJSONSerializationPropertyNames)ignoredJSONSerializationPropertyNames;

/*
 * 这个数组中的属性名会被忽略：不会进行JSON序列化 
 */
+ (NSMutableArray *)mj_totalIgnoredJSONSerializationPropertyNames;

#pragma mark - 内部使用
+ (void)mj_setupBlockReturnValue:(id (^)())block key:(const char *)key;
@end
