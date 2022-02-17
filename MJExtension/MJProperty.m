//
//  MJProperty.m
//  MJExtensionExample
//
//  Created by MJ Lee on 15/4/17.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "MJProperty.h"
#import "MJExtensionPredefine.h"
#import <objc/message.h>
#include "TargetConditionals.h"
#import "NSString+MJExtension.h"
#import "MJExtension_Private.h"

#define mj_objGet(obj, type) mj_msgSendGet(obj, _getter, type)

@import CoreData;

@interface MJProperty()

@end

@implementation MJProperty

- (instancetype)initWithProperty:(objc_property_t)property inClass:(nonnull Class)cls {
    self = [super init];
    
    _srcClass = cls;
    _name = @(property_getName(property));
    
    unsigned int outCount = 0;
    objc_property_attribute_t *attributes = property_copyAttributeList(property, &outCount);
    for (unsigned int i = 0; i < outCount; i++) {
        switch (attributes[i].name[0]) {
            case 'T': { // Type
                if (attributes[i].value) {
                    _typeEncoding = @(attributes[i].value);
                    _type = MJEGetPropertyType(attributes[i].value);
                    
                    if (_type && _typeEncoding.length) {
                        NSScanner *scanner = [NSScanner scannerWithString:_typeEncoding];
                        if (![scanner scanString:@"@\"" intoString:nil]) continue;
                        
                        NSString *clsName = nil;
                        if ([scanner scanUpToCharactersFromSet: [NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&clsName]) {
                            if (clsName.length) _typeClass = objc_getClass(clsName.UTF8String);
                        }
                    }
                }
            } break;
            case 'V': { // ivar
                if (attributes[i].value) {
                    _ivarName = @(attributes[i].value);
                }
            } break;
            case 'G': { // custom getter
                if (attributes[i].value) {
                    _getter = NSSelectorFromString(@(attributes[i].value));
                }
            } break;
            case 'S': { // custom setter
                if (attributes[i].value) {
                    _setter = NSSelectorFromString(@(attributes[i].value));
                }
            }
            default: break;
        }
    }
    if (attributes) {
        free(attributes);
        attributes = NULL;
    }
    
    if (_type == MJEPropertyTypeObject) {
        _basicObjectType = MJEGetBasicObjectType(_typeClass);
        _isCustomModelType = !_basicObjectType && _typeClass;
    }
    // If getter or setter is nil, sets them with property name
    if (_name.length) {
        if (!_getter) _getter = NSSelectorFromString(_name);
        if (!_setter) _setter = _name.mj_defaultSetter;
    }
    // Check whether instances respond getter / setter except NSManagedObject.
    // NSManagedObject properies have dynamic implementation.
    if (![_srcClass isSubclassOfClass:NSManagedObject.class]) {
        if (![cls instancesRespondToSelector:_getter]) _getter = nil;
        if (![cls instancesRespondToSelector:_setter]) _setter = nil;
    }
    
    // Check KVC compliant and basic type
    if (_getter && _setter) {
        switch (_type) {
            case MJEPropertyTypeBool:
            case MJEPropertyTypeInt8:
            case MJEPropertyTypeUInt8:
            case MJEPropertyTypeInt16:
            case MJEPropertyTypeUInt16:
            case MJEPropertyTypeInt32:
            case MJEPropertyTypeUInt32:
            case MJEPropertyTypeInt64:
            case MJEPropertyTypeUInt64:
            case MJEPropertyTypeFloat:
            case MJEPropertyTypeDouble: {
                _isKVCCompliant = YES;
                _isBasicNumber = YES;
            }
                break;
            // Above values would be wrapped by NSNumber, but long double (AKA Float80 is not, which because NSNumber capacity is 64 bit. Float80 is not supported KVC.
            case MJEPropertyTypeLongDouble: {
                _isKVCCompliant = NO;
                _isBasicNumber = YES;
            }
                break;
            case MJEPropertyTypeObject:
            case MJEPropertyTypeClass:
            case MJEPropertyTypeBlock:
            case MJEPropertyTypeStruct:
            case MJEPropertyTypeUnion: {
                _isKVCCompliant = YES;
                _isBasicNumber = NO;
            }
                break;
            // C pointer(SEL/CoreFoundation object) also does not support KVC
            default: break;
        }
    }
    
    return self;
}

- (BOOL)isNumber {
    return _isBasicNumber
    || _basicObjectType == MJEBasicTypeNumber
    || _basicObjectType == MJEBasicTypeDecimalNumber;
}

/**
 *  获得成员变量的值
 */
- (id)valueForObject:(id)object {
    if (!_isKVCCompliant) return NSNull.null;
    
    id value = [object valueForKey:_name];
    
    // 32位BOOL类型转换json后成Int类型
    /** https://github.com/CoderMJLee/MJExtension/issues/545 */
    // 32 bit device OR 32 bit Simulator
#if defined(__arm__) || (TARGET_OS_SIMULATOR && !__LP64__)
    if (_type == MJEPropertyTypeBool) {
        value = @([value boolValue]);
    }
#endif
    return value;
}

- (NSNumber *)numberForObject:(id)object {
    switch (_type) {
        case MJEPropertyTypeBool: {
            id value = @(mj_objGet(object, BOOL));
            // 32位BOOL类型转换json后成Int类型
            /** https://github.com/CoderMJLee/MJExtension/issues/545 */
            // 32 bit device OR 32 bit Simulator
#if defined(__arm__) || (TARGET_OS_SIMULATOR && !__LP64__)
            value = @([value boolValue]);
#endif
            return value;
        }
        case MJEPropertyTypeInt64: return @(mj_objGet(object, int64_t));
        case MJEPropertyTypeUInt64: return @(mj_objGet(object, uint64_t));
        case MJEPropertyTypeFloat:
        case MJEPropertyTypeDouble: {
            double num = (double)mj_objGet(object, double);
            if (isinf(num)) num = 0;
            if (isnan(num)) return nil;
            return @(num);
        }
        case MJEPropertyTypeLongDouble: {
            double num = (double)mj_objGet(object, long double);
            if (isinf(num)) num = 0;
            if (isnan(num)) return nil;
            return @(num);
        }
        default: return @(mj_objGet(object, int64_t));
    }
}

- (id)valueInDictionary:(NSDictionary *)dictionary {
    id value;
    for (NSArray *propertyKeys in _mappedMultiKeys) {
        value = dictionary;
        for (MJPropertyKey *key in propertyKeys) {
            value = [key valueInObject:value];
            if (!value) break;
        }
        if (value) return value;
    }
    return nil;
}

/**
 *  设置成员变量的值
 */
- (void)setValue:(id)value forObject:(id)object {
    if (!_isKVCCompliant || value == nil) return;
    [object setValue:value forKey:self.name];
}

/** 对应着字典中的key */
- (void)handleOriginKey:(id)originKey {
    if ([originKey isKindOfClass:NSString.class]) { // 字符串类型的key
        NSString *stringKey = originKey;
        NSArray<MJPropertyKey *> *multiKeys = stringKey.mj_multiKeys;
        NSUInteger keysCount = multiKeys.count;
        if (keysCount > 1) {
            _isMultiMapping = YES;
            // If JSON key is "xxx.xxx", so add one more key for it.
            _mappedMultiKeys = @[multiKeys, @[stringKey.propertyKey]];
        } else if (keysCount == 1) {
            _mappedKey = originKey;
        }
    } else if ([originKey isKindOfClass:NSArray.class]) {
        _isMultiMapping = YES;
        NSMutableArray *keyses = NSMutableArray.array;
        for (NSString *stringKey in originKey) {
            NSArray *multiKeys = stringKey.mj_multiKeys;
            if (!multiKeys.count) continue;
            if (multiKeys.count > 1) {
                // If JSON key is "xxx.xxx", so add one more key for it.
                [keyses addObject:@[stringKey.propertyKey]];
            }
            [keyses addObject:multiKeys];
        }
        if (keyses.count) {
            _mappedMultiKeys = keyses;
        }
    }
}

MJEPropertyType MJEGetPropertyType(const char *typeEncoding) {
    if (!typeEncoding) return MJEPropertyTypeUndefined;
    size_t length = strlen(typeEncoding);
    if (length == 0) return MJEPropertyTypeUndefined;
    
    switch (*typeEncoding) {
        case 'B': return MJEPropertyTypeBool;
        case 'c': return MJEPropertyTypeInt8;
        case 'C': return MJEPropertyTypeUInt8;
        case 's': return MJEPropertyTypeInt16;
        case 'S': return MJEPropertyTypeUInt16;
        case 'i': return MJEPropertyTypeInt32;
        case 'I': return MJEPropertyTypeUInt32;
        case 'l': return MJEPropertyTypeInt32;
        case 'L': return MJEPropertyTypeUInt32;
        case 'q': return MJEPropertyTypeInt64;
        case 'Q': return MJEPropertyTypeUInt64;
        case 'f': return MJEPropertyTypeFloat;
        case 'd': return MJEPropertyTypeDouble;
        case 'D': return MJEPropertyTypeLongDouble;
        case '@':
            // check "@?"
            if (length == 2 && *(typeEncoding + 1) == '?') {
                return MJEPropertyTypeBlock;
            } else {
                return MJEPropertyTypeObject;
            }
        case '#': return MJEPropertyTypeClass;
        case ':': return MJEPropertyTypeSEL;
        case '^': return MJEPropertyTypePointer;
        case '*': return MJEPropertyTypeCString;
        case '(': return MJEPropertyTypeUnion;
        case '{': return MJEPropertyTypeStruct;
        case '[': return MJEPropertyTypeCArray;
        case 'v': return MJEPropertyTypeVoid;
        default: return MJEPropertyTypeUndefined;
    }
}

MJEBasicType MJEGetBasicObjectType(Class cls) {
    if (!cls) return MJEBasicTypeUndefined;
    if ([cls isSubclassOfClass:NSMutableString.class]) return MJEBasicTypeMutableString;
    if ([cls isSubclassOfClass:NSMutableSet.class]) return MJEBasicTypeMutableSet;
    if ([cls isSubclassOfClass:NSMutableArray.class]) return MJEBasicTypeMutableArray;
    if ([cls isSubclassOfClass:NSMutableDictionary.class]) return MJEBasicTypeMutableDictionary;
    if ([cls isSubclassOfClass:NSMutableData.class]) return MJEBasicTypeMutableData;
    if ([cls isSubclassOfClass:NSDecimalNumber.class]) return MJEBasicTypeDecimalNumber;
    if ([cls isSubclassOfClass:NSMutableAttributedString.class]) return MJEBasicTypeMutableAttributedString;
    if ([cls isSubclassOfClass:NSMutableOrderedSet.class]) return MJEBasicTypeMutableOrderedSet;
    
    if ([cls isSubclassOfClass:NSString.class]) return MJEBasicTypeString;
    if ([cls isSubclassOfClass:NSSet.class]) return MJEBasicTypeSet;
    if ([cls isSubclassOfClass:NSArray.class]) return MJEBasicTypeArray;
    if ([cls isSubclassOfClass:NSDictionary.class]) return MJEBasicTypeDictionary;
    if ([cls isSubclassOfClass:NSData.class]) return MJEBasicTypeData;
    if ([cls isSubclassOfClass:NSNumber.class]) return MJEBasicTypeNumber;
    if ([cls isSubclassOfClass:NSAttributedString.class]) return MJEBasicTypeAttributedString;
    if ([cls isSubclassOfClass:NSOrderedSet.class]) return MJEBasicTypeOrderedSet;
    
    if ([cls isSubclassOfClass:NSValue.class]) return MJEBasicTypeValue;
    if ([cls isSubclassOfClass:NSDate.class]) return MJEBasicTypeDate;
    if ([cls isSubclassOfClass:NSURL.class]) return MJEBasicTypeURL;
    return MJEBasicTypeUndefined;
}

@end
