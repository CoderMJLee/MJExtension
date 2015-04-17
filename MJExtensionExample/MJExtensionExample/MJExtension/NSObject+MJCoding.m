//
//  NSObject+MJCoding.m
//  MJExtension
//
//  Created by mj on 14-1-15.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "NSObject+MJCoding.h"
#import "NSObject+MJProperty.h"
#import "MJProperty.h"

@implementation NSObject (MJCoding)

- (void)encode:(NSCoder *)encoder
{
    NSArray *ignoredCodingPropertyNames = nil;
    if ([[self class] respondsToSelector:@selector(ignoredCodingPropertyNames)]) {
        ignoredCodingPropertyNames = [[self class] ignoredCodingPropertyNames];
    }
    
    [[self class] enumeratePropertiesWithBlock:^(MJProperty *property, BOOL *stop) {
        // 检测是否被忽略
        if ([ignoredCodingPropertyNames containsObject:property.name]) return;
        
        id value = [property valueFromObject:self];
        if (value == nil) return;
        [encoder encodeObject:value forKey:property.name];
    }];
}

- (void)decode:(NSCoder *)decoder
{
    NSArray *ignoredCodingPropertyNames = nil;
    if ([[self class] respondsToSelector:@selector(ignoredCodingPropertyNames)]) {
        ignoredCodingPropertyNames = [[self class] ignoredCodingPropertyNames];
    }
    
    [[self class] enumeratePropertiesWithBlock:^(MJProperty *property, BOOL *stop) {
        // 检测是否被忽略
        if ([ignoredCodingPropertyNames containsObject:property.name]) return;
        
        id value = [decoder decodeObjectForKey:property.name];
        if (value == nil) return;
        [property setValue:value forObject:self];
    }];
}
@end
