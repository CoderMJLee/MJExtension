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

static const char MJReplacedKeyFromPropertyNameKey;
static const char MJObjectClassInArrayKey;
static const char MJAllowedPropertyNamesKey;
static const char MJAllowedCodingPropertyNamesKey;
static const char MJIgnoredPropertyNamesKey;
static const char MJIgnoredCodingPropertyNamesKey;

@implementation NSObject (Property)
#pragma mark - --私有方法--
+ (NSString *)propertyKey:(NSString *)propertyName
{
    MJAssertParamNotNil2(propertyName, nil);
    
    __block NSString *key = nil;
    // 1.查看有没有需要替换的key
    if ([self respondsToSelector:@selector(replacedKeyFromPropertyName)]) {
        key = [self replacedKeyFromPropertyName][propertyName];
    }
    
    if (!key) {
        [self enumerateClassesWithBlock:^(__unsafe_unretained Class c, BOOL *stop) {
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
    __block id class = nil;
    if ([self respondsToSelector:@selector(objectClassInArray)]) {
        class = [self objectClassInArray][propertyName];
    }
    
    if (!class) {
        [self enumerateClassesWithBlock:^(__unsafe_unretained Class c, BOOL *stop) {
            NSDictionary *dict = objc_getAssociatedObject(c, &MJObjectClassInArrayKey);
            if (dict) {
                class = dict[propertyName];
            }
            if (class) *stop = YES;
        }];
    }
    
    // 如果是NSString类型
    if ([class isKindOfClass:[NSString class]]) {
        class = NSClassFromString(class);
    }
    return class;
}

#pragma mark - --公共方法--
+ (void)enumeratePropertiesWithBlock:(MJPropertiesBlock)block
{
    // 获得成员变量
    NSArray *cachedProperties = [self properties];
    
    // 遍历成员变量
    BOOL stop = NO;
    for (MJProperty *property in cachedProperties) {
        block(property, &stop);
        if (stop) break;
    }
}

+ (void)enumerateClassesWithBlock:(MJClassesBlock)block
{
    // 1.没有block就直接返回
    if (block == nil) return;
    
    // 2.停止遍历的标记
    BOOL stop = NO;
    
    // 3.当前正在遍历的类
    Class c = self;
    
    // 4.开始遍历每一个类
    while (c && !stop) {
        // 4.1.执行操作
        block(c, &stop);
        
        // 4.2.获得父类
        c = class_getSuperclass(c);
        
        if ([MJFoundation isClassFromFoundation:c]) break;
    }
}

#pragma mark - 公共方法
+ (NSArray *)properties
{
    static const char MJCachedPropertiesKey;
    
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
        [self enumerateClassesWithBlock:^(__unsafe_unretained Class c, BOOL *stop) {
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

+ (void)setupReplacedKeyFromPropertyName:(ReplacedKeyFromPropertyName)replacedKeyFromPropertyName objectClassInArray:(ObjectClassInArray)objectClassInArray
{
    [self setupObjectClassInArray:objectClassInArray];
    [self setupReplacedKeyFromPropertyName:replacedKeyFromPropertyName];
}

+ (void)setupObjectClassInArray:(ObjectClassInArray)objectClassInArray
{
    [self setupObjectWithBlock:objectClassInArray key:&MJObjectClassInArrayKey];
}

+ (void)setupReplacedKeyFromPropertyName:(ReplacedKeyFromPropertyName)replacedKeyFromPropertyName
{
    [self setupObjectWithBlock:replacedKeyFromPropertyName key:&MJReplacedKeyFromPropertyNameKey];
}

+ (void)setupIgnoredPropertyNames:(IgnoredPropertyNames)ignoredPropertyNames
{
    [self setupObjectWithBlock:ignoredPropertyNames key:&MJIgnoredPropertyNamesKey];
}

+ (NSArray *)totalIgnoredPropertyNames
{
    return [self totalObjectWithSelector:@selector(ignoredPropertyNames) key:&MJIgnoredPropertyNamesKey];
}

+ (void)setupIgnoredCodingPropertyNames:(IgnoredCodingPropertyNames)ignoredCodingPropertyNames
{
    [self setupObjectWithBlock:ignoredCodingPropertyNames key:&MJIgnoredCodingPropertyNamesKey];
}

+ (NSArray *)totalIgnoredCodingPropertyNames
{
    return [self totalObjectWithSelector:@selector(ignoredCodingPropertyNames) key:&MJIgnoredCodingPropertyNamesKey];
}

+ (void)setupAllowedPropertyNames:(AllowedPropertyNames)allowedPropertyNames;
{
    [self setupObjectWithBlock:allowedPropertyNames key:&MJAllowedPropertyNamesKey];
}

+ (NSArray *)totalAllowedPropertyNames
{
    return [self totalObjectWithSelector:@selector(allowedPropertyNames) key:&MJAllowedPropertyNamesKey];
}

+ (void)setupAllowedCodingPropertyNames:(AllowedCodingPropertyNames)allowedCodingPropertyNames
{
    [self setupObjectWithBlock:allowedCodingPropertyNames key:&MJAllowedCodingPropertyNamesKey];
}

+ (NSArray *)totalAllowedCodingPropertyNames
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

+ (NSArray *)totalObjectWithSelector:(SEL)selector key:(const char *)key
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
    
    [self enumerateClassesWithBlock:^(__unsafe_unretained Class c, BOOL *stop) {
        NSArray *subArray = objc_getAssociatedObject(c, key);
        [array addObjectsFromArray:subArray];
    }];
    return array;
}
@end
