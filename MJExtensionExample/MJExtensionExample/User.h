//
//  User.h
//  字典与模型的互转
//
//  Created by MJ Lee on 14-5-21.
//  Copyright (c) 2014年 itcast. All rights reserved.
//  用户模型

#import <Foundation/Foundation.h>

@interface User : NSObject
/**
 *  名称
 */
@property (copy, nonatomic) NSString *name;

/**
 *  头像
 */
@property (copy, nonatomic) NSString *icon;
@end
