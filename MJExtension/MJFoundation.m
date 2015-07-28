//
//  MJFoundation.m
//  MJExtensionExample
//
//  Created by MJ Lee on 14/7/16.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import "MJFoundation.h"
#import "MJExtensionConst.h"
#import <CoreData/CoreData.h>

static NSSet *_foundationClasses;

@implementation MJFoundation

+ (NSSet *)foundatonClasses
{
    if (_foundationClasses == nil) {
        // 集合中没有NSObject，因为几乎所有的类都是继承自NSObject，具体是不是NSObject需要特殊判断
        _foundationClasses = [NSSet setWithObjects:
                              [NSURL class],
                              [NSDate class],
                              [NSValue class],
                              [NSData class],
                              [NSArray class],
                              [NSDictionary class],
                              [NSString class],
                              [NSAttributedString class], nil];
    }
    return _foundationClasses;
}

+ (BOOL)isClassFromFoundation:(Class)c
{
    if (c == [NSObject class] || c == [NSManagedObject class]) return YES;
    
    __block BOOL result = NO;
    [[self foundatonClasses] enumerateObjectsUsingBlock:^(Class foundationClass, BOOL *stop) {
        if (c == foundationClass || [c isSubclassOfClass:foundationClass]) {
            result = YES;
            *stop = YES;
        }
    }];
    return result;
}
@end
