//
//  NSObject+MJIvar.m
//  MJExtension
//
//  Created by mj on 14-1-15.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "MJIvar.h"
#import "NSObject+MJIvar.h"
#import "NSObject+MJKeyValue.h"
#import "MJFoundation.h"

@implementation NSObject (MJMember)

#pragma mark - --私有方法--
+ (NSString *)ivarKey:(NSString *)propertyName
{
    MJAssertParamNotNil2(propertyName, nil);
    
    NSString *key = nil;
    // 1.查看有没有需要替换的key
    if ([self respondsToSelector:@selector(replacedKeyFromPropertyName:)]) {
        key = [self replacedKeyFromPropertyName:propertyName];
    } else if ([self respondsToSelector:@selector(replacedKeyFromPropertyName)]) {
        key = self.replacedKeyFromPropertyName[propertyName];
    } else {
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

+ (Class)ivarObjectClassInArray:(NSString *)propertyName
{
    if ([self respondsToSelector:@selector(objectClassInArray)]) {
        return self.objectClassInArray[propertyName];
    } else {
        // 为了兼容以前的对象方法
        id tempObject = self.tempObject;
        if ([tempObject respondsToSelector:@selector(objectClassInArray)]) {
            id dict = [tempObject objectClassInArray];
            return dict[propertyName];
        }
        return nil;
    }
    return nil;
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

+ (void)enumerateIvarsWithBlock:(MJIvarsBlock)block
{
    static const char MJCachedIvarsKey;
    // 获得成员变量
    NSMutableArray *cachedIvars = objc_getAssociatedObject(self, &MJCachedIvarsKey);
    if (cachedIvars == nil) {
        cachedIvars = [NSMutableArray array];
        
        [self enumerateClassesWithBlock:^(__unsafe_unretained Class c, BOOL *stop) {
            // 1.获得所有的成员变量
            unsigned int outCount = 0;
            Ivar *ivars = class_copyIvarList(c, &outCount);
            
            // 2.遍历每一个成员变量
            for (unsigned int i = 0; i<outCount; i++) {
                MJIvar *ivar = [MJIvar cachedIvarWithIvar:ivars[i]];
                ivar.srcClass = c;
                NSString *key = [self ivarKey:ivar.propertyName];
                [ivar setKey:key forClass:self];
                // 数组中的模型类
                [ivar setObjectClassInArray:[self ivarObjectClassInArray:ivar.propertyName] forClass:self];
                [cachedIvars addObject:ivar];
            }
            
            // 3.释放内存
            free(ivars);
        }];
        objc_setAssociatedObject(self, &MJCachedIvarsKey, cachedIvars, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    // 遍历成员变量
    BOOL stop = NO;
    for (MJIvar *ivar in cachedIvars) {
        block(ivar, &stop);
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
