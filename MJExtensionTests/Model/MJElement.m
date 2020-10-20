//
//  MJElement.m
//  MJExtensionTests
//
//  Created by libin14 on 2020/10/20.
//  Copyright © 2020 MJ Lee. All rights reserved.
//

#import "MJElement.h"

@implementation MJElement

+ (NSArray *)mj_ignoredPropertyNames {
    return @[@"count"];
}

@end

@implementation MJRenderElement

+ (NSArray *)mj_ignoredPropertyNames {
    return @[@"renderName"];
}

@end

