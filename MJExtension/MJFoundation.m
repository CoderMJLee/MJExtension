//
//  MJFoundation.m
//  MJExtensionExample
//
//  Created by MJ Lee on 14/7/16.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import "MJFoundation.h"
#import "MJConst.h"
#import <CoreData/CoreData.h>

static NSSet *_foundationClasses;

@implementation MJFoundation

+ (NSSet *)foundatonClasses
{
    if (_foundationClasses == nil) {
        _foundationClasses = [NSSet setWithObjects:
                              [NSURL class],
                              [NSDate class],
                              [NSValue class],
                              [NSData class],
                              [NSArray class],
                              [NSDictionary class],
                              [NSManagedObject class],
                              [NSString class], nil];
    }
    return _foundationClasses;
}

+ (BOOL)isClassFromFoundation:(Class)c
{
    __block BOOL result = NO;
    [[self foundatonClasses] enumerateObjectsUsingBlock:^(Class obj, BOOL *stop) {
        if (c == [NSObject class] || c == obj || [c isSubclassOfClass:obj]) {
            result = YES;
        }
    }];
    return result;
}
@end
