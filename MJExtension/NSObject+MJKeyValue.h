//
//  NSObject+MJKeyValue.h
//  MJExtension
//
//  Created by mj on 13-8-24.
//  Copyright (c) 2013年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJConst.h"
#import <CoreData/CoreData.h>
#import "MJProperty.h"

/**
 *  KeyValue协议
 */
@protocol MJKeyValue <NSObject>
@optional
/**
 *  只有这个数组中的属性名才允许进行字典和模型的转换
 */
+ (NSArray *)allowedPropertyNames;

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

/**
 *  将属性名换为其他key去字典中取值
 *
 *  @return 从字典中取值用的key
 */
+ (NSString *)replacedKeyFromPropertyName121:(NSString *)propertyName;

/**
 *  数组中需要转换的模型类
 *
 *  @return 字典中的key是数组属性名，value是数组中存放模型的Class（Class类型或者NSString类型）
 */
+ (NSDictionary *)objectClassInArray;

/**
 *  旧值换新值，用于过滤字典中的值
 *
 *  @param oldValue 旧值
 *
 *  @return 新值
 */
- (id)newValueFromOldValue:(id)oldValue property:(MJProperty *)property;

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
 *  模型转字典时，字典的key是否参考replacedKeyFromPropertyName等方法
 */
+ (void)referenceReplacedKeyWhenCreatingKeyValues:(BOOL)reference;
+ (BOOL)isReferenceReplacedKeyWhenCreatingKeyValues;

/**
 *  将模型转成字典
 *  @return 字典
 */
- (NSMutableDictionary *)keyValues;
- (NSMutableDictionary *)keyValuesWithKeys:(NSArray *)keys;
- (NSMutableDictionary *)keyValuesWithIgnoredKeys:(NSArray *)ignoredKeys;
- (NSMutableDictionary *)keyValuesWithError:(NSError **)error;
- (NSMutableDictionary *)keyValuesWithKeys:(NSArray *)keys error:(NSError **)error;
- (NSMutableDictionary *)keyValuesWithIgnoredKeys:(NSArray *)ignoredKeys error:(NSError **)error;

/**
 *  通过模型数组来创建一个字典数组
 *  @param objectArray 模型数组
 *  @return 字典数组
 */
+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray;
+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray keys:(NSArray *)keys;
+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray ignoredKeys:(NSArray *)ignoredKeys;
+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray error:(NSError **)error;
+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray keys:(NSArray *)keys error:(NSError **)error;
+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray ignoredKeys:(NSArray *)ignoredKeys error:(NSError **)error;

#pragma mark - 字典转模型
/**
 *  通过字典来创建一个模型
 *  @param keyValues 字典(可以是NSDictionary、NSData、NSString)
 *  @return 新建的对象
 */
+ (instancetype)objectWithKeyValues:(id)keyValues;
+ (instancetype)objectWithKeyValues:(id)keyValues error:(NSError **)error;

/**
 *  通过字典来创建一个CoreData模型
 *  @param keyValues 字典(可以是NSDictionary、NSData、NSString)
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
 *  通过字典数组来创建一个模型数组
 *  @param keyValuesArray 字典数组(可以是NSDictionary、NSData、NSString)
 *  @return 模型数组
 */
+ (NSMutableArray *)objectArrayWithKeyValuesArray:(id)keyValuesArray;
+ (NSMutableArray *)objectArrayWithKeyValuesArray:(id)keyValuesArray error:(NSError **)error;

/**
 *  通过字典数组来创建一个模型数组
 *  @param keyValuesArray 字典数组(可以是NSDictionary、NSData、NSString)
 *  @param context        CoreData上下文
 *  @return 模型数组
 */
+ (NSMutableArray *)objectArrayWithKeyValuesArray:(id)keyValuesArray context:(NSManagedObjectContext *)context;
+ (NSMutableArray *)objectArrayWithKeyValuesArray:(id)keyValuesArray context:(NSManagedObjectContext *)context error:(NSError **)error;

/**
 *  通过plist来创建一个模型数组
 *  @param filename 文件名(仅限于mainBundle中的文件)
 *  @return 模型数组
 */
+ (NSMutableArray *)objectArrayWithFilename:(NSString *)filename;
+ (NSMutableArray *)objectArrayWithFilename:(NSString *)filename error:(NSError **)error;

/**
 *  通过plist来创建一个模型数组
 *  @param file 文件全路径
 *  @return 模型数组
 */
+ (NSMutableArray *)objectArrayWithFile:(NSString *)file;
+ (NSMutableArray *)objectArrayWithFile:(NSString *)file error:(NSError **)error;

#pragma mark - 转换为JSON
- (NSData *)JSONData;
- (id)JSONObject;
- (NSString *)JSONString;
@end
