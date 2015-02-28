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
    return [self objectWithJSONData:data error:nil];
}

+ (instancetype)objectWithJSONData:(NSData *)data error:(NSError *__autoreleasing *)error
{
    MJAssertError(data != nil, nil, error, @"JSONData参数为nil");
    
    return [self objectWithKeyValues:[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil] error:error];
}

+ (instancetype)objectWithKeyValues:(NSDictionary *)keyValues
{
    return [self objectWithKeyValues:keyValues error:nil];
}

+ (instancetype)objectWithKeyValues:(NSDictionary *)keyValues error:(NSError *__autoreleasing *)error
{
    return [[[self alloc] init] setKeyValues:keyValues error:error];
}

+ (instancetype)objectWithFilename:(NSString *)filename
{
    return [self objectWithFilename:filename error:nil];
}

+ (instancetype)objectWithFilename:(NSString *)filename error:(NSError *__autoreleasing *)error
{
    MJAssertError(filename != nil, nil, error, @"filename参数为nil");
    
    return [self objectWithFile:[[NSBundle mainBundle] pathForResource:filename ofType:nil] error:error];
}

+ (instancetype)objectWithFile:(NSString *)file
{
    return [self objectWithFile:file error:nil];
}

+ (instancetype)objectWithFile:(NSString *)file error:(NSError *__autoreleasing *)error
{
    MJAssertError(file != nil, nil, error, @"file参数为nil");
    
    return [self objectWithKeyValues:[NSDictionary dictionaryWithContentsOfFile:file] error:error];
}

- (instancetype)setKeyValues:(NSDictionary *)keyValues
{
    return [self setKeyValues:keyValues error:nil];
}

- (instancetype)setKeyValues:(NSDictionary *)keyValues error:(NSError *__autoreleasing *)error
{
    MJAssertError([keyValues isKindOfClass:[NSDictionary class]], self, error, @"keyValues参数不是一个字典");
    
    @try {
        NSArray *ignoredPropertyNames = nil;
        if ([[self class] respondsToSelector:@selector(ignoredPropertyNames)]) {
            ignoredPropertyNames = [[self class] ignoredPropertyNames];
        }
        
        [[self class] enumerateIvarsWithBlock:^(MJIvar *ivar, BOOL *stop) {
            // 0.检测是否被忽略
            if ([ignoredPropertyNames containsObject:ivar.propertyName]) return;
            
            // 1.取出属性值
            id value = keyValues ;
            NSArray *keys = [ivar keysFromClass:[self class]];
            for (NSString *key in keys) {
                if (![value isKindOfClass:[NSDictionary class]]) continue;
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
                    value = [value description];
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
            } else {
                Class objectClass = [ivar objectClassInArrayFromClass:[self class]];
                if (objectClass) {
                    // 3.字典数组-->模型数组
                    value = [objectClass objectArrayWithKeyValuesArray:value];
                }
            }
            
            // 4.赋值
            [ivar setValue:value forObject:self];
        }];
        
        // 转换完毕
        if ([self respondsToSelector:@selector(keyValuesDidFinishConvertingToObject)]) {
            [self keyValuesDidFinishConvertingToObject];
        }
    } @catch (NSException *exception) {
        MJBuildError(error, exception.reason);
    }
    return self;
}

+ (NSArray *)objectArrayWithJSONData:(NSData *)data
{
    return [self objectArrayWithJSONData:data error:nil];
}

+ (NSArray *)objectArrayWithJSONData:(NSData *)data error:(NSError *__autoreleasing *)error
{
    MJAssertError(data != nil, nil, error, @"JSONData参数为nil");
    
    return [self objectArrayWithKeyValuesArray:[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil] error:error];
}

+ (NSArray *)objectArrayWithKeyValuesArray:(NSArray *)keyValuesArray
{
    return [self objectArrayWithKeyValuesArray:keyValuesArray error:nil];
}

+ (NSArray *)objectArrayWithKeyValuesArray:(NSArray *)keyValuesArray error:(NSError *__autoreleasing *)error
{
    // 1.判断真实性
    MJAssertError([keyValuesArray isKindOfClass:[NSArray class]], nil, error, @"keyValuesArray参数不是一个数组");
    
    // 2.创建数组
    NSMutableArray *modelArray = [NSMutableArray array];
    
    // 3.遍历
    for (NSDictionary *keyValues in keyValuesArray) {
        id model = [self objectWithKeyValues:keyValues error:error];
        if (model) [modelArray addObject:model];
    }
    
    return modelArray;
}

+ (NSArray *)objectArrayWithFilename:(NSString *)filename
{
    return [self objectArrayWithFilename:filename error:nil];
}

+ (NSArray *)objectArrayWithFilename:(NSString *)filename error:(NSError *__autoreleasing *)error
{
    MJAssertError(filename != nil, nil, error, @"filename参数为nil");
    
    return [self objectArrayWithFile:[[NSBundle mainBundle] pathForResource:filename ofType:nil] error:error];
}

+ (NSArray *)objectArrayWithFile:(NSString *)file
{
    return [self objectArrayWithFile:file error:nil];
}

+ (NSArray *)objectArrayWithFile:(NSString *)file error:(NSError *__autoreleasing *)error
{
    MJAssertError(file != nil, nil, error, @"file参数为nil");
    
    return [self objectArrayWithKeyValuesArray:[NSArray arrayWithContentsOfFile:file] error:error];
}

- (NSDictionary *)keyValues
{
    return [self keyValuesWithError:nil];
}

- (NSDictionary *)keyValuesWithError:(NSError *__autoreleasing *)error
{
    // 如果自己不是模型类
    if ([MJFoundation isClassFromFoundation:[self class]]) return (NSDictionary *)self;
    
    __block NSMutableDictionary *keyValues = [NSMutableDictionary dictionary];
    
    @try {
        NSArray *ignoredPropertyNames = nil;
        if ([[self class] respondsToSelector:@selector(ignoredPropertyNames)]) {
            ignoredPropertyNames = [[self class] ignoredPropertyNames];
        }
        
        [[self class] enumerateIvarsWithBlock:^(MJIvar *ivar, BOOL *stop) {
            // 0.检测是否被忽略
            if ([ignoredPropertyNames containsObject:ivar.propertyName]) return;
            
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
            } else {
                Class objectClass = [ivar objectClassInArrayFromClass:[self class]];
                if (objectClass) {
                    // 3.处理数组里面有模型的情况
                    value = [objectClass keyValuesArrayWithObjectArray:value];
                }
            }
            
            // 4.赋值
            NSArray *keys = [ivar keysFromClass:[self class]];
            NSUInteger keyCount = keys.count;
            // 创建字典
            __block NSMutableDictionary *innerDict = keyValues;
            [keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
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
    } @catch (NSException *exception) {
        MJBuildError(error, exception.reason);
    }
    
    return keyValues;
}

+ (NSArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray
{
    return [self keyValuesArrayWithObjectArray:objectArray error:nil];
}

+ (NSArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray error:(NSError *__autoreleasing *)error
{
    // 0.判断真实性
    MJAssertError([objectArray isKindOfClass:[NSArray class]], nil, error, @"objectArray参数不是一个数组");
    
    // 1.创建数组
    NSMutableArray *keyValuesArray = [NSMutableArray array];
    for (id object in objectArray) {
        [keyValuesArray addObject:[object keyValuesWithError:error]];
    }
    return keyValuesArray;
}
@end
