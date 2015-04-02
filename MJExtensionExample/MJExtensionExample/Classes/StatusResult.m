//
//  StatusResult.m
//  字典与模型的互转
//
//  Created by MJ Lee on 14-5-21.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "StatusResult.h"
//#import "MJExtension.h"
//#import "Status.h"
//#import "Ad.h"
// 其实只要objectClassInArray方法敲出来了，这几个头文件都可以删掉了，这样就更加没有侵入性

@implementation StatusResult
// 实现这个方法的目的：告诉MJExtension框架statuses和ads数组里面装的是什么模型
//+ (NSDictionary *)objectClassInArray
//{
//    return @{
//         @"statuses" : [Status class],
//         @"ads" : [Ad class]
//    };
//}

// 新方法更加没有侵入性和污染
+ (NSDictionary *)objectClassInArray
{
    return @{
         @"statuses" : @"Status",
         @"ads" : @"Ad"
    };
}

//+ (Class)objectClassInArray:(NSString *)propertyName
//{
//    if ([propertyName isEqualToString:@"statuses"]) {
//        return [Status class];
//    } else if ([propertyName isEqualToString:@"ads"]) {
//        return [Ad class];
//    }
//    return nil;
//}
@end
