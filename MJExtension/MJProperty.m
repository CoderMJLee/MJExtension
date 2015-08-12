//
//  MJProperty.m
//  MJExtensionExample
//
//  Created by MJ Lee on 15/4/17.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "MJProperty.h"
#import "MJFoundation.h"
#import "MJExtensionConst.h"

@interface MJProperty()
@property (strong, nonatomic) NSMutableDictionary *propertyKeysDict;
@property (strong, nonatomic) NSMutableDictionary *objectClassInArrayDict;
@end

@implementation MJProperty

/** originKey作为key，propertyKeys作为value */
static NSMutableDictionary *originKeyPropertyKey_;
+ (void)load
{
    originKeyPropertyKey_ = [NSMutableDictionary dictionary];
}

#pragma mark - 懒加载
- (NSMutableDictionary *)propertyKeysDict
{
    if (!_propertyKeysDict) {
        _propertyKeysDict = [NSMutableDictionary dictionary];
    }
    return _propertyKeysDict;
}

- (NSMutableDictionary *)objectClassInArrayDict
{
    if (!_objectClassInArrayDict) {
        _objectClassInArrayDict = [NSMutableDictionary dictionary];
    }
    return _objectClassInArrayDict;
}

#pragma mark - 缓存
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

#pragma mark - 公共方法
- (void)setProperty:(objc_property_t)property
{
    _property = property;
    
    MJExtensionAssertParamNotNil(property);
    
    // 1.属性名
    _name = @(property_getName(property));
    
    // 2.成员类型
    NSString *attrs = @(property_getAttributes(property));
    NSUInteger loc = 1;
    NSUInteger len = [attrs rangeOfString:@","].location - loc;
    _type = [MJPropertyType cachedTypeWithCode:[attrs substringWithRange:NSMakeRange(loc, len)]];
}

/**
 *  获得成员变量的值
 */
- (id)valueForObject:(id)object
{
    if (self.type.KVCDisabled) return [NSNull null];
    return [object valueForKey:self.name];
}

/**
 *  设置成员变量的值
 */
- (void)setValue:(id)value forObject:(id)object
{
    if (self.type.KVCDisabled || value == nil) return;
    [object setValue:value forKey:self.name];
}

/** 对应着字典中的key */
- (void)setOriginKey:(NSString *)originKey forClass:(Class)c
{
    if (originKey.length == 0) return;
    
    NSMutableArray *propertyKeys = originKeyPropertyKey_[originKey];
    if (propertyKeys == nil) {
        // 存放所有的key
        originKeyPropertyKey_[originKey] = propertyKeys = [NSMutableArray array];
        
        // 如果有多级映射
        NSArray *oldKeys = [originKey componentsSeparatedByString:@"."];
        
        for (NSString *oldKey in oldKeys) {
            NSUInteger start = [oldKey rangeOfString:@"["].location;
            if (start != NSNotFound) { // 有索引的key
                NSString *prefixKey = [oldKey substringToIndex:start];
                NSString *indexKey = prefixKey;
                if (prefixKey.length) {
                    MJPropertyKey *propertyKey = [[MJPropertyKey alloc] init];
                    propertyKey.name = prefixKey;
                    [propertyKeys addObject:propertyKey];
                    
                    indexKey = [oldKey stringByReplacingOccurrencesOfString:prefixKey withString:@""];
                }
                
                /** 解析索引 **/
                // 元素
                NSArray *cmps = [[indexKey stringByReplacingOccurrencesOfString:@"[" withString:@""] componentsSeparatedByString:@"]"];
                for (NSInteger i = 0; i<cmps.count - 1; i++) {
                    MJPropertyKey *subPropertyKey = [[MJPropertyKey alloc] init];
                    subPropertyKey.type = MJPropertyKeyTypeArray;
                    subPropertyKey.name = cmps[i];
                    [propertyKeys addObject:subPropertyKey];
                }
            } else { // 没有索引的key
                MJPropertyKey *propertyKey = [[MJPropertyKey alloc] init];
                propertyKey.name = oldKey;
                [propertyKeys addObject:propertyKey];
            }
        }
    }
    
    [self setPorpertyKeys:propertyKeys forClass:c];
}

/** 对应着字典中的多级key */
- (void)setPorpertyKeys:(NSArray *)propertyKeys forClass:(Class)c
{
    if (propertyKeys.count == 0) return;
    self.propertyKeysDict[NSStringFromClass(c)] = propertyKeys;
}
- (NSArray *)propertyKeysFromClass:(Class)c
{
    return self.propertyKeysDict[NSStringFromClass(c)];
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
