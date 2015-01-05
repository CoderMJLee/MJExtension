//
//  Student.m
//  MJExtensionExample
//
//  Created by MJ Lee on 15/1/5.
//  Copyright (c) 2015年 itcast. All rights reserved.
//

#import "Student.h"
#import "MJExtension.h"

@implementation Student
- (NSDictionary *)replacedKeyFromPropertyName
{
    /** 属性ID映射成字典中的id */
    return @{@"ID" : @"id"};
}
@end
