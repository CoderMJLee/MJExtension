//
//  NSObject+MJKeyValue.m
//  MJExtension
//
//  Created by mj on 13-8-24.
//  Copyright (c) 2013年 小码哥. All rights reserved.
//

#import "NSObject+MJKeyValue.h"
#import "NSObject+MJProperty.h"
#import "NSString+MJExtension.h"
#import "MJProperty.h"
#import "MJPropertyType.h"
#import "MJExtensionConst.h"
#import "MJFoundation.h"
#import "NSString+MJExtension.h"
#import "NSObject+MJClass.h"

@implementation NSObject (MJKeyValue)

#pragma mark - 模型 -> 字典时的参考
/** 模型转字典时，字典的key是否参考replacedKeyFromPropertyName等方法（父类设置了，子类也会继承下来） */
static const char MJReferenceReplacedKeyWhenCreatingKeyValuesKey = '\0';

+ (void)referenceReplacedKeyWhenCreatingKeyValues:(BOOL)reference
{
    objc_setAssociatedObject(self, &MJReferenceReplacedKeyWhenCreatingKeyValuesKey, @(reference), OBJC_ASSOCIATION_ASSIGN);
}

+ (BOOL)isReferenceReplacedKeyWhenCreatingKeyValues
{
    __block id value = objc_getAssociatedObject(self, &MJReferenceReplacedKeyWhenCreatingKeyValuesKey);
    if (!value) {
        [self enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            value = objc_getAssociatedObject(c, &MJReferenceReplacedKeyWhenCreatingKeyValuesKey);
            
            if (value) *stop = YES;
        }];
    }
    return [value boolValue];
}

#pragma mark - --常用的对象--
static NSNumberFormatter *numberFormatter_;
+ (void)load
{
    numberFormatter_ = [[NSNumberFormatter alloc] init];
    
    // 默认设置
    [self referenceReplacedKeyWhenCreatingKeyValues:YES];
}

#pragma mark - --公共方法--
#pragma mark - 字典 -> 模型
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
    // 获得JSON对象
    keyValues = [keyValues JSONObject];
    
    MJExtensionAssertError([keyValues isKindOfClass:[NSDictionary class]], self, error, @"keyValues参数不是一个字典");
    
    Class aClass = [self class];
    NSArray *allowedPropertyNames = [aClass totalAllowedPropertyNames];
    NSArray *ignoredPropertyNames = [aClass totalIgnoredPropertyNames];
        
        //通过封装的方法回调一个通过运行时编写的，用于返回属性列表的方法。
    [aClass enumerateProperties:^(MJProperty *property, BOOL *stop) {
        @try {
            // 0.检测是否被忽略
            if (allowedPropertyNames.count && ![allowedPropertyNames containsObject:property.name]) return;
            if ([ignoredPropertyNames containsObject:property.name]) return;
            
            // 1.取出属性值
            id value;
            NSArray *propertyKeyses = [property propertyKeysForClass:aClass];
            for (NSArray *propertyKeys in propertyKeyses) {
                value = keyValues;
                for (MJPropertyKey *propertyKey in propertyKeys) {
                    value = [propertyKey valueInObject:value];
                }
                if (value) break;
            }
            
            // 值的过滤
            value = [aClass getNewValueFromObject:self oldValue:value property:property];
            
            // 如果没有值，就直接返回
            if (!value || value == [NSNull null]) return;
            
            // 2.如果是模型属性
            MJPropertyType *type = property.type;
            Class typeClass = type.typeClass;
            Class objectClass = [property objectClassInArrayForClass:[self class]];
            if (!type.isFromFoundation && typeClass) {
                value = [typeClass objectWithKeyValues:value context:context error:error];
            } else if (objectClass) {
                // string array -> url array
                if (objectClass == [NSURL class] && [value isKindOfClass:[NSArray class]]) {
                    NSMutableArray *urlArray = [NSMutableArray array];
                    for (NSString *string in value) {
                        if (![string isKindOfClass:[NSString class]]) continue;
                        [urlArray addObject:string.url];
                    }
                    value = urlArray;
                } else {
                    // 3.字典数组-->模型数组
                    value = [objectClass objectArrayWithKeyValuesArray:value context:context error:error];
                }
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
                    // 字符串转码
                    value = [value url];
                } else if (type.isNumberType) {
                    NSString *oldValue = value;
                    
                    // NSString -> NSNumber
                    value = [numberFormatter_ numberFromString:oldValue];
                    
                    // 如果是BOOL
                    if (type.isBoolType) {
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
        } @catch (NSException *exception) {
            MJExtensionBuildError(error, exception.reason);
            NSLog(@"%@", exception);
        }
    }];
    
    // 转换完毕
    if ([self respondsToSelector:@selector(keyValuesDidFinishConvertingToObject)]) {
        [self keyValuesDidFinishConvertingToObject];
    }
    return self;
}

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
    MJExtensionAssertError(filename != nil, nil, error, @"filename参数为nil");
    
    return [self objectWithFile:[[NSBundle mainBundle] pathForResource:filename ofType:nil] error:error];
}

