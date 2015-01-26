//
//  NSObject+MJKeyValue.m
//  MJExtension
//
//  Created by mj on 13-8-24.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "NSObject+MJKeyValue.h"
#import "NSObject+MJIvar.h"
#import "MJType.h"
#import "MJConst.h"
#import "MJFoundation.h"

@implementation NSObject (MJKeyValue)

#pragma mark - --常用的对象--
static NSNumberFormatter *_numberFormatter;
+ (void)load
{
    _numberFormatter = [[NSNumberFormatter alloc] init];
}

#pragma mark - --公共方法--
#pragma mark - 字典转模型
/**
 *  通过JSON数据来创建一个模型
 *  @param data JSON数据
 *  @return 新建的对象
 */
+ (instancetype)objectWithJSONData:(NSData *)data
{
    MJAssertParamNotNil2(data, nil);
    
    return [self objectWithKeyValues:[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil]];
}

/**
 *  通过字典来创建一个模型
 *  @param keyValues 字典
 *  @return 新建的对象
 */
+ (instancetype)objectWithKeyValues:(NSDictionary *)keyValues
{
    MJAssert2([keyValues isKindOfClass:[NSDictionary class]], nil);
    
    id model = [[self alloc] init];
    return [model setKeyValues:keyValues];
}

/**
 *  通过plist来创建一个模型
 *  @param filename 文件名(仅限于mainBundle中的文件)
 *  @return 新建的对象
 */
+ (instancetype)objectWithFilename:(NSString *)filename
{
    MJAssertParamNotNil2(filename, nil);
    
    return [self objectWithFile:[[NSBundle mainBundle] pathForResource:filename ofType:nil]];
}

/**
 *  通过plist来创建一个模型
 *  @param file 文件全路径
 *  @return 新建的对象
 */
+ (instancetype)objectWithFile:(NSString *)file
{
    MJAssertParamNotNil2(file, nil);
    
    return [self objectWithKeyValues:[NSDictionary dictionaryWithContentsOfFile:file]];
}

/**
 *  将字典的键值对转成模型属性
 *  @param keyValues 字典
 */
- (instancetype)setKeyValues:(NSDictionary *)keyValues
{
    MJAssert2([keyValues isKindOfClass:[NSDictionary class]], self);
    
    [self enumerateIvarsWithBlock:^(MJIvar *ivar, BOOL *stop) {
        // 1.取出属性值
        id value = keyValues[ivar.key];
        if (!value || value == [NSNull null]) return;
        
        // 2.如果是模型属性
        MJType *type = ivar.type;
        Class typeClass = type.typeClass;
        if (!type.isFromFoundation && typeClass) {
            value = [typeClass objectWithKeyValues:value];
        } else if (typeClass == [NSString class]) {
            if ([value isKindOfClass:[NSNumber class]]) {
                // NSNumber -> NSString
                value = [_numberFormatter stringFromNumber:value];
            } else if ([value isKindOfClass:[NSURL class]]) {
                // NSURL -> NSString
                value = [value absoluteString];
            }
        } else if ([value isKindOfClass:[NSString class]]) {
            if (typeClass == [NSNumber class]) {
                // NSString -> NSNumber
                value = [_numberFormatter numberFromString:value];
            } else if (typeClass == [NSURL class]) {
                // NSString -> NSURL
                value = [NSURL URLWithString:value];
            }
        } else if (ivar.objectClassInArray) {
            // 3.字典数组-->模型数组
            value = [ivar.objectClassInArray objectArrayWithKeyValuesArray:value];
        }
        
        // 4.赋值
        [ivar setValue:value forObject:self];
    }];
    
    // 转换完毕
    if ([self respondsToSelector:@selector(keyValuesDidFinishConvertingToObject)]) {
        [self keyValuesDidFinishConvertingToObject];
    }
    
    return self;
}

/**
 *  将模型转成字典
 *  @return 字典
 */
