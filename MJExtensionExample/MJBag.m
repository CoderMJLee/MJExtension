//
//  MJBag.m
//  MJExtensionExample
//
//  Created by MJ Lee on 15/1/28.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "MJBag.h"
#import "MJExtension.h"

@implementation MJBag
/** 实现协议属性 */
@synthesize modelID = _modelID;

// NSCoding实现
MJExtensionCodingImplementation

//+ (NSArray *)mj_ignoredCodingPropertyNames
//{
//    return @[@"name"];
//}
@end
