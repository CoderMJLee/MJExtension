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
#import "objc/runtime.h"

@implementation MJFoundation

+ (BOOL)isClassFromFoundation:(Class)c
{
    if (c == [NSObject class] || c == [NSManagedObject class]) return YES;
    
    static NSSet *foundationClasses;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 集合中没有NSObject，因为几乎所有的类都是继承自NSObject，具体是不是NSObject需要特殊判断
        foundationClasses = [NSSet setWithObjects:
                              [NSURL class],
                              [NSDate class],
                              [NSValue class],
                              [NSData class],
                              [NSError class],
                              [NSArray class],
                              [NSDictionary class],
                              [NSString class],
                              [NSAttributedString class], nil];
    });
    
    __block BOOL result = NO;
    [foundationClasses enumerateObjectsUsingBlock:^(Class foundationClass, BOOL *stop) {
        if ([c isSubclassOfClass:foundationClass]) {
            result = YES;
            *stop = YES;
        }
    }];
    return result;
}

+ (BOOL)isFromNSObjectProtocolProperty:(NSString *)propertyName
{
    if (!propertyName) return NO;
    
    static NSSet<NSString *> *mj_NSObjectProtocolPropertyNames;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mj_NSObjectProtocolPropertyNames = [self mj_NSObjectProtocolPropetyNames];
    });
    return [mj_NSObjectProtocolPropertyNames containsObject:propertyName];
}

/**
 @return Get all NSObject Protocol property
 */
+ (NSSet<NSString *> *)mj_NSObjectProtocolPropetyNames {
    unsigned int count = 0;
    // get property content
    objc_property_t *propertyList = protocol_copyPropertyList(@protocol(NSObject), &count);
    // create collection with capacity
    NSMutableSet *propertyNames = [NSMutableSet setWithCapacity:count];
    for (int i = 0; i < count; i++) {
        objc_property_t property = propertyList[i];
        // get each propery name
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        [propertyNames addObject:propertyName];
    }
    return [propertyNames copy];
}

@end
