//
//  Base.m
//  MJExtensionExample
//
//  Created by 陆晖 on 16/2/25.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import "Base.h"

@implementation Base

+ (NSMutableArray *)mj_identityPropertyNames {
    return [NSMutableArray arrayWithObjects:@"objectId", nil];
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"objectId": @"id"};
}

@end
