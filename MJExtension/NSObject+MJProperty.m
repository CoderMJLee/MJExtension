//
//  NSObject+MJProperty.m
//  MJExtensionExample
//
//  Created by MJ Lee on 15/4/17.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "NSObject+MJProperty.h"
#import "NSObject+MJKeyValue.h"
#import "NSObject+MJCoding.h"
#import "MJProperty.h"
#import "MJFoundation.h"
#import <objc/runtime.h>

static const char MJReplacedKeyFromPropertyNameKey = '\0';
static const char MJReplacedKeyFromPropertyName121Key = '\0';
static const char MJNewValueFromOldValueKey = '\0';
static const char MJObjectClassInArrayKey = '\0';
static const char MJAllowedPropertyNamesKey = '\0';
static const char MJAllowedCodingPropertyNamesKey = '\0';
static const char MJIgnoredPropertyNamesKey = '\0';
static const char MJIgnoredCodingPropertyNamesKey = '\0';

@implementation NSObject (Property)
#pragma mark - --私有方法--
+ (NSString *)propertyKey:(NSString *)propertyName
{
    MJAssertParamNotNil2(propertyName, nil);
    
    __block NSString *key = nil;
    // 查看有没有需要替换的key
    if ([self respondsToSelector:@selector(replacedKeyFromPropertyName121:)]) {
        key = [self replacedKeyFromPropertyName121:propertyName];
    }
    
    // 调用block
    if (!key) {
        [self enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            MJReplacedKeyFromPropertyName121 block = objc_getAssociatedObject(c, &MJReplacedKeyFromPropertyName121Key);
            if (block) {
                key = block(propertyName);
            }
            if (key) *stop = YES;
        }];
    }
    
    // 查看有没有需要替换的key
    if (!key && [self respondsToSelector:@selector(replacedKeyFromPropertyName)]) {
        key = [self replacedKeyFromPropertyName][propertyName];
    }
    
    if (!key) {
        [self enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            NSDictionary *dict = objc_getAssociatedObject(c, &MJReplacedKeyFromPropertyNameKey);
            if (dict) {
                key = dict[propertyName];
            }
            if (key) *stop = YES;
        }];
    }
    
    // 2.用属性名作为key
    if (!key) key = propertyName;
    
    return key;
}

+ (Class)propertyObjectClassInArray:(NSString *)propertyName
{
    __block id aClass = nil;
    if ([self respondsToSelector:@selector(objectClassInArray)]) {
        aClass = [self objectClassInArray][propertyName];
    }
    
    if (!aClass) {
        [self enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            NSDictionary *dict = objc_getAssociatedObject(c, &MJObjectClassInArrayKey);
            if (dict) {
                aClass = dict[propertyName];
            }
            if (aClass) *stop = YES;
        }];
    }
    
    // 如果是NSString类型
    if ([aClass isKindOfClass:[NSString class]]) {
        aClass = NSClassFromString(aClass);
    }
    return aClass;
}

#pragma mark - --公共方法--
+ (void)enumerateProperties:(MJPropertiesEnumeration)enumeration
{
    // 获得成员变量
    NSArray *cachedProperties = [self properties];
    
    // 遍历成员变量
    BOOL stop = NO;
    for (MJProperty *property in cachedProperties) {
        enumeration(property, &stop);
        if (stop) break;
    }
}

+ (void)enumerateClasses:(MJClassesEnumeration)enumeration
{
    // 1.没有block就直接返回
    if (enumeration == nil) return;
    
    // 2.停止遍历的标记
    BOOL stop = NO;
    
    // 3.当前正在遍历的类
    Class c = self;
    
    // 4.开始遍历每一个类
    while (c && !stop) {
        // 4.1.执行操作
        enumeration(c, &stop);
        
        // 4.2.获得父类
        c = class_getSuperclass(c);
        
        if ([MJFoundation isClassFromFoundation:c]) break;
    }
}

+ (void)enumerateAllClasses:(MJClassesEnumeration)enumeration
{
    // 1.没有block就直接返回
    if (enumeration == nil) return;
    
    // 2.停止遍历的标记
    BOOL stop = NO;
    
    // 3.当前正在遍历的类
    Class c = self;
    
    // 4.开始遍历每一个类
    while (c && !stop) {
        // 4.1.执行操作
        enumeration(c, &stop);
        
        // 4.2.获得父类
        c = class_getSuperclass(c);
    }
}

