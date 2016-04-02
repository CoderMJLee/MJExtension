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
#import "NSManagedObject+MJCoreData.h"

@interface NSManagedObject (MJKeyValue)

+ (NSArray *)mj_defaultAllowPropertyNamesWithContext:(NSManagedObjectContext *)context;

@end

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
    if ([self isKindOfClass:[NSManagedObject class]] && allowedPropertyNames.count == 0) {
        allowedPropertyNames = [clazz mj_defaultAllowPropertyNamesWithContext:context];
        //加入缓存
        [clazz mj_setupAllowedPropertyNames:^NSArray *{
            return allowedPropertyNames;
        }];
    }
    NSArray *ignoredPropertyNames = [clazz mj_totalIgnoredPropertyNames];
    NSArray *ignoredMappingPropertyNames = [clazz mj_totalIgnoredObjectMappingPropertyNames];
    NSArray *objectMappingPropertyNames = [clazz mj_totalObjectMappingPropertyNames];
    
    //通过封装的方法回调一个通过运行时编写的，用于返回属性列表的方法。
    [clazz mj_enumerateProperties:^(MJProperty *property, BOOL *stop) {
        @try {
            // 0.检测是否被忽略
            if (allowedPropertyNames.count && ![allowedPropertyNames containsObject:property.name]) return;
            if (objectMappingPropertyNames.count && ![objectMappingPropertyNames containsObject:property.name]) return;
            if ([ignoredMappingPropertyNames containsObject:property.name]) return;
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
                } else {
                    // 3.字典数组-->模型数组
                    if ([propertyClass isSubclassOfClass:[NSSet class]]) {
                        value = [objectClass mj_objectSetWithKeyValuesArray:value context:context];
                    } else if ([propertyClass isKindOfClass:[NSOrderedSet class]]) {
                        value = [objectClass mj_objectOrderedSetWithKeyValuesArray:value context:context];
                    } else {
                        value = [objectClass mj_objectArrayWithKeyValuesArray:value context:context];
                    }
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
                        if (type.typeClass == [NSDecimalNumber class]) {
                            value = [NSDecimalNumber decimalNumberWithString:oldValue];
                        } else {
                            value = [numberFormatter_ numberFromString:oldValue];
                        }
                        
                        BOOL isBOOLType = type.isBoolType;
                        
                        if (property.type.isNumberType && [self isKindOfClass:[NSManagedObject class]]) {
                            NSManagedObject *object = (NSManagedObject *)self;
                            NSEntityDescription *entityDescription = [object entity];
                            NSAttributeDescription *attr = [[entityDescription attributesByName] objectForKey:property.name];
                            NSAttributeType type = [attr attributeType];
                            if (type == NSBooleanAttributeType) {
                                isBOOLType = YES;
                            }
                        }
                        
                        if (isBOOLType) {
                            // 如果是BOOL
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
    NSObject *data =[self mj_generateDataWithKeyValue:keyValues inContext:context];
    return [data mj_setKeyValues:keyValues context:context];
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

#pragma mark Array

+ (NSMutableArray *)mj_objectArrayWithKeyValuesArray:(NSArray *)keyValuesArray
{
    return [self mj_objectArrayWithKeyValuesArray:keyValuesArray context:nil];
}

+ (NSMutableArray *)mj_objectArrayWithKeyValuesArray:(id)keyValuesArray context:(NSManagedObjectContext *)context
{
    return [self mj_objectMutableCollection:[NSMutableArray new] withKeyValuesArray:keyValuesArray context:context];
}

#pragma mark Set

+ (NSMutableSet *)mj_objectSetWithKeyValuesArray:(id)keyValuesArray {
    return [self mj_objectSetWithKeyValuesArray:keyValuesArray context:nil];
}

+ (NSMutableSet *)mj_objectSetWithKeyValuesArray:(id)keyValuesArray context:(NSManagedObjectContext *)context {
    return [self mj_objectMutableCollection:[NSMutableSet new] withKeyValuesArray:keyValuesArray context:context];
}

#pragma mark OrderdSet

+ (NSMutableOrderedSet *)mj_objectOrderedSetWithKeyValuesArray:(id)keyValuesArray {
    return [self mj_objectOrderedSetWithKeyValuesArray:keyValuesArray context:nil];
}
+ (NSMutableOrderedSet *)mj_objectOrderedSetWithKeyValuesArray:(id)keyValuesArray context:(NSManagedObjectContext *)context {
    return [self mj_objectMutableCollection:[NSMutableOrderedSet new] withKeyValuesArray:keyValuesArray context:context];
}

#pragma mark File

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
    if ([self isKindOfClass:[NSManagedObject class]] && allowedPropertyNames.count == 0) {
        NSManagedObject *object = (NSManagedObject *)self;
        allowedPropertyNames = [clazz mj_defaultAllowPropertyNamesWithContext:object.managedObjectContext];
        //加入缓存
        [clazz mj_setupAllowedPropertyNames:^NSArray *{
            return allowedPropertyNames;
        }];
    }
    NSArray *jsonSerializationPropertyNames = [clazz mj_totalJSONSerializationPropertyNames];
    NSArray *ignoredJSONSerializationPropertyNames = [clazz mj_totalIgnoredJSONSerializationPropertyNames];
    NSArray *ignoredPropertyNames = [clazz mj_totalIgnoredPropertyNames];
    
    [clazz mj_enumerateProperties:^(MJProperty *property, BOOL *stop) {
        @try {
            // 0.检测是否被忽略
            if (allowedPropertyNames.count && ![allowedPropertyNames containsObject:property.name]) return;
            if (jsonSerializationPropertyNames.count && ![jsonSerializationPropertyNames containsObject:property.name]) return;
            if ([ignoredJSONSerializationPropertyNames containsObject:property.name]) return;
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
                if ([propertyClass isSubclassOfClass:[NSManagedObject class]] && [self isKindOfClass:[NSManagedObject class]]) {
                    //core data对象关联另一个core data对象，可能存在inverse关系，需要过滤，否则造成循环调用
                    NSManagedObject *object = (NSManagedObject *)self;
                    NSManagedObjectContext *context = object.managedObjectContext;
                    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
                    NSRelationshipDescription *relationshipDescription = entityDescription.relationshipsByName[property.name];
                    NSString *inverseRelationName = relationshipDescription.inverseRelationship.name;
                    NSArray *ignoreKeys;
                    if (inverseRelationName) {
                        ignoreKeys = @[inverseRelationName];
                    }
                    value = [value mj_keyValuesWithIgnoredKeys:ignoreKeys];
                } else {
                    value = [value mj_keyValues];
                }
            } else if ([MJFoundation isCollectionClass:[value class]]) {
                // 3.处理数组里面有模型的情况
                value = [NSObject mj_keyValuesArrayWithObjectArray:value];
            } else if (propertyClass == [NSURL class]) {
                value = [value absoluteString];
            }
            
            //TODO: 看看有没有办法放在初始化property的时候，为property.type.isBoolType赋值
            // 如果是CoreData对象，需要判断NSNumber的属性是否bool类型，否则JSON序列化的时候会序列化为0/1
            if (property.type.isNumberType && [self isKindOfClass:[NSManagedObject class]]) {
                NSManagedObject *object = (NSManagedObject *)self;
                NSEntityDescription *entityDescription = [object entity];
                NSAttributeDescription *attr = [[entityDescription attributesByName] objectForKey:property.name];
                NSAttributeType type = [attr attributeType];
                if (type == NSBooleanAttributeType) {
                    value = [value boolValue]?@YES:@NO;
                }
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

#pragma mark Array
+ (NSMutableArray *)mj_keyValuesArrayWithObjectArray:(NSArray *)objectArray
{
    return [self mj_keyValuesArrayWithObjectArray:objectArray ignoredKeys:nil];
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
    return [self mj_keyValuesArrayWithObjectCollection:objectArray keys:keys ignoredKeys:ignoredKeys];
}

#pragma mark Set

+ (NSMutableArray *)mj_keyValuesArrayWithObjectSet:(NSSet *)objectSet
{
    return [self mj_keyValuesArrayWithObjectCollection:objectSet keys:nil ignoredKeys:nil];
}
+ (NSMutableArray *)mj_keyValuesArrayWithObjectSet:(NSSet *)objectSet keys:(NSArray *)keys
{
    return [self mj_keyValuesArrayWithObjectCollection:objectSet keys:keys ignoredKeys:nil];
}
+ (NSMutableArray *)mj_keyValuesArrayWithObjectSet:(NSSet *)objectSet ignoredKeys:(NSArray *)ignoredKeys
{
    return [self mj_keyValuesArrayWithObjectCollection:objectSet keys:nil ignoredKeys:ignoredKeys];
}

+ (NSMutableArray *)mj_keyValuesArrayWithObjectSet:(NSSet *)objectSet keys:(NSArray *)keys ignoredKeys:(NSArray *)ignoredKeys
{
    return [self mj_keyValuesArrayWithObjectCollection:objectSet keys:keys ignoredKeys:ignoredKeys];
}

#pragma mark OrderSet

+ (NSMutableArray *)mj_keyValuesArrayWithObjectOrderedSet:(NSOrderedSet *)objectOrderedSet
{
    return [self mj_keyValuesArrayWithObjectCollection:objectOrderedSet keys:nil ignoredKeys:nil];
}
+ (NSMutableArray *)mj_keyValuesArrayWithObjectOrderedSet:(NSOrderedSet *)objectOrderedSet keys:(NSArray *)keys
{
    return [self mj_keyValuesArrayWithObjectCollection:objectOrderedSet keys:keys ignoredKeys:nil];
}
+ (NSMutableArray *)mj_keyValuesArrayWithObjectOrderedSet:(NSOrderedSet *)objectOrderedSet ignoredKeys:(NSArray *)ignoredKeys {
    return [self mj_keyValuesArrayWithObjectCollection:objectOrderedSet keys:nil ignoredKeys:ignoredKeys];
}
+ (NSMutableArray *)mj_keyValuesArrayWithObjectOrderedSet:(NSOrderedSet *)objectOrderedSet keys:(NSArray *)keys ignoredKeys:(NSArray *)ignoredKeys
{
    return [self mj_keyValuesArrayWithObjectCollection:objectOrderedSet keys:keys ignoredKeys:ignoredKeys];
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

#pragma mark - 私有方法

+ (id)mj_objectMutableCollection:(id)mutableCollection withKeyValuesArray:(id)keyValuesArray context:(NSManagedObjectContext *)context {
    // 如果数组里面放的是NSString、NSNumber等数据
    if ([MJFoundation isClassFromFoundation:self]) {
        if ([mutableCollection isKindOfClass:[NSMutableSet class]]) {
            return [NSMutableSet setWithArray:keyValuesArray];
        } else if ([mutableCollection isKindOfClass:[NSMutableOrderedSet class]]) {
            return [NSMutableOrderedSet orderedSetWithArray:keyValuesArray];
        } else {
            return [NSMutableArray arrayWithArray:keyValuesArray];
        }
    }
    
    // 如果是JSON字符串
    keyValuesArray = [keyValuesArray mj_JSONObject];
    
    // 1.判断真实性
    MJExtensionAssertError([keyValuesArray isKindOfClass:[NSArray class]], nil, self, @"keyValuesArray参数不是一个数组");
    
    // 2.遍历
    for (NSDictionary *keyValues in keyValuesArray) {
        if ([keyValues isKindOfClass:[NSArray class]]){
            [mutableCollection addObject:[self mj_objectArrayWithKeyValuesArray:keyValues context:context]];
        } else {
            id model = [self mj_objectWithKeyValues:keyValues context:context];
            if (model) [mutableCollection addObject:model];
        }
    }
    
    return mutableCollection;
}

+ (NSMutableArray *)mj_keyValuesArrayWithObjectCollection:(id)objectCollection keys:(NSArray *)keys ignoredKeys:(NSArray *)ignoredKeys
{
    // 0.判断真实性
    MJExtensionAssertError([MJFoundation isCollectionClass:[objectCollection class]], nil, self, @"objectCollection参数不是一个容器");
    
    // 1.创建数组
    NSMutableArray *keyValuesArray = [NSMutableArray array];
    for (id object in objectCollection) {
        if (keys) {
            [keyValuesArray addObject:[object mj_keyValuesWithKeys:keys]];
        } else {
            [keyValuesArray addObject:[object mj_keyValuesWithIgnoredKeys:ignoredKeys]];
        }
    }
    return keyValuesArray;
}

/**
 *  对象初始化工厂方法，根据class生成对应的实例
 */
+ (NSObject *)mj_generateDataWithKeyValue:(id)keyValues inContext:(NSManagedObjectContext *)context {
    return [[self alloc] init];
}

@end

/**
 *  重写实例生成方法，core data对象先通过identityPropertyName查找是否包含有对应的数据，如果有，则生成该数据的实例进行更新，否则插入新数据
 */
@implementation NSManagedObject (MJKeyValue)

+ (NSObject *)mj_generateDataWithKeyValue:(id)keyValues inContext:(NSManagedObjectContext *)context {
    MJExtensionAssertError([keyValues isKindOfClass:[NSDictionary class]], nil, self, @"keyValue参数不是一个NSDictionary");
    MJExtensionAssertError(context != nil, nil, self, @"没有传递context");
    Class aClass = self;
    NSManagedObject *mappingObject;
    NSArray *identityProperyNames = [aClass mj_totalIdentityPropertyNames];
    
    //TODO:这里的代码和setKeyValues:的代码有重复，后期需要优化
    //设置了唯一键值，则尝试去数据库中找到对应的数据
    if (identityProperyNames.count > 0) {
        NSMutableArray *predicateArray = [[NSMutableArray alloc] initWithCapacity:identityProperyNames.count];
        [aClass mj_enumerateProperties:^(MJProperty *property, BOOL *stop) {
            if ([identityProperyNames containsObject:property.name]) {
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
                
                // 2.值的过滤
                id newValue = [aClass mj_getNewValueFromObject:self oldValue:value property:property];
                if (newValue) value = newValue;
                
                // 3.建立predicate
                if (value) {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", property.name, value];
                    [predicateArray addObject:predicate];
                } else {
                    //unique key不在keyValues中，取消遍历，直接插入新数据
                    *stop = YES;
                }
            }
        }];
        
        // 4. 查询对象
        if (predicateArray.count == identityProperyNames.count) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(self)];
            fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
            fetchRequest.fetchLimit = 1;
            mappingObject = [context executeFetchRequest:fetchRequest error:nil].firstObject;
        }
    }
    
    if (!mappingObject) {
        mappingObject = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:context];
    }
    
    return [mappingObject mj_setKeyValues:keyValues context:context];
}

+ (NSArray *)mj_defaultAllowPropertyNamesWithContext:(NSManagedObjectContext *)context {
    MJExtensionAssertError(context != nil, nil, self, @"传入的context为nil");
    NSEntityDescription *description = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    return [description propertiesByName].allKeys;
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
    if (error != NULL) {
        *error = [self.class mj_error];
    }
    return value;
    
}

- (instancetype)setKeyValues:(id)keyValues context:(NSManagedObjectContext *)context
{
    return [self mj_setKeyValues:keyValues context:context];
}

- (instancetype)setKeyValues:(id)keyValues context:(NSManagedObjectContext *)context error:(NSError **)error
{
    id value = [self mj_setKeyValues:keyValues context:context];
    if (error != NULL) {
        *error = [self.class mj_error];
    }
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
    if (error != NULL) {
        *error = [self.class mj_error];
    }
    return value;
}

- (NSMutableDictionary *)keyValuesWithKeys:(NSArray *)keys
{
    return [self mj_keyValuesWithKeys:keys];
}

- (NSMutableDictionary *)keyValuesWithKeys:(NSArray *)keys error:(NSError **)error
{
    id value = [self mj_keyValuesWithKeys:keys];
    if (error != NULL) {
        *error = [self.class mj_error];
    }
    return value;
}

- (NSMutableDictionary *)keyValuesWithIgnoredKeys:(NSArray *)ignoredKeys
{
    return [self mj_keyValuesWithIgnoredKeys:ignoredKeys];
}

- (NSMutableDictionary *)keyValuesWithIgnoredKeys:(NSArray *)ignoredKeys error:(NSError **)error
{
    id value = [self mj_keyValuesWithIgnoredKeys:ignoredKeys];
    if (error != NULL) {
        *error = [self.class mj_error];
    }
    return value;
}

+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray
{
    return [self mj_keyValuesArrayWithObjectArray:objectArray];
}

+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray error:(NSError **)error
{
    id value = [self mj_keyValuesArrayWithObjectArray:objectArray];
    if (error != NULL) {
        *error = [self mj_error];
    }
    return value;
}

+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray keys:(NSArray *)keys
{
    return [self mj_keyValuesArrayWithObjectArray:objectArray keys:keys];
}

+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray keys:(NSArray *)keys error:(NSError **)error
{
    id value = [self mj_keyValuesArrayWithObjectArray:objectArray keys:keys];
    if (error != NULL) {
        *error = [self mj_error];
    }
    return value;
}

+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray ignoredKeys:(NSArray *)ignoredKeys
{
    return [self mj_keyValuesArrayWithObjectArray:objectArray ignoredKeys:ignoredKeys];
}

+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray ignoredKeys:(NSArray *)ignoredKeys error:(NSError **)error
{
    id value = [self mj_keyValuesArrayWithObjectArray:objectArray ignoredKeys:ignoredKeys];
    if (error != NULL) {
        *error = [self mj_error];
    }
    return value;
}

+ (instancetype)objectWithKeyValues:(id)keyValues
{
    return [self mj_objectWithKeyValues:keyValues];
}

+ (instancetype)objectWithKeyValues:(id)keyValues error:(NSError **)error
{
    id value = [self mj_objectWithKeyValues:keyValues];
    if (error != NULL) {
        *error = [self mj_error];
    }
    return value;
}

+ (instancetype)objectWithKeyValues:(id)keyValues context:(NSManagedObjectContext *)context
{
    return [self mj_objectWithKeyValues:keyValues context:context];
}

+ (instancetype)objectWithKeyValues:(id)keyValues context:(NSManagedObjectContext *)context error:(NSError **)error
{
    id value = [self mj_objectWithKeyValues:keyValues context:context];
    if (error != NULL) {
        *error = [self mj_error];
    }
    return value;
}

+ (instancetype)objectWithFilename:(NSString *)filename
{
    return [self mj_objectWithFilename:filename];
}

+ (instancetype)objectWithFilename:(NSString *)filename error:(NSError **)error
{
    id value = [self mj_objectWithFilename:filename];
    if (error != NULL) {
        *error = [self mj_error];
    }
    return value;
}

+ (instancetype)objectWithFile:(NSString *)file
{
    return [self mj_objectWithFile:file];
}

+ (instancetype)objectWithFile:(NSString *)file error:(NSError **)error
{
    id value = [self mj_objectWithFile:file];
    if (error != NULL) {
        *error = [self mj_error];
    }
    return value;
}

+ (NSMutableArray *)objectArrayWithKeyValuesArray:(id)keyValuesArray
{
    return [self mj_objectArrayWithKeyValuesArray:keyValuesArray];
}

+ (NSMutableArray *)objectArrayWithKeyValuesArray:(id)keyValuesArray error:(NSError **)error
{
    id value = [self mj_objectArrayWithKeyValuesArray:keyValuesArray];
    if (error != NULL) {
        *error = [self mj_error];
    }
    return value;
}

+ (NSMutableArray *)objectArrayWithKeyValuesArray:(id)keyValuesArray context:(NSManagedObjectContext *)context
{
    return [self mj_objectArrayWithKeyValuesArray:keyValuesArray context:context];
}

+ (NSMutableArray *)objectArrayWithKeyValuesArray:(id)keyValuesArray context:(NSManagedObjectContext *)context error:(NSError **)error
{
    id value = [self mj_objectArrayWithKeyValuesArray:keyValuesArray context:context];
    if (error != NULL) {
        *error = [self mj_error];
    }
    return value;
}

+ (NSMutableArray *)objectArrayWithFilename:(NSString *)filename
{
    return [self mj_objectArrayWithFilename:filename];
}

+ (NSMutableArray *)objectArrayWithFilename:(NSString *)filename error:(NSError **)error
{
    id value = [self mj_objectArrayWithFilename:filename];
    if (error != NULL) {
        *error = [self mj_error];
    }
    return value;
}

+ (NSMutableArray *)objectArrayWithFile:(NSString *)file
{
    return [self mj_objectArrayWithFile:file];
}

+ (NSMutableArray *)objectArrayWithFile:(NSString *)file error:(NSError **)error
{
    id value = [self mj_objectArrayWithFile:file];
    if (error != NULL) {
        *error = [self mj_error];
    }
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
