//
//  MJFrenchUser.m
//  MJExtensionTests
//
//  Created by Frank on 2019/9/26.
//  Copyright © 2019 MJ Lee. All rights reserved.
//

#import "MJFrenchUser.h"

@implementation MJFrenchUser

+ (NSLocale *)mj_numberLocale {
    return [NSLocale localeWithLocaleIdentifier:@"fr_FR"];//ru_RU
}

/// Depreacated API
+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"cats": MJCat.class
    };
}

@end
