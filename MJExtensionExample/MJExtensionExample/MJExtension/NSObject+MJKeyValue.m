//
//  NSObject+MJKeyValue.m
//  MJExtension
//
//  Created by mj on 13-8-24.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "NSObject+MJKeyValue.h"
#import "NSObject+MJIvar.h"
#import "MJIvar.h"
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
+ (instancetype)objectWithJSONData:(NSData *)data
{
    MJAssertParamNotNil2(data, nil);
    
    return [self objectWithKeyValues:[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil]];
}

+ (instancetype)objectWithKeyValues:(NSDictionary *)keyValues
{
    MJAssert2([keyValues isKindOfClass:[NSDictionary class]], nil);
    
    id model = [[self alloc] init];
    return [model setKeyValues:keyValues];
}

+ (instancetype)objectWithFilename:(NSString *)filename
{
    MJAssertParamNotNil2(filename, nil);
    
    return [self objectWithFile:[[NSBundle mainBundle] pathForResource:filename ofType:nil]];
}

+ (instancetype)objectWithFile:(NSString *)file
{
    MJAssertParamNotNil2(file, nil);
    
    return [self objectWithKeyValues:[NSDictionary dictionaryWithContentsOfFile:file]];
}

- (instancetype)setKeyValues:(NSDictionary *)keyValues
{
    MJAssert2([keyValues isKindOfClass:[NSDictionary class]], self);
    
    [[self class] enumerateIvarsWithBlock:^(MJIvar *ivar, BOOL *stop) {
        // 1.取出属性值
        id value = keyValues ;
        for (NSString *key in ivar.keys) {
            value = value[key];
        }
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

+ (NSArray *)objectArrayWithJSONData:(NSData *)data
{
    MJAssertParamNotNil2(data, nil);
    
    return [self objectArrayWithKeyValuesArray:[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil]];
}

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

+ (NSArray *)objectArrayWithFilename:(NSString *)filename
{
    MJAssertParamNotNil2(filename, nil);
    
    return [self objectArrayWithFile:[[NSBundle mainBundle] pathForResource:filename ofType:nil]];
}

+ (NSArray *)objectArrayWithFile:(NSString *)file
{
    MJAssertParamNotNil2(file, nil);
    
    return [self objectArrayWithKeyValuesArray:[NSArray arrayWithContentsOfFile:file]];
}

- (NSDictionary *)keyValues
{
    // 如果自己不是模型类
    if ([MJFoundation isClassFromFoundation:[self class]]) return (NSDictionary *)self;
    
    __block NSMutableDictionary *keyValues = [NSMutableDictionary dictionary];
    
    [[self class] enumerateIvarsWithBlock:^(MJIvar *ivar, BOOL *stop) {
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
        NSUInteger keyCount = ivar.keys.count;
        // 创建字典
        __block NSMutableDictionary *innerDict = keyValues;
        [ivar.keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
            if (idx == keyCount - 1) { // 最后一个属性
                innerDict[key] = value;
            } else { // 字典
                NSMutableDictionary *tempDict = innerDict[key];
                if (tempDict == nil) {
                    tempDict = [NSMutableDictionary dictionary];
                    innerDict[key] = tempDict;
                }
                innerDict = tempDict;
            }
        }];
    }];
    
    // 转换完毕
    if ([self respondsToSelector:@selector(objectDidFinishConvertingToKeyValues)]) {
        [self objectDidFinishConvertingToKeyValues];
    }
    
    return keyValues;
}

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
@end
