//
//  MJStatusResult.m
//  字典与模型的互转
//
//  Created by MJ Lee on 14-5-21.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import "MJStatusResult.h"
#import "MJAd.h"

@implementation MJStatusResult
+ (NSDictionary *)mj_objectClassInCollection {
    return @{
             @"statuses" : @"MJStatus",
             @"ads" : MJAd.class // @"ads" : [MJAd class]
             };
}

@end
