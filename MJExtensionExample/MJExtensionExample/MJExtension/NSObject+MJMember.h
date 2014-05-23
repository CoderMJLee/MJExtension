//
//  NSObject+MJMember.h
//  MJExtension
//
//  Created by mj on 14-1-15.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJIvar.h"
#import "MJMethod.h"

/**
 *  遍历所有类的block（父类）
 */
typedef void (^MJClassesBlock)(Class c, BOOL *stop);

@interface NSObject (MJMember)

/**
 *  遍历所有的成员变量
 */
- (void)enumerateIvarsWithBlock:(MJIvarsBlock)block;

/**
 *  遍历所有的方法
 */
- (void)enumerateMethodsWithBlock:(MJMethodsBlock)block;

/**
 *  遍历所有的类
 */
- (void)enumerateClassesWithBlock:(MJClassesBlock)block;
@end