#pragma mark - 公共方法
+ (NSMutableArray *)properties
{
    static const char MJCachedPropertiesKey = '\0';
    
    // 获得成员变量
    // 通过关联对象，以及提前定义好的MJCachedPropertiesKey来进行运行时，对所有属性的获取。

    //***objc_getAssociatedObject 方法用于判断当前是否已经获取过MJCachedPropertiesKey对应的关联对象
    //  1> 关联到的对象
    //  2> 关联的属性 key
    NSMutableArray *cachedProperties = objc_getAssociatedObject(self, &MJCachedPropertiesKey);
    //***
    if (cachedProperties == nil) {
        cachedProperties = [NSMutableArray array];

        /**遍历这个类的父类*/
        [self enumerateClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            // 1.获得所有的成员变量
            unsigned int outCount = 0;
            /**
                class_copyIvarList 成员变量，提示有很多第三方框架会使用 Ivar，能够获得更多的信息
                但是：在 swift 中，由于语法结构的变化，使用 Ivar 非常不稳定，经常会崩溃！
                class_copyPropertyList 属性
                class_copyMethodList 方法
                class_copyProtocolList 协议
                */
            objc_property_t *properties = class_copyPropertyList(c, &outCount);
            
            // 2.遍历每一个成员变量
            for (unsigned int i = 0; i<outCount; i++) {
                MJProperty *property = [MJProperty cachedPropertyWithProperty:properties[i]];
                property.srcClass = c;
                [property setKey:[self propertyKey:property.name] forClass:self];
                [property setObjectClassInArray:[self propertyObjectClassInArray:property.name] forClass:self];
                [cachedProperties addObject:property];
            }
            
            // 3.释放内存
            free(properties);
        }];
        //*** 在此时设置当前这个类为关联对象，这样下次就不会重复获取类的相关属性。
        objc_setAssociatedObject(self, &MJCachedPropertiesKey, cachedProperties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        //***
    }
    
    return cachedProperties;
}

#pragma mark - 新值配置
+ (void)setupNewValueFormOldValue:(MJNewValueFormOldValue)newValueFormOldValue
{
    objc_setAssociatedObject(self, &MJNewValueFromOldValueKey, newValueFormOldValue, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (id)getNewValueFormOldValue:(__weak id)oldValue object:(__weak id)object property:(MJProperty *__weak)property
{
    __block id newValue = nil;
    [self enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
        MJNewValueFormOldValue block = objc_getAssociatedObject(c, &MJNewValueFromOldValueKey);
        if (block) {
            newValue = block(object, oldValue, property);
            *stop = YES;
        }
    }];
    return newValue;
}

#pragma mark - array model class配置
+ (void)setupObjectClassInArray:(MJObjectClassInArray)objectClassInArray
{
    [self setupObjectWithBlock:objectClassInArray key:&MJObjectClassInArrayKey];
}

#pragma mark - key配置
+ (void)setupReplacedKeyFromPropertyName:(MJReplacedKeyFromPropertyName)replacedKeyFromPropertyName
{
    [self setupObjectWithBlock:replacedKeyFromPropertyName key:&MJReplacedKeyFromPropertyNameKey];
}

+ (void)setupReplacedKeyFromPropertyName121:(MJReplacedKeyFromPropertyName121)replacedKeyFromPropertyName121
{
    objc_setAssociatedObject(self, &MJReplacedKeyFromPropertyName121Key, replacedKeyFromPropertyName121, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark - 属性黑名单配置
+ (void)setupIgnoredPropertyNames:(MJIgnoredPropertyNames)ignoredPropertyNames
{
    [self setupObjectWithBlock:ignoredPropertyNames key:&MJIgnoredPropertyNamesKey];
}

+ (NSMutableArray *)totalIgnoredPropertyNames
{
    return [self totalObjectWithSelector:@selector(ignoredPropertyNames) key:&MJIgnoredPropertyNamesKey];
}

#pragma mark - 归档属性黑名单配置
+ (void)setupIgnoredCodingPropertyNames:(MJIgnoredCodingPropertyNames)ignoredCodingPropertyNames
{
    [self setupObjectWithBlock:ignoredCodingPropertyNames key:&MJIgnoredCodingPropertyNamesKey];
}

+ (NSMutableArray *)totalIgnoredCodingPropertyNames
{
    return [self totalObjectWithSelector:@selector(ignoredCodingPropertyNames) key:&MJIgnoredCodingPropertyNamesKey];
}

#pragma mark - 属性白名单配置
+ (void)setupAllowedPropertyNames:(MJAllowedPropertyNames)allowedPropertyNames;
{
    [self setupObjectWithBlock:allowedPropertyNames key:&MJAllowedPropertyNamesKey];
}

+ (NSMutableArray *)totalAllowedPropertyNames
{
    return [self totalObjectWithSelector:@selector(allowedPropertyNames) key:&MJAllowedPropertyNamesKey];
}

#pragma mark - 归档属性白名单配置
+ (void)setupAllowedCodingPropertyNames:(MJAllowedCodingPropertyNames)allowedCodingPropertyNames
{
    [self setupObjectWithBlock:allowedCodingPropertyNames key:&MJAllowedCodingPropertyNamesKey];
}

+ (NSMutableArray *)totalAllowedCodingPropertyNames
{
    return [self totalObjectWithSelector:@selector(allowedCodingPropertyNames) key:&MJAllowedCodingPropertyNamesKey];
}
#pragma mark - block和方法处理
+ (void)setupObjectWithBlock:(id (^)())block key:(const char *)key
{
    if (block) {
        id obj = block();
        if (obj) {
            objc_setAssociatedObject(self, key, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}

+ (NSMutableArray *)totalObjectWithSelector:(SEL)selector key:(const char *)key
{
    NSMutableArray *array = [NSMutableArray array];
    
    if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSArray *subArray = [self performSelector:selector];
#pragma clang diagnostic pop
        if (subArray) {
            [array addObjectsFromArray:subArray];
        }
    }
    
    [self enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
        NSArray *subArray = objc_getAssociatedObject(c, key);
        [array addObjectsFromArray:subArray];
    }];
    return array;
}
@end
