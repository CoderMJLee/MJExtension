//
//  NSObject+MJProperty.m
//  MJExtensionExample
//
//  Created by MJ Lee on 15/4/17.
//  Copyright (c) 2015年 itcast. All rights reserved.
//

#import "NSObject+MJProperty.h"
#import "NSObject+MJKeyValue.h"
#import "MJProperty.h"
#import "MJFoundation.h"
#import <objc/runtime.h>
#import <CoreData/CoreData.h>

@implementation NSObject (MJMember)
#pragma mark - --私有方法--
+ (NSString *)propertyKey:(NSString *)propertyName
{
    MJAssertParamNotNil2(propertyName, nil);
    
    NSString *key = nil;
    // 1.查看有没有需要替换的key
    if ([self respondsToSelector:@selector(replacedKeyFromPropertyName:)]) {
        key = [self replacedKeyFromPropertyName:propertyName];
    } else if ([self respondsToSelector:@selector(replacedKeyFromPropertyName)]) {
        key = self.replacedKeyFromPropertyName[propertyName];
    } else if (![self isSubclassOfClass:[NSManagedObject class]]) { // 如果不是CoreData对象
        // 为了兼容以前的对象方法
        id tempObject = self.tempObject;
        if ([tempObject respondsToSelector:@selector(replacedKeyFromPropertyName)]) {
            key = [tempObject replacedKeyFromPropertyName][propertyName];
        }
    }
    
    // 2.用属性名作为key
    if (!key) key = propertyName;
    
    return key;
}

+ (Class)propertyObjectClassInArray:(NSString *)propertyName
{
    id class = nil;
    if ([self respondsToSelector:@selector(objectClassInArray:)]) {
        class = [self objectClassInArray:propertyName];
    } else if ([self respondsToSelector:@selector(objectClassInArray)]) {
        class = self.objectClassInArray[propertyName];
    } else if (![self isSubclassOfClass:[NSManagedObject class]]) { // 如果不是CoreData对象
        // 为了兼容以前的对象方法
        id tempObject = self.tempObject;
        if ([tempObject respondsToSelector:@selector(objectClassInArray)]) {
            id dict = [tempObject objectClassInArray];
            class = dict[propertyName];
        }
    }
    // 如果是NSString类型
    if ([class isKindOfClass:[NSString class]]) {
        class = NSClassFromString(class);
    }
    return class;
}

#pragma mark - --公共方法--
+ (instancetype)tempObject
{
    static const char MJTempObjectKey;
    id tempObject = objc_getAssociatedObject(self, &MJTempObjectKey);
    if (tempObject == nil) {
        tempObject = [[self alloc] init];
        objc_setAssociatedObject(self, &MJTempObjectKey, tempObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return tempObject;
}

+ (void)enumeratePropertiesWithBlock:(MJPropertiesBlock)block
{
    static const char MJCachedPropertiesKey;
    // 获得成员变量
    NSMutableArray *cachedProperties = objc_getAssociatedObject(self, &MJCachedPropertiesKey);
    if (cachedProperties == nil) {
        cachedProperties = [NSMutableArray array];
        
        [self enumerateClassesWithBlock:^(__unsafe_unretained Class c, BOOL *stop) {
            // 1.获得所有的成员变量
            unsigned int outCount = 0;
            objc_property_t *properties = class_copyPropertyList(c, &outCount);
            
            // 2.遍历每一个成员变量
            for (unsigned int i = 0; i<outCount; i++) {
                MJProperty *property = [MJProperty cachedPropertyWithProperty:properties[i]];
                property.srcClass = c;
                NSString *key = [self propertyKey:property.name];
                [property setKey:key forClass:self];
                // 数组中的模型类
                [property setObjectClassInArray:[self propertyObjectClassInArray:property.name] forClass:self];
                [cachedProperties addObject:property];
            }
            
            // 3.释放内存
            free(properties);
        }];
        objc_setAssociatedObject(self, &MJCachedPropertiesKey, cachedProperties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
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
@end
