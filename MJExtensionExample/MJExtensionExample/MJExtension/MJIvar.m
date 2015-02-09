//
//  MJIvar.m
//  MJExtension
//
//  Created by mj on 14-1-15.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "MJIvar.h"
#import "MJType.h"
#import "MJFoundation.h"
#import "MJConst.h"

@interface MJIvar()
@property (strong, nonatomic) NSMutableDictionary *keyDict;
@property (strong, nonatomic) NSMutableDictionary *keysDict;
@property (strong, nonatomic) NSMutableDictionary *objectClassInArrayDict;
@end

@implementation MJIvar

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

+ (instancetype)cachedIvarWithIvar:(Ivar)ivar
{
    MJIvar *ivarObject = objc_getAssociatedObject(self, ivar);
    if (ivarObject == nil) {
        ivarObject = [[self alloc] init];
        ivarObject.ivar = ivar;
        objc_setAssociatedObject(self, ivar, ivarObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return ivarObject;
}

/**
 *  设置成员变量
 */
- (void)setIvar:(Ivar)ivar
{
    _ivar = ivar;
    
    MJAssertParamNotNil(ivar);
    
    // 1.成员变量名
    _name = @(ivar_getName(ivar));
    
    // 2.属性名
    if ([_name hasPrefix:@"_"]) {
        _propertyName = [_name stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
    } else {
        _propertyName = _name;
    }
    
    // 3.成员变量的类型符
    NSString *code = @(ivar_getTypeEncoding(ivar));
    _type = [MJType cachedTypeWithCode:code];
}

/**
 *  获得成员变量的值
 */
- (id)valueFromObject:(id)object
{
    if (_type.KVCDisabled) return [NSNull null];
    return [object valueForKey:_propertyName];
}

/**
 *  设置成员变量的值
 */
- (void)setValue:(id)value forObject:(id)object
{
    if (_type.KVCDisabled || value == nil) return;
    [object setValue:value forKey:_propertyName];
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
