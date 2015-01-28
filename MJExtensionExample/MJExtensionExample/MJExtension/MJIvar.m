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

@implementation MJIvar

+ (instancetype)cachedIvarWithIvar:(Ivar)ivar
{
    MJIvar *ivarObject = objc_getAssociatedObject(self, ivar);
    if (ivarObject == nil) {
        ivarObject = [[self alloc] initWithIvar:ivar];
        objc_setAssociatedObject(self, ivar, ivarObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return ivarObject;
}

/**
 *  初始化
 *
 *  @param ivar      成员变量
 *  @param srcObject 哪个对象的成员变量
 *
 *  @return 初始化好的对象
 */
- (instancetype)initWithIvar:(Ivar)ivar
{
    if (self = [super init]) {
        self.ivar = ivar;
    }
    return self;
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
    if (_type.KVCDisabled) return;
    [object setValue:value forKey:_propertyName];
}
@end
