//
//  NSObject+MJCoding.m
//  MJExtension
//
//  Created by mj on 14-1-15.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "NSObject+MJCoding.h"
#import "NSObject+MJIvar.h"

@implementation NSObject (MJCoding)
/**
 *  编码（将对象写入文件中）
 */
- (void)encode:(NSCoder *)encoder
{
    [self enumerateIvarsWithBlock:^(MJIvar *ivar, BOOL *stop) {
        [encoder encodeObject:[ivar valueFromObject:self] forKey:ivar.name];
    }];
}

/**
 *  解码（从文件中解析对象）
 */
- (void)decode:(NSCoder *)decoder
{
    [self enumerateIvarsWithBlock:^(MJIvar *ivar, BOOL *stop) {
        id value = [decoder decodeObjectForKey:ivar.name];
        [ivar setValue:value forObject:self];
    }];
}
@end
