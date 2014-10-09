//
//  MJTypeEncoding.m
//  MJExtension
//
//  Created by mj on 14-1-15.
//  Copyright (c) 2014年 itcast. All rights reserved.
//
#import <Foundation/Foundation.h>
/**
 *  成员变量类型（属性类型）
 */
NSString *const MJTypeInt = @"i";
NSString *const MJTypeFloat = @"f";
NSString *const MJTypeDouble = @"d";
NSString *const MJTypeLong = @"q";
NSString *const MJTypeLongLong = @"q";
NSString *const MJTypeChar = @"c";
NSString *const MJTypeBOOL = @"c";
NSString *const MJTypePointer = @"*";

NSString *const MJTypeIvar = @"^{objc_ivar=}";
NSString *const MJTypeMethod = @"^{objc_method=}";
NSString *const MJTypeBlock = @"@?";
NSString *const MJTypeClass = @"#";
NSString *const MJTypeSEL = @":";
NSString *const MJTypeId = @"@";

/**
 *  返回值类型(如果是unsigned，就是大写)
 */
NSString *const MJReturnTypeVoid = @"v";
NSString *const MJReturnTypeObject = @"@";



