//
//  NSObject+MJKeyValue.h
//  MJExtension
//
//  Created by mj on 13-8-24.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJConst.h"
#import <CoreData/CoreData.h>

/**
 *  KeyValue协议
 */
@protocol MJKeyValue <NSObject>
@optional
/**
 *  这个数组中的属性名将会被忽略：不进行字典和模型的转换
 */
+ (NSArray *)ignoredPropertyNames;

/**
 *  将属性名换为其他key去字典中取值
 *
 *  @return 字典中的key是属性名，value是从字典中取值用的key
 */
+ (NSDictionary *)replacedKeyFromPropertyName;
- (NSDictionary *)replacedKeyFromPropertyName MJDeprecated("请使用+ (NSDictionary *)replacedKeyFromPropertyName方法");

/**
 *  将属性名换为其他key去字典中取值
 *  @param propertyName 属性名
 *
 *  @return 字典中的key
 */
+ (NSString *)replacedKeyFromPropertyName:(NSString *)propertyName;
// 方法优先级：replacedKeyFromPropertyName: > replacedKeyFromPropertyName

/**
 *  数组中需要转换的模型类
 *
 *  @return 字典中的key是数组属性名，value是数组中存放模型的Class（Class类型或者NSString类型）
 */
+ (NSDictionary *)objectClassInArray;
- (NSDictionary *)objectClassInArray MJDeprecated("请使用+ (NSDictionary *)objectClassInArray方法");
/**
 *  数组中需要转换的模型类
 *
 *  @return 数组中存放模型的Class
 */
+ (Class)objectClassInArray:(NSString *)propertyName;
// 方法优先级：objectClassInArray: > objectClassInArray

/**
 *  当字典转模型完毕时调用
 */
- (void)keyValuesDidFinishConvertingToObject;

/**
 *  当模型转字典完毕时调用
 */
- (void)objectDidFinishConvertingToKeyValues;
@end

@interface NSObject (MJKeyValue) <MJKeyValue>
/**
 *  将字典的键值对转成模型属性
 *  @param keyValues 字典
 */
- (instancetype)setKeyValues:(id)keyValues;
- (instancetype)setKeyValues:(id)keyValues error:(NSError **)error;

/**
 *  将字典的键值对转成模型属性
 *  @param keyValues 字典
 *  @param context   CoreData上下文
 */
- (instancetype)setKeyValues:(id)keyValues context:(NSManagedObjectContext *)context;
- (instancetype)setKeyValues:(id)keyValues context:(NSManagedObjectContext *)context error:(NSError **)error;

/**
 *  将模型转成字典
 *  @return 字典
 */
- (NSDictionary *)keyValues;
- (NSDictionary *)keyValuesWithError:(NSError **)error;

/**
 *  通过模型数组来创建一个字典数组
 *  @param objectArray 模型数组
 *  @return 字典数组
 */
+ (NSArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray;
+ (NSArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray error:(NSError **)error;

#pragma mark - 字典转模型
/**
 *  通过JSON数据来创建一个模型
 *  @param data JSON数据
 *  @return 新建的对象
 */
+ (instancetype)objectWithJSONData:(NSData *)data;
+ (instancetype)objectWithJSONData:(NSData *)data error:(NSError **)error;

/**
 *  通过字典来创建一个模型
 *  @param keyValues 字典
 *  @return 新建的对象
 */
+ (instancetype)objectWithKeyValues:(id)keyValues;
+ (instancetype)objectWithKeyValues:(id)keyValues error:(NSError **)error;

/**
 *  通过字典来创建一个CoreData模型
 *  @param keyValues 字典
 *  @param context   CoreData上下文
 *  @return 新建的对象
 */
+ (instancetype)objectWithKeyValues:(id)keyValues context:(NSManagedObjectContext *)context;
+ (instancetype)objectWithKeyValues:(id)keyValues context:(NSManagedObjectContext *)context error:(NSError **)error;

/**
 *  通过plist来创建一个模型
 *  @param filename 文件名(仅限于mainBundle中的文件)
 *  @return 新建的对象
 */
+ (instancetype)objectWithFilename:(NSString *)filename;
+ (instancetype)objectWithFilename:(NSString *)filename error:(NSError **)error;

/**
 *  通过plist来创建一个模型
 *  @param file 文件全路径
 *  @return 新建的对象
 */
+ (instancetype)objectWithFile:(NSString *)file;
+ (instancetype)objectWithFile:(NSString *)file error:(NSError **)error;

#pragma mark - 字典数组转模型数组
/**
 *  通过JSON数据来创建一个模型数组
 *  @param data JSON数据
 *  @return 新建的对象
 */
+ (NSArray *)objectArrayWithJSONData:(NSData *)data;
+ (NSArray *)objectArrayWithJSONData:(NSData *)data error:(NSError **)error;

/**
 *  通过字典数组来创建一个模型数组
 *  @param keyValuesArray 字典数组
 *  @return 模型数组
 */
+ (NSArray *)objectArrayWithKeyValuesArray:(id)keyValuesArray;
+ (NSArray *)objectArrayWithKeyValuesArray:(id)keyValuesArray error:(NSError **)error;

/**
 *  通过字典数组来创建一个模型数组
 *  @param keyValuesArray 字典数组
 *  @param context        CoreData上下文
 *  @return 模型数组
 */
+ (NSArray *)objectArrayWithKeyValuesArray:(id)keyValuesArray context:(NSManagedObjectContext *)context;
+ (NSArray *)objectArrayWithKeyValuesArray:(id)keyValuesArray context:(NSManagedObjectContext *)context error:(NSError **)error;

/**
 *  通过plist来创建一个模型数组
 *  @param filename 文件名(仅限于mainBundle中的文件)
 *  @return 模型数组
 */
+ (NSArray *)objectArrayWithFilename:(NSString *)filename;
+ (NSArray *)objectArrayWithFilename:(NSString *)filename error:(NSError **)error;

/**
 *  通过plist来创建一个模型数组
 *  @param file 文件全路径
 *  @return 模型数组
 */
+ (NSArray *)objectArrayWithFile:(NSString *)file;
+ (NSArray *)objectArrayWithFile:(NSString *)file error:(NSError **)error;
@end
