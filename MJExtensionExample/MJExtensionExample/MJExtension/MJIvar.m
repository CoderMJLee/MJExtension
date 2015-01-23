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
#import "MJTypeEncoding.h"
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
    _name = [NSString stringWithUTF8String:ivar_getName(ivar)];
    
    // 2.属性名
    if ([_name hasPrefix:@"_"]) {
        _propertyName = [_name stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
    } else {
        _propertyName = _name;
    }
    
    // 3.成员变量的类型符
    NSString *code = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
    _type = [MJType cachedTypeWithCode:code];
}

/**
 *  获得成员变量的值
 */
- (id)value
{
    if (_type.KVCDisabled) return [NSNull null];
    return [_srcObject valueForKey:_propertyName];
}

/**
 *  设置成员变量的值
 */
- (void)setValue:(id)value
{
    if (_type.KVCDisabled) return;
    [_srcObject setValue:value forKey:_propertyName];
}

/**
 * 成员来源于哪个类（可能是父类
 */
- (void)setSrcClass:(Class)srcClass
{
    _srcClass = srcClass;
    
    MJAssertParamNotNil(srcClass);
    
    _srcClassFromFoundation = [MJFoundation isClassFromFoundation:srcClass];
}
@end
