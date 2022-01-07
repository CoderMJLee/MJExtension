//
//  MJUser.m
//  字典与模型的互转
//
//  Created by MJ Lee on 14-5-21.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import "MJUser.h"

@import MJExtension;

@interface MJUser() <MJEConfiguration>

@end

@implementation MJUser
//+ (NSArray *)mj_allowedPropertyNames {
//    return @[@"name", @"icon"];
//}

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
        @"speed": @[@"size.width", @"speed"]
    };
}
MJExtensionLogAllProperties
@end
