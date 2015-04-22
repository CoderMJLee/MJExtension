//
//  User.m
//  字典与模型的互转
//
//  Created by MJ Lee on 14-5-21.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "User.h"
#import "MJExtension.h"

@implementation User

/**
 * 哪些属性需要忽略，不参与Coding
 */
+ (NSArray *)ignoredCodingPropertyNames
{
    return @[@"icon", @"age"];
}

// NSCoding实现
MJCodingImplementation
@end
