//
//  MJBag.m
//  MJExtensionExample
//
//  Created by MJ Lee on 15/1/28.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "MJBag.h"

@import MJExtension;

// NSSecureCoding实现
MJSecureCodingImplementation(MJBag, YES)

@implementation MJBag

//+ (NSArray *)mj_ignoredCodingPropertyNames
//{
//    return @[@"name"];
//}
@end
