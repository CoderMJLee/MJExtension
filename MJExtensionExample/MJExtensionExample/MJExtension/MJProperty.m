//
//  MJProperty.m
//  MJExtensionExample
//
//  Created by MJ Lee on 15/4/17.
//  Copyright (c) 2015年 itcast. All rights reserved.
//

#import "MJProperty.h"
#import "MJType.h"
#import "MJFoundation.h"
#import "MJConst.h"

@interface MJProperty()
@property (strong, nonatomic) NSMutableDictionary *keyDict;
@property (strong, nonatomic) NSMutableDictionary *keysDict;
@property (strong, nonatomic) NSMutableDictionary *objectClassInArrayDict;
@end

@implementation MJProperty

- (NSMutableDictionary *)keyDict
{
    if (!_keyDict) {
        self.keyDict = [NSMutableDictionary dictionary];
    }
    return _keyDict;
}

- (NSMutableDictionary *)keysDict
{
    if (!_keysDict) {
        self.keysDict = [NSMutableDictionary dictionary];
    }
    return _keysDict;
}

- (NSMutableDictionary *)objectClassInArrayDict
{
    if (!_objectClassInArrayDict) {
        self.objectClassInArrayDict = [NSMutableDictionary dictionary];
    }
    return _objectClassInArrayDict;
}

+ (instancetype)cachedPropertyWithProperty:(objc_property_t)property
{
    MJProperty *propertyObj = objc_getAssociatedObject(self, property);
    if (propertyObj == nil) {
        propertyObj = [[self alloc] init];
        propertyObj.property = property;
        objc_setAssociatedObject(self, property, propertyObj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return propertyObj;
}

- (void)setProperty:(objc_property_t)property
{
    _property = property;
    
    MJAssertParamNotNil(property);
    
    // 1.属性名
    _name = @(property_getName(property));
    
    // 2.成员类型
    NSString *attrs = @(property_getAttributes(property));
    NSUInteger loc = 1;
    NSUInteger len = [attrs rangeOfString:@","].location - loc;
    _type = [MJType cachedTypeWithCode:[attrs substringWithRange:NSMakeRange(loc, len)]];
}

/**
 *  获得成员变量的值
 */
- (id)valueFromObject:(id)object
{
    if (_type.KVCDisabled) return [NSNull null];
    return [object valueForKey:_name];
}

/**
 *  设置成员变量的值
 */
- (void)setValue:(id)value forObject:(id)object
{
    if (_type.KVCDisabled || value == nil) return;
    [object setValue:value forKey:_name];
}

/** 对应着字典中的key */
- (void)setKey:(NSString *)key forClass:(Class)c
{
    if (!key) return;
    self.keyDict[NSStringFromClass(c)] = key;
    // 如果有多级映射
    [self setKeys:[key componentsSeparatedByString:@"."] forClass:c];
}
- (NSString *)keyFromClass:(Class)c
{
    return self.keyDict[NSStringFromClass(c)];
}

/** 对应着字典中的多级key */
- (void)setKeys:(NSArray *)keys forClass:(Class)c
{
    if (!keys) return;
    self.keysDict[NSStringFromClass(c)] = keys;
}
- (NSArray *)keysFromClass:(Class)c
{
    return self.keysDict[NSStringFromClass(c)];
}

/** 模型数组中的模型类型 */
- (void)setObjectClassInArray:(Class)objectClass forClass:(Class)c
{
    if (!objectClass) return;
    self.objectClassInArrayDict[NSStringFromClass(c)] = objectClass;
}
- (Class)objectClassInArrayFromClass:(Class)c
{
    return self.objectClassInArrayDict[NSStringFromClass(c)];
}
@end
