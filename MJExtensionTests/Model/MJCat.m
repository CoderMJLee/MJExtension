//
//  MJCat.m
//  MJExtensionTests
//
//  Created by Frank on 2020/6/9.
//  Copyright © 2020 MJ Lee. All rights reserved.
//

#import "MJCat.h"

// NSSecureCoding实现
MJSecureCodingImplementation(MJCat, YES)

@implementation MJCat

+ (NSDictionary *)mj_classInfoInCollection {
    return @{
        @"nicknames" : NSString.class
    };
}

@end
