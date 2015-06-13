//
//  NSObject+MJKeyValue.m
//  MJExtension
//
//  Created by mj on 13-8-24.
//  Copyright (c) 2013年 小码哥. All rights reserved.
//

#import "NSObject+MJKeyValue.h"
#import "NSObject+MJProperty.h"
#import "MJProperty.h"
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
#pragma mark - 字典 -> 模型
+ (instancetype)objectWithKeyValues:(id)keyValues
{
    return [self objectWithKeyValues:keyValues error:nil];
}

+ (instancetype)objectWithKeyValues:(id)keyValues error:(NSError *__autoreleasing *)error
{
    return [self objectWithKeyValues:keyValues context:nil error:error];
}

+ (instancetype)objectWithKeyValues:(id)keyValues context:(NSManagedObjectContext *)context
{
    return [self objectWithKeyValues:keyValues context:context error:nil];
}

+ (instancetype)objectWithKeyValues:(id)keyValues context:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error
{
    if (keyValues == nil) return nil;
    if ([self isSubclassOfClass:[NSManagedObject class]] && context) {
        return [[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:context] setKeyValues:keyValues context:context error:error];
    }
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

- (instancetype)setKeyValues:(id)keyValues
{
    return [self setKeyValues:keyValues error:nil];
}

- (instancetype)setKeyValues:(id)keyValues error:(NSError *__autoreleasing *)error
{
    return [self setKeyValues:keyValues context:nil error:error];
}

- (instancetype)setKeyValues:(id)keyValues context:(NSManagedObjectContext *)context
{
    return [self setKeyValues:keyValues context:context error:nil];
}

/**
 核心代码：
 */
- (instancetype)setKeyValues:(id)keyValues context:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error
{
    // 如果是JSON字符串
    if ([keyValues isKindOfClass:[NSString class]]) {
        keyValues = [((NSString *)keyValues) JSONObject];
    } else if ([keyValues isKindOfClass:[NSData class]]) {
        keyValues = [NSJSONSerialization JSONObjectWithData:keyValues options:kNilOptions error:nil];
    }
    
    MJAssertError([keyValues isKindOfClass:[NSDictionary class]], self, error, @"keyValues参数不是一个字典");
    
    @try {
        Class aClass = [self class];
        NSArray *allowedPropertyNames = [aClass totalAllowedPropertyNames];
        NSArray *ignoredPropertyNames = [aClass totalIgnoredPropertyNames];
        
        //通过封装的方法回调一个通过运行时编写的，用于返回属性列表的方法。
        [aClass enumerateProperties:^(MJProperty *property, BOOL *stop) {
            // 0.检测是否被忽略
            if (allowedPropertyNames.count && ![allowedPropertyNames containsObject:property.name]) return;
            if ([ignoredPropertyNames containsObject:property.name]) return;
            
            // 1.取出属性值
            id value = keyValues ;
            NSArray *keys = [property keysFromClass:[self class]];
            for (NSString *key in keys) {
                if (![value isKindOfClass:[NSDictionary class]]) continue;
                value = value[key];
            }
            
            // 值的过滤
            if ([self respondsToSelector:@selector(newValueFromOldValue:property:)]) {
                value = [self newValueFromOldValue:value property:property];
            } else {
                id newValue = [aClass getNewValueFormOldValue:value object:self property:property];
                if (newValue) value = newValue;
            }
            
            if (!value || value == [NSNull null]) return;
                
            // 2.如果是模型属性
            MJType *type = property.type;
            Class typeClass = type.typeClass;
            Class objectClass = [property objectClassInArrayFromClass:[self class]];
            if (!type.isFromFoundation && typeClass) {
                value = [typeClass objectWithKeyValues:value context:context error:error];
            } else if (objectClass) {
                // 3.字典数组-->模型数组
                value = [objectClass objectArrayWithKeyValuesArray:value context:context error:error];
            } else if (typeClass == [NSString class]) {
                if ([value isKindOfClass:[NSNumber class]]) {
                    // NSNumber -> NSString
                    value = [value description];
                } else if ([value isKindOfClass:[NSURL class]]) {
                    // NSURL -> NSString
                    value = [value absoluteString];
                }
            } else if ([value isKindOfClass:[NSString class]]) {
                if (typeClass == [NSURL class]) {
                    // NSString -> NSURL
                    value = [NSURL URLWithString:[value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                } else if (type.isNumberType) {
                    NSString *oldValue = value;
                    
                    // NSString -> NSNumber
                    value = [_numberFormatter numberFromString:oldValue];
                    
                    // 如果是BOOL
                    if ([type.code isEqualToString:MJTypeBOOL]) {
                        // 字符串转BOOL（字符串没有charValue方法）
                        // 系统会调用字符串的charValue转为BOOL类型
                        NSString *lower = [oldValue lowercaseString];
                        if ([lower isEqualToString:@"yes"] || [lower isEqualToString:@"true"]) {
                            value = @YES;
                        } else if ([lower isEqualToString:@"no"] || [lower isEqualToString:@"false"]) {
                            value = @NO;
                        }
                    }
                }
            }
            
            // 4.赋值
            [property setValue:value forObject:self];
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

#pragma mark - 字典数组 -> 模型数组
+ (NSMutableArray *)objectArrayWithKeyValuesArray:(NSArray *)keyValuesArray
{
    return [self objectArrayWithKeyValuesArray:keyValuesArray error:nil];
}

+ (NSMutableArray *)objectArrayWithKeyValuesArray:(NSArray *)keyValuesArray error:(NSError *__autoreleasing *)error
{
    return [self objectArrayWithKeyValuesArray:keyValuesArray context:nil error:error];
}

+ (NSMutableArray *)objectArrayWithKeyValuesArray:(id)keyValuesArray context:(NSManagedObjectContext *)context
{
    return [self objectArrayWithKeyValuesArray:keyValuesArray context:context error:nil];
}

+ (NSMutableArray *)objectArrayWithKeyValuesArray:(id)keyValuesArray context:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error
{
    // 如果是JSON字符串
    if ([keyValuesArray isKindOfClass:[NSString class]]) {
        keyValuesArray = [((NSString *)keyValuesArray) JSONObject];
    } else if ([keyValuesArray isKindOfClass:[NSData class]]) {
        keyValuesArray = [NSJSONSerialization JSONObjectWithData:keyValuesArray options:kNilOptions error:nil];
    }
    
    // 如果数组里面放的是NSString、NSNumber等数据
    if ([MJFoundation isClassFromFoundation:self]) return keyValuesArray;
    
    // 1.判断真实性
    MJAssertError([keyValuesArray isKindOfClass:[NSArray class]], nil, error, @"keyValuesArray参数不是一个数组");
    
    // 2.创建数组
    NSMutableArray *modelArray = [NSMutableArray array];
    
    // 3.遍历
    for (NSDictionary *keyValues in keyValuesArray) {
        if ([keyValues isKindOfClass:[NSArray class]]){
            [modelArray addObject:[self objectArrayWithKeyValuesArray:keyValues context:context error:error]];
        } else {
            id model = [self objectWithKeyValues:keyValues context:context error:error];
            if (model) [modelArray addObject:model];
        }
    }
    
    return modelArray;
}

+ (NSMutableArray *)objectArrayWithFilename:(NSString *)filename
{
    return [self objectArrayWithFilename:filename error:nil];
}

+ (NSMutableArray *)objectArrayWithFilename:(NSString *)filename error:(NSError *__autoreleasing *)error
{
    MJAssertError(filename != nil, nil, error, @"filename参数为nil");
    
    return [self objectArrayWithFile:[[NSBundle mainBundle] pathForResource:filename ofType:nil] error:error];
}

+ (NSMutableArray *)objectArrayWithFile:(NSString *)file
{
    return [self objectArrayWithFile:file error:nil];
}

+ (NSMutableArray *)objectArrayWithFile:(NSString *)file error:(NSError *__autoreleasing *)error
{
    MJAssertError(file != nil, nil, error, @"file参数为nil");
    
    return [self objectArrayWithKeyValuesArray:[NSArray arrayWithContentsOfFile:file] error:error];
}

#pragma mark - 模型 -> 字典
- (NSMutableDictionary *)keyValues
{
    return [self keyValuesWithError:nil];
}

- (NSMutableDictionary *)keyValuesWithError:(NSError *__autoreleasing *)error
{
    return [self keyValuesWithIgnoredKeys:nil error:error];
}

- (NSMutableDictionary *)keyValuesWithKeys:(NSArray *)keys
{
    return [self keyValuesWithKeys:keys error:nil];
}

- (NSMutableDictionary *)keyValuesWithIgnoredKeys:(NSArray *)ignoredKeys
{
    return [self keyValuesWithIgnoredKeys:ignoredKeys error:nil];
}

- (NSMutableDictionary *)keyValuesWithKeys:(NSArray *)keys error:(NSError *__autoreleasing *)error
{
    return [self keyValuesWithKeys:keys ignoredKeys:nil error:error];
}

- (NSMutableDictionary *)keyValuesWithIgnoredKeys:(NSArray *)ignoredKeys error:(NSError *__autoreleasing *)error
{
    return [self keyValuesWithKeys:nil ignoredKeys:ignoredKeys error:error];
}

- (NSMutableDictionary *)keyValuesWithKeys:(NSArray *)keys ignoredKeys:(NSArray *)ignoredKeys error:(NSError *__autoreleasing *)error
{
    // 如果自己不是模型类
    if ([MJFoundation isClassFromFoundation:[self class]]) return (NSMutableDictionary *)self;
    
    __block NSMutableDictionary *keyValues = [NSMutableDictionary dictionary];
    
    @try {
        Class aClass = [self class];
        NSArray *allowedPropertyNames = [aClass totalAllowedPropertyNames];
        NSArray *ignoredPropertyNames = [aClass totalIgnoredPropertyNames];
        
        [aClass enumerateProperties:^(MJProperty *property, BOOL *stop) {
            // 0.检测是否被忽略
            if (allowedPropertyNames.count && ![allowedPropertyNames containsObject:property.name]) return;
            if ([ignoredPropertyNames containsObject:property.name]) return;
            if (keys.count && ![keys containsObject:property.name]) return;
            if ([ignoredKeys containsObject:property.name]) return;
            
            // 1.取出属性值
            id value = [property valueFromObject:self];
            if (!value) return;
            
            // 2.如果是模型属性
            MJType *type = property.type;
            Class typeClass = type.typeClass;
            Class objectClass = [property objectClassInArrayFromClass:[self class]];
            if (!type.isFromFoundation && typeClass) {
                value = [value keyValues];
            } else if (objectClass) {
                // 3.处理数组里面有模型的情况
                value = [objectClass keyValuesArrayWithObjectArray:value];
            } else if (typeClass == [NSURL class]) {
                value = [value absoluteString];
            }
            
            // 4.赋值
            NSArray *keys = [property keysFromClass:[self class]];
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
        
        // 去除系统自动增加的元素
        [keyValues removeObjectsForKeys:@[@"superclass", @"debugDescription", @"description", @"hash"]];
        
        // 转换完毕
        if ([self respondsToSelector:@selector(objectDidFinishConvertingToKeyValues)]) {
            [self objectDidFinishConvertingToKeyValues];
        }
    } @catch (NSException *exception) {
        MJBuildError(error, exception.reason);
    }
    
    return keyValues;
}
#pragma mark - 模型数组 -> 字典数组
+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray
{
    return [self keyValuesArrayWithObjectArray:objectArray error:nil];
}

+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray error:(NSError *__autoreleasing *)error
{
    return [self keyValuesArrayWithObjectArray:objectArray ignoredKeys:nil error:error];
}

+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray keys:(NSArray *)keys
{
    return [self keyValuesArrayWithObjectArray:objectArray keys:keys error:nil];
}

+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray ignoredKeys:(NSArray *)ignoredKeys
{
    return [self keyValuesArrayWithObjectArray:objectArray ignoredKeys:ignoredKeys error:nil];
}

+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray keys:(NSArray *)keys error:(NSError *__autoreleasing *)error
{
    return [self keyValuesArrayWithObjectArray:objectArray keys:keys ignoredKeys:nil error:error];
}

+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray ignoredKeys:(NSArray *)ignoredKeys error:(NSError *__autoreleasing *)error
{
    return [self keyValuesArrayWithObjectArray:objectArray keys:nil ignoredKeys:ignoredKeys error:error];
}

+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray keys:(NSArray *)keys ignoredKeys:(NSArray *)ignoredKeys error:(NSError *__autoreleasing *)error
{
    // 0.判断真实性
    MJAssertError([objectArray isKindOfClass:[NSArray class]], nil, error, @"objectArray参数不是一个数组");
    
    // 1.创建数组
    NSMutableArray *keyValuesArray = [NSMutableArray array];
    for (id object in objectArray) {
        if (keys) {
            [keyValuesArray addObject:[object keyValuesWithKeys:keys error:error]];
        } else {
            [keyValuesArray addObject:[object keyValuesWithIgnoredKeys:ignoredKeys error:error]];
        }
    }
    return keyValuesArray;
}

#pragma mark - 转换为JSON
- (NSData *)JSONData
{
    if ([self isKindOfClass:[NSString class]]) {
        return [((NSString *)self) dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    return [NSJSONSerialization dataWithJSONObject:[self JSONObject] options:kNilOptions error:nil];
}

- (id)JSONObject
{
    if ([self isKindOfClass:[NSString class]]) {
        return [NSJSONSerialization JSONObjectWithData:[((NSString *)self) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    }
    
    return self.keyValues;
}

- (NSString *)JSONString
{
    if ([self isKindOfClass:[NSString class]]) {
        return (NSString *)self;
    }
    
    return [[NSString alloc] initWithData:[self JSONData] encoding:NSUTF8StringEncoding];
}
@end
