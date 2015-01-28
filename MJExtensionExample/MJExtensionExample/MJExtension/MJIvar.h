//
//  MJIvar.h
//  MJExtension
//
//  Created by mj on 14-1-15.
//  Copyright (c) 2014年 itcast. All rights reserved.
//  包装一个成员变量

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
@class MJType;

/**
 *  包装一个成员变量
 */
@interface MJIvar : NSObject
/** 成员变量 */
@property (nonatomic, assign) Ivar ivar;
/** 成员名 */
@property (nonatomic, copy) NSString *name;
/** 成员属性名 */
@property (nonatomic, copy, readonly) NSString *propertyName;
/** 成员变量的类型 */
@property (nonatomic, strong, readonly) MJType *type;

/** 对应着字典中的key */
@property (nonatomic, copy) NSString *key;
/** 对应着字典中的多级key */
@property (nonatomic, strong) NSArray *keys;
/** 模型数组中的模型类型 */
@property (nonatomic, assign) Class objectClassInArray;

/** 成员来源于哪个类（可能是父类） */
@property (nonatomic, assign) Class srcClass;

/**
 * 设置成员变量的值
 */
- (void)setValue:(id)value forObject:(id)object;
/**
 * 得到成员变量的值
 */
- (id)valueFromObject:(id)object;

/**
 *  初始化
 *
 *  @param ivar      成员变量
 *  @param srcObject 哪个对象的成员变量
 *
 *  @return 初始化好的对象
 */
- (instancetype)initWithIvar:(Ivar)ivar;
+ (instancetype)cachedIvarWithIvar:(Ivar)ivar;
@end