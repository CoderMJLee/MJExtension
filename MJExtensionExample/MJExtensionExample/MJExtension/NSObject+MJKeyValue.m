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

@implementation NSObject (MJKeyValue)
static NSNumberFormatter *_numberFormatter;
+ (void)load
{
    _numberFormatter = [[NSNumberFormatter alloc] init];
}

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
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    return [self objectWithKeyValues:dict];
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
    MJAssert2([keyValues isKindOfClass:[NSDictionary class]], );
    
    [self enumerateIvarsWithBlock:^(MJIvar *ivar, BOOL *stop) {
        // 来自Foundation框架的成员变量，直接返回
        if (ivar.isSrcClassFromFoundation) return;
        
        // 1.取出属性值
        id value = keyValues[ivar.key];
        if (!value || [value isKindOfClass:[NSNull class]]) return;
        
        // 2.如果是模型属性
        Class typeClass = ivar.type.typeClass;
        if (typeClass && !ivar.type.isFromFoundation) {
            value = [typeClass objectWithKeyValues:value];
        } else if (typeClass == [NSString class] && [value isKindOfClass:[NSNumber class]]) {
            // NSNumber -> NSString
            value = [_numberFormatter stringFromNumber:value];
        } else if (typeClass == [NSNumber class] && [value isKindOfClass:[NSString class]]) {
            // NSString -> NSNumber
            value = [_numberFormatter numberFromString:value];
        } else if (typeClass == [NSURL class] && [value isKindOfClass:[NSString class]]) {
            // NSString -> NSURL
            value = [NSURL URLWithString:value];
        } else if (typeClass == [NSString class] && [value isKindOfClass:[NSURL class]]) {
            // NSURL -> NSString
            value = [value absoluteString];
        } else if (ivar.objectClassInArray) {
            // 3.字典数组-->模型数组
            value = [ivar.objectClassInArray objectArrayWithKeyValuesArray:value];
        }
        
        // 4.赋值
        ivar.srcObject = self;
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
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
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
    MJAssert2([objectArray isKindOfClass:[NSArray class]], nil);
    
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
