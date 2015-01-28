//
//  NSObject+MJCoding.m
//  MJExtension
//
//  Created by mj on 14-1-15.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "NSObject+MJCoding.h"
#import "NSObject+MJIvar.h"
#import "MJIvar.h"

@implementation NSObject (MJCoding)

- (void)encode:(NSCoder *)encoder
{
    [[self class] enumerateIvarsWithBlock:^(MJIvar *ivar, BOOL *stop) {
        [encoder encodeObject:[ivar valueFromObject:self] forKey:ivar.name];
    }];
}

- (void)decode:(NSCoder *)decoder
{
    [[self class] enumerateIvarsWithBlock:^(MJIvar *ivar, BOOL *stop) {
        id value = [decoder decodeObjectForKey:ivar.name];
        [ivar setValue:value forObject:self];
    }];
}
@end