- (NSDictionary *)keyValues
{
    // 如果自己不是模型类
    if ([MJFoundation isClassFromFoundation:[self class]]) return (NSDictionary *)self;
    
    NSMutableDictionary *keyValues = [NSMutableDictionary dictionary];
    
    [self enumerateIvarsWithBlock:^(MJIvar *ivar, BOOL *stop) {
        // 1.取出属性值
        id value = [ivar valueFromObject:self];
        if (!value) return;
        
        // 2.如果是模型属性
        MJType *type = ivar.type;
        Class typeClass = type.typeClass;
        if (!type.isFromFoundation && typeClass) {
            value = [value keyValues];
        } else if (typeClass == [NSURL class]) {
            value = [value absoluteString];
        } else if (ivar.objectClassInArray) {
            // 3.处理数组里面有模型的情况
            value = [ivar.objectClassInArray keyValuesArrayWithObjectArray:value];
        }
        
        // 4.赋值
        keyValues[ivar.key] = value;
    }];
    
    // 转换完毕
    if ([self respondsToSelector:@selector(objectDidFinishConvertingToKeyValues)]) {
        [self objectDidFinishConvertingToKeyValues];
    }
    
    return keyValues;
}

/**
 *  通过JSON数据来创建一个模型数组
 *  @param data JSON数据
 *  @return 新建的对象
 */
+ (NSArray *)objectArrayWithJSONData:(NSData *)data
{
    MJAssertParamNotNil2(data, nil);
    
    return [self objectArrayWithKeyValuesArray:[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil]];
}

/**
 *  通过模型数组来创建一个字典数组
 *  @param objectArray 模型数组
 *  @return 字典数组
 */
+ (NSArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray
{
    // 0.判断真实性
    MJAssert2([objectArray isKindOfClass:[NSArray class]], nil);
    
    // 1.创建数组
    NSMutableArray *keyValuesArray = [NSMutableArray array];
    for (id object in objectArray) {
        [keyValuesArray addObject:[object keyValues]];
    }
    return keyValuesArray;
}

#pragma mark - 字典数组转模型数组
/**
 *  通过字典数组来创建一个模型数组
 *  @param keyValuesArray 字典数组
 *  @return 模型数组
 */
+ (NSArray *)objectArrayWithKeyValuesArray:(NSArray *)keyValuesArray
{
    // 1.判断真实性
    MJAssert2([keyValuesArray isKindOfClass:[NSArray class]], nil);
    
    // 2.创建数组
    NSMutableArray *modelArray = [NSMutableArray array];
    
    // 3.遍历
    for (NSDictionary *keyValues in keyValuesArray) {
        id model = [self objectWithKeyValues:keyValues];
        if (model) [modelArray addObject:model];
    }
    
    return modelArray;
}

/**
 *  通过plist来创建一个模型数组
 *  @param filename 文件名(仅限于mainBundle中的文件)
 *  @return 模型数组
 */
+ (NSArray *)objectArrayWithFilename:(NSString *)filename
{
    MJAssertParamNotNil2(filename, nil);
    
    return [self objectArrayWithFile:[[NSBundle mainBundle] pathForResource:filename ofType:nil]];
}

/**
 *  通过plist来创建一个模型数组
 *  @param file 文件全路径
 *  @return 模型数组
 */
+ (NSArray *)objectArrayWithFile:(NSString *)file
{
    MJAssertParamNotNil2(file, nil);
    
    return [self objectArrayWithKeyValuesArray:[NSArray arrayWithContentsOfFile:file]];
}

#pragma mark - --私有方法--
/**
 *  根据属性名获得对应的key
 *
 *  @param propertyName 属性名
 *
 *  @return 字典的key
 */
- (NSString *)keyWithPropertyName:(NSString *)propertyName
{
    MJAssertParamNotNil2(propertyName, nil);
    
    NSString *key = nil;
    // 1.查看有没有需要替换的key
    if ([self respondsToSelector:@selector(replacedKeyFromPropertyName)]) {
        key = self.replacedKeyFromPropertyName[propertyName];
    }
    
    // 2.用属性名作为key
    if (!key) key = propertyName;
    
    return key;
}
@end
