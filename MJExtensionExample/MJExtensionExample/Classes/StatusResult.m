//
//  StatusResult.m
//  字典与模型的互转
//
//  Created by MJ Lee on 14-5-21.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "StatusResult.h"
#import "MJExtension.h"
#import "Status.h"
#import "Ad.h"

@implementation StatusResult
- (NSDictionary *)objectClassInArray
{
    return @{
         @"statuses" : [Status class],
         @"ads" : [Ad class]
    };
}
@end
