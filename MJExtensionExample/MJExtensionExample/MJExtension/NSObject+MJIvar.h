//
//  NSObject+MJIvar.h
//  MJExtension
//
//  Created by mj on 14-1-15.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MJIvar;

/**
 *  遍历所有类的block（父类）
 */
typedef void (^MJClassesBlock)(Class c, BOOL *stop);

/**
 *  遍历成员变量用的block
 *
 *  @param ivar 成员变量的包装对象
 *  @param stop       YES代表停止遍历，NO代表继续遍历
 */
typedef void (^MJIvarsBlock)(MJIvar *ivar, BOOL *stop);

@interface NSObject (MJMember)

/**
 *  遍历所有的成员变量
 */
+ (void)enumerateIvarsWithBlock:(MJIvarsBlock)block;

/**
 *  遍历所有的类
 */
+ (void)enumerateClassesWithBlock:(MJClassesBlock)block;

/**
 *  返回一个临时对象
 */
+ (instancetype)tempObject;
@end
