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
    Class clazz = [self class];
    
    NSArray *allowedCodingPropertyNames = [clazz mj_totalAllowedCodingPropertyNames];
    NSArray *ignoredCodingPropertyNames = [clazz mj_totalIgnoredCodingPropertyNames];
    
    [clazz mj_enumerateProperties:^(MJProperty *property, BOOL *stop) {
        // 检测是否被忽略
        if (allowedCodingPropertyNames.count && ![allowedCodingPropertyNames containsObject:property.name]) return;
        if ([ignoredCodingPropertyNames containsObject:property.name]) return;
        
        id value = [property valueForObject:self];
        if (value == nil) return;
        
        const NSString *const propertyCode = property.type.code.lowercaseString;
        if ([propertyCode isEqualToString:MJPropertyTypeDouble]) {
            if ([value respondsToSelector:@selector(doubleValue)]) {
                [encoder encodeDouble:[(NSNumber *)value doubleValue] forKey:property.name];
            }
        } else if ([propertyCode isEqualToString:MJPropertyTypeInt] || [propertyCode isEqualToString:MJPropertyTypeShort]) {
            if ([value respondsToSelector:@selector(intValue)]) {
                [encoder encodeInt:[(NSNumber *)value intValue] forKey:property.name];
            }
        }  else if ([propertyCode isEqualToString:MJPropertyTypeFloat]) {
            if ([value respondsToSelector:@selector(floatValue)]) {
                [encoder encodeFloat:[(NSNumber *)value floatValue] forKey:property.name];
            }
        } else if ([propertyCode isEqualToString:MJPropertyTypeLongLong] || [propertyCode isEqualToString:MJPropertyTypeLong]) {
            if ([value respondsToSelector:@selector(longLongValue)]) {
                [encoder encodeInt64:[(NSNumber *)value longLongValue] forKey:property.name];
            }
        } else if ([propertyCode isEqualToString:MJPropertyTypeBOOL1] || [propertyCode isEqualToString:MJPropertyTypeBOOL2]) {
            if ([value respondsToSelector:@selector(boolValue)]) {
                [encoder encodeBool:[(NSNumber *)value boolValue] forKey:property.name];
            }
        } else {
            [encoder encodeObject:value forKey:property.name];
        }
    }];
}

- (void)mj_decode:(NSCoder *)decoder
{
    Class clazz = [self class];
    
    NSArray *allowedCodingPropertyNames = [clazz mj_totalAllowedCodingPropertyNames];
    NSArray *ignoredCodingPropertyNames = [clazz mj_totalIgnoredCodingPropertyNames];
    
    [clazz mj_enumerateProperties:^(MJProperty *property, BOOL *stop) {
        // 检测是否被忽略
        if (allowedCodingPropertyNames.count && ![allowedCodingPropertyNames containsObject:property.name]) return;
        if ([ignoredCodingPropertyNames containsObject:property.name]) return;
        
        /// 先兼容之前的 encodeObject 的 case
        id value = [decoder decodeObjectForKey:property.name];
        if (value == nil) { // 兼容以前的MJExtension版本
            value = [decoder decodeObjectForKey:[@"_" stringByAppendingString:property.name]];
        }
        
        if (value == nil) {
            const NSString *const propertyCode = property.type.code.lowercaseString;
            if ([propertyCode isEqualToString:MJPropertyTypeDouble]) {
                double actual = [decoder decodeDoubleForKey:property.name];;
                value = [NSNumber numberWithDouble:actual];
            } else if ([propertyCode isEqualToString:MJPropertyTypeInt] || [propertyCode isEqualToString:MJPropertyTypeShort]) {
                int actual = [decoder decodeIntForKey:property.name];;
                value = [NSNumber numberWithInt:actual];
            } else if ([propertyCode isEqualToString:MJPropertyTypeFloat]) {
                float actual = [decoder decodeFloatForKey:property.name];;
                value = [NSNumber numberWithFloat:actual];
            } else if ([propertyCode isEqualToString:MJPropertyTypeLong] || [propertyCode isEqualToString:MJPropertyTypeLongLong]) {
                int64_t actual = [decoder decodeInt64ForKey:property.name];;
                value = [NSNumber numberWithLongLong:actual];
            } else if ([propertyCode isEqualToString:MJPropertyTypeBOOL1] || [propertyCode isEqualToString:MJPropertyTypeBOOL2]) {
                BOOL actual = [decoder decodeBoolForKey:property.name];;
                value = [NSNumber numberWithBool:actual];
            }
        }
        
        if (value == nil) return;
        [property setValue:value forObject:self];
    }];
}
@end
