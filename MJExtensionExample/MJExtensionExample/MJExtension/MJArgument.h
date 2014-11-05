//
//  MJArgument.h
//  ItcastWeibo
//
//  Created by mj on 14-1-15.
//  Copyright (c) 2014年 itcast. All rights reserved.
//  包装一个方法参数

#import <Foundation/Foundation.h>
/**
 *  包装一个方法参数
 */
@interface MJArgument : NSObject
/** 参数的索引 */
@property (nonatomic, assign) NSInteger index;
/** 参数类型 */
@property (nonatomic, copy) NSString *type;
@end
