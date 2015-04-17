//
//  NSObject+MJProperty.h
//  MJExtensionExample
//
//  Created by MJ Lee on 15/4/17.
//  Copyright (c) 2015年 itcast. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MJProperty;

/**
 *  遍历所有类的block（父类）
 */
typedef void (^MJClassesBlock)(Class c, BOOL *stop);

/**
 *  遍历成员变量用的block
 *
 *  @param property 成员的包装对象
 *  @param stop   YES代表停止遍历，NO代表继续遍历
 */
typedef void (^MJPropertiesBlock)(MJProperty *property, BOOL *stop);

@interface NSObject (MJProperty)

/**
 *  遍历所有的成员
 */
+ (void)enumeratePropertiesWithBlock:(MJPropertiesBlock)block;

/**
 *  遍历所有的类
 */
+ (void)enumerateClassesWithBlock:(MJClassesBlock)block;

/**
 *  返回一个临时对象
 */
+ (instancetype)tempObject;
@end