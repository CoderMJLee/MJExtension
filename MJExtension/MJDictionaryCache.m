//
//  MJDictionaryCache.m
//  MJExtensionExample
//
//  Created by MJ Lee on 15/8/22.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//  //  我发现了一个非常大的Bug, 哈哈哈哈哈哈哈哈哈

#import "MJDictionaryCache.h"
#import <objc/runtime.h>

@implementation MJDictionaryCache
+ (id)setObject:(id)object forKey:(id<NSCopying>)key forDictId:(const void *)dictId
{
    // 获得字典
    NSMutableDictionary *dict = [self dictWithDictId:dictId];
    if (dict == nil) {
        dict = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, dictId, dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    // 存储数据
    dict[key] = object;
    
    return dict;
}

+ (id)objectForKey:(id<NSCopying>)key forDictId:(const void *)dictId
{
    return [self dictWithDictId:dictId][key];
}

+ (id)dictWithDictId:(const void *)dictId
{
    return objc_getAssociatedObject(self, dictId);
}
@end