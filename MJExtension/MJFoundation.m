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
                              [NSObject class],
                              [NSURL class],
                              [NSDate class],
                              [NSNumber class],
                              [NSDecimalNumber class],
                              [NSData class],
                              [NSMutableData class],
                              [NSArray class],
                              [NSMutableArray class],
                              [NSDictionary class],
                              [NSMutableDictionary class],
                              [NSManagedObject class],
                              [NSString class],
                              [NSMutableString class], nil];
    }
    return _foundationClasses;
}

+ (BOOL)isClassFromFoundation:(Class)c
{
    return [[self foundatonClasses] containsObject:c];
}
@end
