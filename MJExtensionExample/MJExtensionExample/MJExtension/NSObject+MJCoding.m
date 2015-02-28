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
    NSArray *ignoredCodingPropertyNames = nil;
    if ([[self class] respondsToSelector:@selector(ignoredCodingPropertyNames)]) {
        ignoredCodingPropertyNames = [[self class] ignoredCodingPropertyNames];
    }
    
    [[self class] enumerateIvarsWithBlock:^(MJIvar *ivar, BOOL *stop) {
        // 检测是否被忽略
        if ([ignoredCodingPropertyNames containsObject:ivar.propertyName]) return;
        
        id value = [ivar valueFromObject:self];
        if (value == nil) return;
        [encoder encodeObject:value forKey:ivar.name];
    }];
}

- (void)decode:(NSCoder *)decoder
{
    NSArray *ignoredCodingPropertyNames = nil;
    if ([[self class] respondsToSelector:@selector(ignoredCodingPropertyNames)]) {
        ignoredCodingPropertyNames = [[self class] ignoredCodingPropertyNames];
    }
    
    [[self class] enumerateIvarsWithBlock:^(MJIvar *ivar, BOOL *stop) {
        // 检测是否被忽略
        if ([ignoredCodingPropertyNames containsObject:ivar.propertyName]) return;
        
        id value = [decoder decodeObjectForKey:ivar.name];
        if (value == nil) return;
        [ivar setValue:value forObject:self];
    }];
}
@end
