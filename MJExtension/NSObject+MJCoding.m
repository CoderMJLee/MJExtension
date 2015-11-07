//
//  NSObject+MJCoding.m
//  MJExtension
//
//  Created by mj on 14-1-15.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import "NSObject+MJCoding.h"
#import "NSObject+MJClass.h"
#import "NSObject+MJProperty.h"
#import "MJProperty.h"

@implementation NSObject (MJCoding)

- (void)mj_encode:(NSCoder *)encoder
{
    Class aClass = [self class];
    
    NSArray *allowedCodingPropertyNames = [aClass mj_totalAllowedCodingPropertyNames];
    NSArray *ignoredCodingPropertyNames = [aClass mj_totalIgnoredCodingPropertyNames];
    
    [aClass mj_enumerateProperties:^(MJProperty *property, BOOL *stop) {
        // 检测是否被忽略
        if (allowedCodingPropertyNames.count && ![allowedCodingPropertyNames containsObject:property.name]) return;
        if ([ignoredCodingPropertyNames containsObject:property.name]) return;
        
        id value = [property valueForObject:self];
        if (value == nil) return;
        [encoder encodeObject:value forKey:property.name];
    }];
}

- (void)mj_decode:(NSCoder *)decoder
{
    Class aClass = [self class];
    
    NSArray *allowedCodingPropertyNames = [aClass mj_totalAllowedCodingPropertyNames];
    NSArray *ignoredCodingPropertyNames = [aClass mj_totalIgnoredCodingPropertyNames];
    
    [aClass mj_enumerateProperties:^(MJProperty *property, BOOL *stop) {
        // 检测是否被忽略
        if (allowedCodingPropertyNames.count && ![allowedCodingPropertyNames containsObject:property.name]) return;
        if ([ignoredCodingPropertyNames containsObject:property.name]) return;
        
        id value = [decoder decodeObjectForKey:property.name];
        if (value == nil) { // 兼容以前的MJExtension版本
            value = [decoder decodeObjectForKey:[@"_" stringByAppendingString:property.name]];
        }
        if (value == nil) return;
        [property setValue:value forObject:self];
    }];
}
@end
