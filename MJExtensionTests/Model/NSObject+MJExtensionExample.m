//
//  NSObject+MJExtensionExample.m
//  MJExtensionTests
//
//  Created by Frank on 2021/12/2.
//  Copyright © 2021 MJ Lee. All rights reserved.
//

#import "NSObject+MJExtensionExample.h"

@import MJExtension;

@implementation NSObject (MJExtensionExample)

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
        @"ID" : @"id"
    };
}

@end
