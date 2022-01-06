//
//  MJStudent.m
//  MJExtensionExample
//
//  Created by MJ Lee on 15/1/5.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "MJStudent.h"

@implementation MJStudent
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
        @"desc" : @"description",
        @"oldName" : @"name.oldName",
        @"nowName" : @"name.newName",
        @"otherName" : @[@"otherName", @"name.newName", @"name.oldName"],
        @"nameChangedTime" : @"name.info[1].nameChangedTime",
        @"bag" : @"other.bag"
        };
}
@end
