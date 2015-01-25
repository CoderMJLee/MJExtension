//
//  NSObject+MJIvar.m
//  MJExtension
//
//  Created by mj on 14-1-15.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "NSObject+MJIvar.h"
#import "NSObject+MJKeyValue.h"
#import "MJFoundation.h"

@implementation NSObject (MJMember)

static const char MJCachedIvarsKey;
- (NSArray *)cachedIvars
{
    NSMutableArray *cachedIvars = objc_getAssociatedObject([self class], &MJCachedIvarsKey);
    if (cachedIvars == nil) {
        cachedIvars = [NSMutableArray array];
        
        [self enumerateClassesWithBlock:^(__unsafe_unretained Class c, BOOL *stop) {
            // 1.获得所有的成员变量
            unsigned int outCount = 0;
            Ivar *ivars = class_copyIvarList(c, &outCount);
            
            // 2.遍历每一个成员变量
            for (unsigned int i = 0; i<outCount; i++) {
                MJIvar *ivar = [MJIvar cachedIvarWithIvar:ivars[i]];
                ivar.key = [self keyWithPropertyName:ivar.propertyName];
                if ([self respondsToSelector:@selector(objectClassInArray)]) {
                    ivar.objectClassInArray = self.objectClassInArray[ivar.propertyName];
                }
                ivar.srcClass = c;
                [cachedIvars addObject:ivar];
            }
            
            // 3.释放内存
            free(ivars);
        }];
        objc_setAssociatedObject([self class], &MJCachedIvarsKey, cachedIvars, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cachedIvars;
}
    

/**
 *  遍历所有的成员变量
 */
- (void)enumerateIvarsWithBlock:(MJIvarsBlock)block
{
    NSArray *ivars = [self cachedIvars];
    BOOL stop = NO;
    for (MJIvar *ivar in ivars) {
        block(ivar, &stop);
        if (stop) break;
    }
}

/**
 *  遍历所有的类
 */
- (void)enumerateClassesWithBlock:(MJClassesBlock)block
{
    // 1.没有block就直接返回
    if (block == nil) return;
    
    // 2.停止遍历的标记
    BOOL stop = NO;
    
    // 3.当前正在遍历的类
    Class c = [self class];
    
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
