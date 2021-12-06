//
//  MJPerson.m
//  MJExtensionTests
//
//  Created by MJ Lee on 2019/8/29.
//  Copyright © 2019 MJExtension. All rights reserved.
//

#import "MJPerson.h"
#import <MJExtension/MJExtension.h>

// NSSecureCoding实现
MJSecureCodingImplementation(MJPerson, YES)

@implementation MJPerson
+ (NSDictionary *)mj_objectClassInArray {
    return @{@"friends": [MJPerson class],
             @"books": [NSString class]};
}
@end
