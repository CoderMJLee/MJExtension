//
//  MJPerson.m
//  MJExtensionTests
//
//  Created by MJ Lee on 2019/8/29.
//  Copyright © 2019 MJExtension. All rights reserved.
//

#import "MJPerson.h"
#import <MJExtension/MJExtension.h>

@implementation MJPerson
+ (NSDictionary *)mj_objectClassInCollection {
    return  @{@"friends" : @"MJPerson"};
}
@end
