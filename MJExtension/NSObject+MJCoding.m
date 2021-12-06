//
//  NSObject+MJCoding.m
//  MJExtension
//
//  Created by mj on 14-1-15.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import "NSObject+MJCoding.h"
#import "MJProperty.h"
#import "MJEClass.h"

@implementation NSObject (MJCoding)

- (void)mj_encode:(NSCoder *)encoder {
    MJEClass *mjeClass = [MJEClass cachedClass:self.class];
    [mjeClass->_allCodingProperties enumerateObjectsUsingBlock:^(MJProperty * _Nonnull property, NSUInteger idx, BOOL * _Nonnull stop) {
        id value = [property valueForObject:self];
        if (value == nil) return;
        [encoder encodeObject:value forKey:property.name];
    }];
}

- (void)mj_decode:(NSCoder *)decoder {
    MJEClass *mjeClass = [MJEClass cachedClass:self.class];
    [mjeClass->_allCodingProperties enumerateObjectsUsingBlock:^(MJProperty * _Nonnull property, NSUInteger idx, BOOL * _Nonnull stop) {
        // fixed `-[NSKeyedUnarchiver validateAllowedClass:forKey:] allowed unarchiving safe plist type ''NSNumber'(This will be disallowed in the future.)` warning.
        // If genericClass exists, property.type.typeClass would be a collection type(Array, Set, Dictionary). This scenario([obj, nil, obj, nil]) would not happened.
        NSSet *classes = [NSSet setWithObjects:NSNumber.class,
                          property.type.typeClass, property.classInArray, nil];
        id value = [decoder decodeObjectOfClasses:classes forKey:property.name];
        if (value == nil) { // 兼容以前的MJExtension版本
            value = [decoder decodeObjectForKey:[@"_" stringByAppendingString:property.name]];
        }
        if (value == nil) return;
        [property setValue:value forObject:self];
    }];
}
@end
