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
#import "NSString+MJExtension_Private.h"

@interface NSString (MJPropertyKey)

///  If JSON key is "xxx.xxx", so add one more key for it.
- (MJPropertyKey *)propertyKey;

/// Create keys with dot form, which is splitted by dot.
- (NSArray<MJPropertyKey *> *)mj_multiKeys;

@end

@implementation NSString (MJPropertyKey)

- (MJPropertyKey *)propertyKey {
    MJPropertyKey *specialKey = [[MJPropertyKey alloc] init];
    specialKey.name = self;
    return specialKey;
}

- (NSArray<MJPropertyKey *> *)mj_multiKeys {
    if (self.length == 0) return nil;
    
    NSMutableArray *multiKeys = [NSMutableArray array];
    // 如果有多级映射
    NSArray *oldKeys = [self componentsSeparatedByString:@"."];
    
    for (NSString *oldKey in oldKeys) {
        NSUInteger start = [oldKey rangeOfString:@"["].location;
        if (start != NSNotFound) { // 有索引的key
            NSString *prefixKey = [oldKey substringToIndex:start];
            NSString *indexKey = prefixKey;
            if (prefixKey.length) {
                MJPropertyKey *propertyKey = [[MJPropertyKey alloc] init];
                propertyKey.name = prefixKey;
                [multiKeys addObject:propertyKey];
                
                indexKey = [oldKey stringByReplacingOccurrencesOfString:prefixKey withString:@""];
            }
            
            /** 解析索引 **/
            // 元素
            NSArray *cmps = [[indexKey stringByReplacingOccurrencesOfString:@"[" withString:@""] componentsSeparatedByString:@"]"];
            for (NSInteger i = 0; i<cmps.count - 1; i++) {
                MJPropertyKey *subPropertyKey = [[MJPropertyKey alloc] init];
                subPropertyKey.type = MJPropertyKeyTypeArray;
                subPropertyKey.name = cmps[i];
                [multiKeys addObject:subPropertyKey];
            }
        } else { // 没有索引的key
            MJPropertyKey *propertyKey = [[MJPropertyKey alloc] init];
            propertyKey.name = oldKey;
            [multiKeys addObject:propertyKey];
        }
    }
    
    return multiKeys;
}

@end

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
                    _typeEncoding = [NSString stringWithUTF8String:attributes[i].value];
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
                    _ivarName = [NSString stringWithUTF8String:attributes[i].value];
                }
            } break;
            case 'G': { // custom getter
                if (attributes[i].value) {
                    _getter = NSSelectorFromString([NSString stringWithUTF8String:attributes[i].value]);
                }
            } break;
            case 'S': { // custom setter
                if (attributes[i].value) {
                    _setter = NSSelectorFromString([NSString stringWithUTF8String:attributes[i].value]);
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
- (id)valueForObject:(id)object
{
    if (!_isKVCCompliant) return NSNull.null;
    
    id value = [object valueForKey:self.name];
    
    // 32位BOOL类型转换json后成Int类型
    /** https://github.com/CoderMJLee/MJExtension/issues/545 */
    // 32 bit device OR 32 bit Simulator
#if defined(__arm__) || (TARGET_OS_SIMULATOR && !__LP64__)
    if (_type1 == MJEPropertyTypeBool) {
        value = @([(NSNumber *)value boolValue]);
    }
#endif
    
    return value;
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
    //FIXME: Bottleneck #4: Enhanced
    [object setValue:value forKey:self.name];
//    mj_msgSendOne(object, _setter, id, value);
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
        NSMutableArray *keyses = [NSMutableArray array];
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
