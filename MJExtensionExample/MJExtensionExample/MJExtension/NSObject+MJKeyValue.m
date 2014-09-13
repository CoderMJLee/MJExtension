//
//  NSObject+MJKeyValue.m
//  MJExtension
//
//  Created by mj on 13-8-24.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "NSObject+MJKeyValue.h"
#import "NSObject+MJMember.h"
#import "MJConst.h"

@implementation NSObject (MJKeyValue)
#pragma mark - 公共方法
#pragma mark - 字典转模型
/**
 *  通过JSON数据来创建一个模型
 *  @param data JSON数据
 *  @return 新建的对象
 */
+ (instancetype)objectWithJSONData:(NSData *)data
{
    MJAssertParamNotNil2(data, nil);
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    return [self objectWithKeyValues:dict];
}

/**
 *  通过字典来创建一个模型
 *  @param keyValues 字典
 *  @return 新建的对象
 */
+ (instancetype)objectWithKeyValues:(NSDictionary *)keyValues
{
    NSString *desc = [NSString stringWithFormat:@"keyValues is not a NSDictionary - keyValues参数不是一个字典, keyValues is a %@ - keyValues参数是一个%@", keyValues.class, keyValues.class];
    MJAssert2([keyValues isKindOfClass:[NSDictionary class]], desc, nil);
    
    id model = [[self alloc] init];
    [model setKeyValues:keyValues];
    return model;
}

/**
 *  通过plist来创建一个模型
 *  @param filename 文件名(仅限于mainBundle中的文件)
 *  @return 新建的对象
 */
+ (instancetype)objectWithFilename:(NSString *)filename
{
    MJAssertParamNotNil2(filename, nil);
    NSString *file = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
    return [self objectWithFile:file];
}

/**
 *  通过plist来创建一个模型
 *  @param file 文件全路径
 *  @return 新建的对象
 */
+ (instancetype)objectWithFile:(NSString *)file
{
    MJAssertParamNotNil2(file, nil);
    NSDictionary *keyValues = [NSDictionary dictionaryWithContentsOfFile:file];
    return [self objectWithKeyValues:keyValues];
}

/**
 *  将字典的键值对转成模型属性
 *  @param keyValues 字典
 */
- (void)setKeyValues:(NSDictionary *)keyValues
{
    NSString *desc = [NSString stringWithFormat:@"keyValues is not a NSDictionary - keyValues参数不是一个字典, keyValues is a %@ - keyValues参数是一个%@", keyValues.class, keyValues.class];
    MJAssert2([keyValues isKindOfClass:[NSDictionary class]], desc, );
    
    [self enumerateIvarsWithBlock:^(MJIvar *ivar, BOOL *stop) {
        // 来自Foundation框架的成员变量，直接返回
        if (ivar.isSrcClassFromFoundation) return;
        
        // 1.取出属性值
        NSString *key = [self keyWithPropertyName:ivar.propertyName];
        id value = keyValues[key];
        if (!value || [value isKindOfClass:[NSNull class]]) return;
        
        // 2.如果是模型属性
        if (ivar.type.typeClass && !ivar.type.isFromFoundation) {
            value = [ivar.type.typeClass objectWithKeyValues:value];
        } else if (ivar.type.typeClass == [NSString class] && [value isKindOfClass:[NSNumber class]]) {
            // NSNumber -> NSString
            NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
            value = [fmt stringFromNumber:value];
        } else if (ivar.type.typeClass == [NSNumber class] && [value isKindOfClass:[NSString class]]) {
            // NSString -> NSNumber
            NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
            value = [fmt numberFromString:value];
        } else if (ivar.type.typeClass == [NSURL class] && [value isKindOfClass:[NSString class]]) {
            // NSString -> NSURL
            value = [NSURL URLWithString:value];
        } else if (ivar.type.typeClass == [NSString class] && [value isKindOfClass:[NSURL class]]) {
            // NSURL -> NSString
            value = [value absoluteString];
        } else if ([self respondsToSelector:@selector(objectClassInArray)]) {
            // 3.字典数组-->模型数组
            Class objectClass = self.objectClassInArray[ivar.propertyName];
            if (objectClass) {
                value = [objectClass objectArrayWithKeyValuesArray:value];
            }
        }
        
        // 4.赋值
        ivar.value = value;
    }];
    
    // 转换完毕
    if ([self respondsToSelector:@selector(keyValuesDidFinishConvertingToObject)]) {
        [self keyValuesDidFinishConvertingToObject];
    }
}

/**
 *  将模型转成字典
 *  @return 字典
 */
- (NSDictionary *)keyValues
{
    NSMutableDictionary *keyValues = [NSMutableDictionary dictionary];
    
    [self enumerateIvarsWithBlock:^(MJIvar *ivar, BOOL *stop) {
        if (ivar.isSrcClassFromFoundation) return;
        
        // 1.取出属性值
        id value = ivar.value;
        if (!value) return;
        
        // 2.如果是模型属性
        if (ivar.type.typeClass && !ivar.type.isFromFoundation) {
            value = [value keyValues];
        } else if (ivar.type.typeClass == [NSURL class]) {
            value = [value absoluteString];
        } else if ([self respondsToSelector:@selector(objectClassInArray)]) {
            // 3.处理数组里面有模型的情况
            Class objectClass = self.objectClassInArray[ivar.propertyName];
            if (objectClass) {
                value = [objectClass keyValuesArrayWithObjectArray:value];
            }
        }
        
        // 4.赋值
        NSString *key = [self keyWithPropertyName:ivar.propertyName];
        keyValues[key] = value;
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
    
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    return [self objectArrayWithKeyValuesArray:array];
}

/**
 *  通过模型数组来创建一个字典数组
 *  @param objectArray 模型数组
 *  @return 字典数组
 */
+ (NSArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray
{
    // 0.判断真实性
    NSString *desc = [NSString stringWithFormat:@"objectArray is not a NSArray - objectArray不是一个数组, objectArray is a %@ - objectArray参数是一个%@", objectArray.class, objectArray.class];
    MJAssert2([objectArray isKindOfClass:[NSArray class]], desc, nil);
    
    // 1.过滤
    if (![objectArray isKindOfClass:[NSArray class]]) return objectArray;
    if (![[objectArray lastObject] isKindOfClass:self]) return objectArray;
    
    // 2.创建数组
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
    NSString *desc = [NSString stringWithFormat:@"keyValuesArray is not a keyValuesArray - keyValuesArray不是一个数组, keyValuesArray is a %@ - keyValuesArray参数是一个%@", keyValuesArray.class, keyValuesArray.class];
    MJAssert2([keyValuesArray isKindOfClass:[NSArray class]], desc, nil);
    
    // 2.创建数组
    NSMutableArray *modelArray = [NSMutableArray array];
    
    // 3.遍历
    for (NSDictionary *keyValues in keyValuesArray) {
        if (![keyValues isKindOfClass:[NSDictionary class]]) continue;
        
        id model = [self objectWithKeyValues:keyValues];
        [modelArray addObject:model];
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
    NSString *file = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
    return [self objectArrayWithFile:file];
}

/**
 *  通过plist来创建一个模型数组
 *  @param file 文件全路径
 *  @return 模型数组
 */
+ (NSArray *)objectArrayWithFile:(NSString *)file
{
    MJAssertParamNotNil2(file, nil);
    NSArray *keyValuesArray = [NSArray arrayWithContentsOfFile:file];
    return [self objectArrayWithKeyValuesArray:keyValuesArray];
}

#pragma mark - 私有方法
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
