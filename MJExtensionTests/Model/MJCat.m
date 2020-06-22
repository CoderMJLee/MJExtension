//
//  MJCat.m
//  MJExtensionTests
//
//  Created by Frank on 2020/6/9.
//  Copyright © 2020 MJ Lee. All rights reserved.
//

#import "MJCat.h"

@implementation MJCat

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"nicknames" : NSString.class
    };
}

@end
