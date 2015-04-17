//
//  NSString+MJExtension.m
//  TestTabBar
//
//  Created by MJ Lee on 15/4/17.
//  Copyright (c) 2015年 Mac Z. All rights reserved.
//

#import "NSString+MJExtension.h"

@implementation NSString (MJExtension)
- (id)JSONObject
{
    return [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
}
@end
