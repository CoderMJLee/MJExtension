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

#pragma mark - 错误
static const char MJErrorKey = '\0';
+ (NSError *)mj_error
{
    return objc_getAssociatedObject(self, &MJErrorKey);
}

+ (void)setMj_error:(NSError *)error
{
    objc_setAssociatedObject(self, &MJErrorKey, error, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - 模型 -> 字典时的参考
/** 模型转字典时，字典的key是否参考replacedKeyFromPropertyName等方法（父类设置了，子类也会继承下来） */
static const char MJReferenceReplacedKeyWhenCreatingKeyValuesKey = '\0';

+ (void)mj_referenceReplacedKeyWhenCreatingKeyValues:(BOOL)reference
{
    objc_setAssociatedObject(self, &MJReferenceReplacedKeyWhenCreatingKeyValuesKey, @(reference), OBJC_ASSOCIATION_ASSIGN);
}

+ (BOOL)mj_isReferenceReplacedKeyWhenCreatingKeyValues
{
    __block id value = objc_getAssociatedObject(self, &MJReferenceReplacedKeyWhenCreatingKeyValuesKey);
    if (!value) {
        [self mj_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
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
    [self mj_referenceReplacedKeyWhenCreatingKeyValues:YES];
}

#pragma mark - --公共方法--
#pragma mark - 字典 -> 模型
- (instancetype)mj_setKeyValues:(id)keyValues
{
    return [self mj_setKeyValues:keyValues context:nil];
}

/**
 核心代码：
 */
- (instancetype)mj_setKeyValues:(id)keyValues context:(NSManagedObjectContext *)context
{
    // 获得JSON对象
    keyValues = [keyValues mj_JSONObject];
    
    MJExtensionAssertError([keyValues isKindOfClass:[NSDictionary class]], self, [self class], @"keyValues参数不是一个字典");
    
    Class clazz = [self class];
    NSArray *allowedPropertyNames = [clazz mj_totalAllowedPropertyNames];
    NSArray *ignoredPropertyNames = [clazz mj_totalIgnoredPropertyNames];
    
    //通过封装的方法回调一个通过运行时编写的，用于返回属性列表的方法。
    [clazz mj_enumerateProperties:^(MJProperty *property, BOOL *stop) {
        @try {
            // 0.检测是否被忽略
            if (allowedPropertyNames.count && ![allowedPropertyNames containsObject:property.name]) return;
            if ([ignoredPropertyNames containsObject:property.name]) return;
            
            // 1.取出属性值
            id value;
            NSArray *propertyKeyses = [property propertyKeysForClass:clazz];
            for (NSArray *propertyKeys in propertyKeyses) {
                value = keyValues;
                for (MJPropertyKey *propertyKey in propertyKeys) {
                    value = [propertyKey valueInObject:value];
                }
                if (value) break;
            }
            
            // 值的过滤
            id newValue = [clazz mj_getNewValueFromObject:self oldValue:value property:property];
            if (newValue != value) { // 有过滤后的新值
                [property setValue:newValue forObject:self];
                return;
            }
            
            // 如果没有值，就直接返回
            if (!value || value == [NSNull null]) return;
            
            // 2.复杂处理
            MJPropertyType *type = property.type;
            Class propertyClass = type.typeClass;
            Class objectClass = [property objectClassInArrayForClass:[self class]];
            
            // 不可变 -> 可变处理
            if (propertyClass == [NSMutableArray class] && [value isKindOfClass:[NSArray class]]) {
                value = [NSMutableArray arrayWithArray:value];
            } else if (propertyClass == [NSMutableDictionary class] && [value isKindOfClass:[NSDictionary class]]) {
                value = [NSMutableDictionary dictionaryWithDictionary:value];
            } else if (propertyClass == [NSMutableString class] && [value isKindOfClass:[NSString class]]) {
                value = [NSMutableString stringWithString:value];
            } else if (propertyClass == [NSMutableData class] && [value isKindOfClass:[NSData class]]) {
                value = [NSMutableData dataWithData:value];
            }
            
            if (!type.isFromFoundation && propertyClass) { // 模型属性
                value = [propertyClass mj_objectWithKeyValues:value context:context];
            } else if (objectClass) {
                if (objectClass == [NSURL class] && [value isKindOfClass:[NSArray class]]) {
                    // string array -> url array
                    NSMutableArray *urlArray = [NSMutableArray array];
                    for (NSString *string in value) {
                        if (![string isKindOfClass:[NSString class]]) continue;
                        [urlArray addObject:string.mj_url];
                    }
                    value = urlArray;
                } else { // 字典数组-->模型数组
                    value = [objectClass mj_objectArrayWithKeyValuesArray:value context:context];
                }
            } else {
                if (propertyClass == [NSString class]) {
                    if ([value isKindOfClass:[NSNumber class]]) {
                        // NSNumber -> NSString
                        value = [value description];
                    } else if ([value isKindOfClass:[NSURL class]]) {
                        // NSURL -> NSString
                        value = [value absoluteString];
                    }
                } else if ([value isKindOfClass:[NSString class]]) {
                    if (propertyClass == [NSURL class]) {
                        // NSString -> NSURL
                        // 字符串转码
                        value = [value mj_url];
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
                
                // value和property类型不匹配
                if (propertyClass && ![value isKindOfClass:propertyClass]) {
                    value = nil;
                }
            }
            
            // 3.赋值
            [property setValue:value forObject:self];
        } @catch (NSException *exception) {
            MJExtensionBuildError([self class], exception.reason);
            MJExtensionLog(@"%@", exception);
        }
    }];
    
    // 转换完毕
    if ([self respondsToSelector:@selector(mj_keyValuesDidFinishConvertingToObject)]) {
        [self mj_keyValuesDidFinishConvertingToObject];
    }
    return self;
}

+ (instancetype)mj_objectWithKeyValues:(id)keyValues
{
    return [self mj_objectWithKeyValues:keyValues context:nil];
}

+ (instancetype)mj_objectWithKeyValues:(id)keyValues context:(NSManagedObjectContext *)context
{
    // 获得JSON对象
    keyValues = [keyValues mj_JSONObject];
    MJExtensionAssertError([keyValues isKindOfClass:[NSDictionary class]], nil, [self class], @"keyValues参数不是一个字典");
    
    if ([self isSubclassOfClass:[NSManagedObject class]] && context) {
        return [[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:context] mj_setKeyValues:keyValues context:context];
    }
    return [[[self alloc] init] mj_setKeyValues:keyValues];
}

+ (instancetype)mj_objectWithFilename:(NSString *)filename
{
    MJExtensionAssertError(filename != nil, nil, [self class], @"filename参数为nil");
    
    return [self mj_objectWithFile:[[NSBundle mainBundle] pathForResource:filename ofType:nil]];
}

+ (instancetype)mj_objectWithFile:(NSString *)file
{
    MJExtensionAssertError(file != nil, nil, [self class], @"file参数为nil");
    
    return [self mj_objectWithKeyValues:[NSDictionary dictionaryWithContentsOfFile:file]];
}

#pragma mark - 字典数组 -> 模型数组
+ (NSMutableArray *)mj_objectArrayWithKeyValuesArray:(NSArray *)keyValuesArray
{
    return [self mj_objectArrayWithKeyValuesArray:keyValuesArray context:nil];
}

+ (NSMutableArray *)mj_objectArrayWithKeyValuesArray:(id)keyValuesArray context:(NSManagedObjectContext *)context
{
    // 如果是JSON字符串
    keyValuesArray = [keyValuesArray mj_JSONObject];
    
    // 1.判断真实性
    MJExtensionAssertError([keyValuesArray isKindOfClass:[NSArray class]], nil, [self class], @"keyValuesArray参数不是一个数组");
    
    // 如果数组里面放的是NSString、NSNumber等数据
    if ([MJFoundation isClassFromFoundation:self]) return [NSMutableArray arrayWithArray:keyValuesArray];
    

    // 2.创建数组
    NSMutableArray *modelArray = [NSMutableArray array];
    
    // 3.遍历
    for (NSDictionary *keyValues in keyValuesArray) {
        if ([keyValues isKindOfClass:[NSArray class]]){
            [modelArray addObject:[self mj_objectArrayWithKeyValuesArray:keyValues context:context]];
        } else {
            id model = [self mj_objectWithKeyValues:keyValues context:context];
            if (model) [modelArray addObject:model];
        }
    }
    
    return modelArray;
}

+ (NSMutableArray *)mj_objectArrayWithFilename:(NSString *)filename
{
    MJExtensionAssertError(filename != nil, nil, [self class], @"filename参数为nil");
    
    return [self mj_objectArrayWithFile:[[NSBundle mainBundle] pathForResource:filename ofType:nil]];
}

+ (NSMutableArray *)mj_objectArrayWithFile:(NSString *)file
{
    MJExtensionAssertError(file != nil, nil, [self class], @"file参数为nil");
    
    return [self mj_objectArrayWithKeyValuesArray:[NSArray arrayWithContentsOfFile:file]];
}

#pragma mark - 模型 -> 字典
- (NSMutableDictionary *)mj_keyValues
{
    return [self mj_keyValuesWithKeys:nil ignoredKeys:nil];
}

- (NSMutableDictionary *)mj_keyValuesWithKeys:(NSArray *)keys
{
    return [self mj_keyValuesWithKeys:keys ignoredKeys:nil];
}

- (NSMutableDictionary *)mj_keyValuesWithIgnoredKeys:(NSArray *)ignoredKeys
{
    return [self mj_keyValuesWithKeys:nil ignoredKeys:ignoredKeys];
}

- (NSMutableDictionary *)mj_keyValuesWithKeys:(NSArray *)keys ignoredKeys:(NSArray *)ignoredKeys
{
    // 如果自己不是模型类, 那就返回自己
    MJExtensionAssertError(![MJFoundation isClassFromFoundation:[self class]], (NSMutableDictionary *)self, [self class], @"不是自定义的模型类")
    
    id keyValues = [NSMutableDictionary dictionary];
    
    Class clazz = [self class];
    NSArray *allowedPropertyNames = [clazz mj_totalAllowedPropertyNames];
    NSArray *ignoredPropertyNames = [clazz mj_totalIgnoredPropertyNames];
    
    [clazz mj_enumerateProperties:^(MJProperty *property, BOOL *stop) {
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
            Class propertyClass = type.typeClass;
            if (!type.isFromFoundation && propertyClass) {
                value = [value mj_keyValues];
            } else if ([value isKindOfClass:[NSArray class]]) {
                // 3.处理数组里面有模型的情况
                value = [NSObject mj_keyValuesArrayWithObjectArray:value];
            } else if (propertyClass == [NSURL class]) {
                value = [value absoluteString];
            }
            
            // 4.赋值
            if ([clazz mj_isReferenceReplacedKeyWhenCreatingKeyValues]) {
                NSArray *propertyKeys = [[property propertyKeysForClass:clazz] firstObject];
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
                            NSMutableArray *tempInnerContainerArray = tempInnerContainer;
                            int index = nextPropertyKey.name.intValue;
                            while (tempInnerContainerArray.count < index + 1) {
                                [tempInnerContainerArray addObject:[NSNull null]];
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
            MJExtensionBuildError([self class], exception.reason);
            MJExtensionLog(@"%@", exception);
        }
    }];
    
    // 转换完毕
    if ([self respondsToSelector:@selector(mj_objectDidFinishConvertingToKeyValues)]) {
        [self mj_objectDidFinishConvertingToKeyValues];
    }
    
    return keyValues;
}
#pragma mark - 模型数组 -> 字典数组
+ (NSMutableArray *)mj_keyValuesArrayWithObjectArray:(NSArray *)objectArray
{
    return [self mj_keyValuesArrayWithObjectArray:objectArray keys:nil ignoredKeys:nil];
}

+ (NSMutableArray *)mj_keyValuesArrayWithObjectArray:(NSArray *)objectArray keys:(NSArray *)keys
{
    return [self mj_keyValuesArrayWithObjectArray:objectArray keys:keys ignoredKeys:nil];
}

+ (NSMutableArray *)mj_keyValuesArrayWithObjectArray:(NSArray *)objectArray ignoredKeys:(NSArray *)ignoredKeys
{
    return [self mj_keyValuesArrayWithObjectArray:objectArray keys:nil ignoredKeys:ignoredKeys];
}

+ (NSMutableArray *)mj_keyValuesArrayWithObjectArray:(NSArray *)objectArray keys:(NSArray *)keys ignoredKeys:(NSArray *)ignoredKeys
{
    // 0.判断真实性
    MJExtensionAssertError([objectArray isKindOfClass:[NSArray class]], nil, [self class], @"objectArray参数不是一个数组");
    
    // 1.创建数组
    NSMutableArray *keyValuesArray = [NSMutableArray array];
    for (id object in objectArray) {
        if (keys) {
            [keyValuesArray addObject:[object mj_keyValuesWithKeys:keys]];
        } else {
            [keyValuesArray addObject:[object mj_keyValuesWithIgnoredKeys:ignoredKeys]];
        }
    }
    return keyValuesArray;
}

#pragma mark - 转换为JSON
- (NSData *)mj_JSONData
{
    if ([self isKindOfClass:[NSString class]]) {
        return [((NSString *)self) dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([self isKindOfClass:[NSData class]]) {
        return (NSData *)self;
    }
    
    return [NSJSONSerialization dataWithJSONObject:[self mj_JSONObject] options:kNilOptions error:nil];
}

- (id)mj_JSONObject
{
    if ([self isKindOfClass:[NSString class]]) {
        return [NSJSONSerialization JSONObjectWithData:[((NSString *)self) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    } else if ([self isKindOfClass:[NSData class]]) {
        return [NSJSONSerialization JSONObjectWithData:(NSData *)self options:kNilOptions error:nil];
    }
    
    return self.mj_keyValues;
}

- (NSString *)mj_JSONString
{
    if ([self isKindOfClass:[NSString class]]) {
        return (NSString *)self;
    } else if ([self isKindOfClass:[NSData class]]) {
        return [[NSString alloc] initWithData:(NSData *)self encoding:NSUTF8StringEncoding];
    }
    
    return [[NSString alloc] initWithData:[self mj_JSONData] encoding:NSUTF8StringEncoding];
}
@end

@implementation NSObject (MJKeyValueDeprecated_v_2_5_16)
- (instancetype)setKeyValues:(id)keyValues
{
    return [self mj_setKeyValues:keyValues];
}

- (instancetype)setKeyValues:(id)keyValues error:(NSError **)error
{
    id value = [self mj_setKeyValues:keyValues];
    *error = [self.class mj_error];
    return value;
}

- (instancetype)setKeyValues:(id)keyValues context:(NSManagedObjectContext *)context
{
    return [self mj_setKeyValues:keyValues context:context];
}

- (instancetype)setKeyValues:(id)keyValues context:(NSManagedObjectContext *)context error:(NSError **)error
{
    id value = [self mj_setKeyValues:keyValues context:context];
    *error = [self.class mj_error];
    return value;
}

+ (void)referenceReplacedKeyWhenCreatingKeyValues:(BOOL)reference
{
    [self mj_referenceReplacedKeyWhenCreatingKeyValues:reference];
}

- (NSMutableDictionary *)keyValues
{
    return [self mj_keyValues];
}

- (NSMutableDictionary *)keyValuesWithError:(NSError **)error
{
    id value = [self mj_keyValues];
    *error = [self.class mj_error];
    return value;
}

- (NSMutableDictionary *)keyValuesWithKeys:(NSArray *)keys
{
    return [self mj_keyValuesWithKeys:keys];
}

- (NSMutableDictionary *)keyValuesWithKeys:(NSArray *)keys error:(NSError **)error
{
    id value = [self mj_keyValuesWithKeys:keys];
    *error = [self.class mj_error];
    return value;
}

- (NSMutableDictionary *)keyValuesWithIgnoredKeys:(NSArray *)ignoredKeys
{
    return [self mj_keyValuesWithIgnoredKeys:ignoredKeys];
}

- (NSMutableDictionary *)keyValuesWithIgnoredKeys:(NSArray *)ignoredKeys error:(NSError **)error
{
    id value = [self mj_keyValuesWithIgnoredKeys:ignoredKeys];
    *error = [self.class mj_error];
    return value;
}

+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray
{
    return [self mj_keyValuesArrayWithObjectArray:objectArray];
}

+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray error:(NSError **)error
{
    id value = [self mj_keyValuesArrayWithObjectArray:objectArray];
    *error = [self mj_error];
    return value;
}

+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray keys:(NSArray *)keys
{
    return [self mj_keyValuesArrayWithObjectArray:objectArray keys:keys];
}

+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray keys:(NSArray *)keys error:(NSError **)error
{
    id value = [self mj_keyValuesArrayWithObjectArray:objectArray keys:keys];
    *error = [self mj_error];
    return value;
}

+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray ignoredKeys:(NSArray *)ignoredKeys
{
    return [self mj_keyValuesArrayWithObjectArray:objectArray ignoredKeys:ignoredKeys];
}

+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray ignoredKeys:(NSArray *)ignoredKeys error:(NSError **)error
{
    id value = [self mj_keyValuesArrayWithObjectArray:objectArray ignoredKeys:ignoredKeys];
    *error = [self mj_error];
    return value;
}

+ (instancetype)objectWithKeyValues:(id)keyValues
{
    return [self mj_objectWithKeyValues:keyValues];
}

+ (instancetype)objectWithKeyValues:(id)keyValues error:(NSError **)error
{
    id value = [self mj_objectWithKeyValues:keyValues];
    *error = [self mj_error];
    return value;
}

+ (instancetype)objectWithKeyValues:(id)keyValues context:(NSManagedObjectContext *)context
{
    return [self mj_objectWithKeyValues:keyValues context:context];
}

+ (instancetype)objectWithKeyValues:(id)keyValues context:(NSManagedObjectContext *)context error:(NSError **)error
{
    id value = [self mj_objectWithKeyValues:keyValues context:context];
    *error = [self mj_error];
    return value;
}

+ (instancetype)objectWithFilename:(NSString *)filename
{
    return [self mj_objectWithFilename:filename];
}

+ (instancetype)objectWithFilename:(NSString *)filename error:(NSError **)error
{
    id value = [self mj_objectWithFilename:filename];
    *error = [self mj_error];
    return value;
}

+ (instancetype)objectWithFile:(NSString *)file
{
    return [self mj_objectWithFile:file];
}

+ (instancetype)objectWithFile:(NSString *)file error:(NSError **)error
{
    id value = [self mj_objectWithFile:file];
    *error = [self mj_error];
    return value;
}

+ (NSMutableArray *)objectArrayWithKeyValuesArray:(id)keyValuesArray
{
    return [self mj_objectArrayWithKeyValuesArray:keyValuesArray];
}

+ (NSMutableArray *)objectArrayWithKeyValuesArray:(id)keyValuesArray error:(NSError **)error
{
    id value = [self mj_objectArrayWithKeyValuesArray:keyValuesArray];
    *error = [self mj_error];
    return value;
}

+ (NSMutableArray *)objectArrayWithKeyValuesArray:(id)keyValuesArray context:(NSManagedObjectContext *)context
{
    return [self mj_objectArrayWithKeyValuesArray:keyValuesArray context:context];
}

+ (NSMutableArray *)objectArrayWithKeyValuesArray:(id)keyValuesArray context:(NSManagedObjectContext *)context error:(NSError **)error
{
    id value = [self mj_objectArrayWithKeyValuesArray:keyValuesArray context:context];
    *error = [self mj_error];
    return value;
}

+ (NSMutableArray *)objectArrayWithFilename:(NSString *)filename
{
    return [self mj_objectArrayWithFilename:filename];
}

+ (NSMutableArray *)objectArrayWithFilename:(NSString *)filename error:(NSError **)error
{
    id value = [self mj_objectArrayWithFilename:filename];
    *error = [self mj_error];
    return value;
}

+ (NSMutableArray *)objectArrayWithFile:(NSString *)file
{
    return [self mj_objectArrayWithFile:file];
}

+ (NSMutableArray *)objectArrayWithFile:(NSString *)file error:(NSError **)error
{
    id value = [self mj_objectArrayWithFile:file];
    *error = [self mj_error];
    return value;
}

- (NSData *)JSONData
{
    return [self mj_JSONData];
}

- (id)JSONObject
{
    return [self mj_JSONObject];
}

- (NSString *)JSONString
{
    return [self mj_JSONString];
}
@end