+ (instancetype)objectWithFile:(NSString *)file
{
    return [self objectWithFile:file error:nil];
}

+ (instancetype)objectWithFile:(NSString *)file error:(NSError *__autoreleasing *)error
{
    MJExtensionAssertError(file != nil, nil, error, @"file参数为nil");
    
    return [self objectWithKeyValues:[NSDictionary dictionaryWithContentsOfFile:file] error:error];
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
    // 如果数组里面放的是NSString、NSNumber等数据
    if ([MJFoundation isClassFromFoundation:self]) return [NSMutableArray arrayWithArray:keyValuesArray];
    
    // 如果是JSON字符串
    keyValuesArray = [keyValuesArray JSONObject];
    
    // 1.判断真实性
    MJExtensionAssertError([keyValuesArray isKindOfClass:[NSArray class]], nil, error, @"keyValuesArray参数不是一个数组");
    
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
    MJExtensionAssertError(filename != nil, nil, error, @"filename参数为nil");
    
    return [self objectArrayWithFile:[[NSBundle mainBundle] pathForResource:filename ofType:nil] error:error];
}

+ (NSMutableArray *)objectArrayWithFile:(NSString *)file
{
    return [self objectArrayWithFile:file error:nil];
}

+ (NSMutableArray *)objectArrayWithFile:(NSString *)file error:(NSError *__autoreleasing *)error
{
    MJExtensionAssertError(file != nil, nil, error, @"file参数为nil");
    
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

- (NSMutableDictionary *)keyValuesWithKeys:(NSArray *)keys error:(NSError *__autoreleasing *)error
{
    return [self keyValuesWithKeys:keys ignoredKeys:nil error:error];
}

- (NSMutableDictionary *)keyValuesWithIgnoredKeys:(NSArray *)ignoredKeys
{
    return [self keyValuesWithIgnoredKeys:ignoredKeys error:nil];
}

- (NSMutableDictionary *)keyValuesWithIgnoredKeys:(NSArray *)ignoredKeys error:(NSError *__autoreleasing *)error
{
    return [self keyValuesWithKeys:nil ignoredKeys:ignoredKeys error:error];
}

- (NSMutableDictionary *)keyValuesWithKeys:(NSArray *)keys ignoredKeys:(NSArray *)ignoredKeys error:(NSError *__autoreleasing *)error
{
    // 如果自己不是模型类
    if ([MJFoundation isClassFromFoundation:[self class]]) return (NSMutableDictionary *)self;
    
    id keyValues = [NSMutableDictionary dictionary];
    
    Class aClass = [self class];
    NSArray *allowedPropertyNames = [aClass totalAllowedPropertyNames];
    NSArray *ignoredPropertyNames = [aClass totalIgnoredPropertyNames];
    
    [aClass enumerateProperties:^(MJProperty *property, BOOL *stop) {
        @try {
            // 0.检测是否被忽略
            if (allowedPropertyNames.count && ![allowedPropertyNames containsObject:property.name]) return;
            if ([ignoredPropertyNames containsObject:property.name]) return;
            if (keys.count && ![keys containsObject:property.name]) return;
            if ([ignoredKeys containsObject:property.name]) return;
            
            // 1.取出属性值
            id value = [property valueForObject:self];
            if (!value) return;
            
            // 2.如果是模型属性
            MJPropertyType *type = property.type;
            Class typeClass = type.typeClass;
            if (!type.isFromFoundation && typeClass) {
                value = [value keyValues];
            } else if ([value isKindOfClass:[NSArray class]]) {
                // 3.处理数组里面有模型的情况
                value = [NSObject keyValuesArrayWithObjectArray:value];
            } else if (typeClass == [NSURL class]) {
                value = [value absoluteString];
            }
            
            // 4.赋值
            if ([aClass isReferenceReplacedKeyWhenCreatingKeyValues]) {
                NSArray *propertyKeys = [[property propertyKeysForClass:aClass] firstObject];
                NSUInteger keyCount = propertyKeys.count;
                // 创建字典
                __block id innerContainer = keyValues;
                [propertyKeys enumerateObjectsUsingBlock:^(MJPropertyKey *propertyKey, NSUInteger idx, BOOL *stop) {
                    // 下一个属性
                    MJPropertyKey *nextPropertyKey = nil;
                    if (idx != keyCount - 1) {
                        nextPropertyKey = propertyKeys[idx + 1];
                    }
                    
                    if (nextPropertyKey) { // 不是最后一个key
                        // 当前propertyKey对应的字典或者数组
                        id tempInnerContainer = [propertyKey valueInObject:innerContainer];
                        if (tempInnerContainer == nil || [tempInnerContainer isKindOfClass:[NSNull class]]) {
                            if (nextPropertyKey.type == MJPropertyKeyTypeDictionary) {
                                tempInnerContainer = [NSMutableDictionary dictionary];
                            } else {
                                tempInnerContainer = [NSMutableArray array];
                            }
                            if (propertyKey.type == MJPropertyKeyTypeDictionary) {
                                innerContainer[propertyKey.name] = tempInnerContainer;
                            } else {
                                innerContainer[propertyKey.name.intValue] = tempInnerContainer;
                            }
                        }
                        
                        if ([tempInnerContainer isKindOfClass:[NSMutableArray class]]) {
                            int index = nextPropertyKey.name.intValue;
                            while ([tempInnerContainer count] < index + 1) {
                                [tempInnerContainer addObject:[NSNull null]];
                            }
                        }
                        
                        innerContainer = tempInnerContainer;
                    } else { // 最后一个key
                        if (propertyKey.type == MJPropertyKeyTypeDictionary) {
                            innerContainer[propertyKey.name] = value;
                        } else {
                            innerContainer[propertyKey.name.intValue] = value;
                        }
                    }
                }];
            } else {
                keyValues[property.name] = value;
            }
        } @catch (NSException *exception) {
            MJExtensionBuildError(error, exception.reason);
            NSLog(@"%@", exception);
        }
    }];
    
    // 转换完毕
    if ([self respondsToSelector:@selector(objectDidFinishConvertingToKeyValues)]) {
        [self objectDidFinishConvertingToKeyValues];
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
    MJExtensionAssertError([objectArray isKindOfClass:[NSArray class]], nil, error, @"objectArray参数不是一个数组");
    
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
    } else if ([self isKindOfClass:[NSData class]]) {
        return (NSData *)self;
    }
    
    return [NSJSONSerialization dataWithJSONObject:[self JSONObject] options:kNilOptions error:nil];
}

- (id)JSONObject
{
    if ([self isKindOfClass:[NSString class]]) {
        return [NSJSONSerialization JSONObjectWithData:[((NSString *)self) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    } else if ([self isKindOfClass:[NSData class]]) {
        return [NSJSONSerialization JSONObjectWithData:(NSData *)self options:kNilOptions error:nil];
    }
    
    return self.keyValues;
}

- (NSString *)JSONString
{
    if ([self isKindOfClass:[NSString class]]) {
        return (NSString *)self;
    } else if ([self isKindOfClass:[NSData class]]) {
        return [[NSString alloc] initWithData:(NSData *)self encoding:NSUTF8StringEncoding];
    }
    
    return [[NSString alloc] initWithData:[self JSONData] encoding:NSUTF8StringEncoding];
}
@end
