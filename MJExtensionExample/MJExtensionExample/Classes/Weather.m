//
//  Weather.m
//  MJExtensionExample
//
//  Created by 开发者 on 15/4/9.
//  Copyright (c) 2015年 itcast. All rights reserved.
//

#import "Weather.h"

@implementation Weather

// 实现这个方法的目的：告诉MJExtension框架temperatures和cloud数组里面装的是什么模型
+ (NSDictionary *)objectClassInArray
{
    return @{
         @"temperatures" : [NSNumber class],
         @"cloud" : [NSDictionary class]
    };
}
@end
