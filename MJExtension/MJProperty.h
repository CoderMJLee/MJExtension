//
//  MJProperty.h
//  MJExtensionExample
//
//  Created by MJ Lee on 15/4/17.
//  Copyright (c) 2015年 小码哥. All rights reserved.

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "MJPropertyKey.h"

/// Property type defination
///
/// @discussion  According to [Apple Documents](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101)
typedef NS_ENUM(NSUInteger, MJEPropertyType) {
    MJEPropertyTypeUndefined    = 0, ///< undefined
    MJEPropertyTypeBool       = 1, ///< 'B': A C++ bool or a C99 _Bool
    MJEPropertyTypeInt8       = 2, ///< 'c': char or BOOL
    MJEPropertyTypeUInt8      = 3, ///< 'C': unsigned char
    MJEPropertyTypeInt16      = 4, ///< 's'
    MJEPropertyTypeUInt16     = 5, ///< 'S'
    MJEPropertyTypeInt32      = 6, ///< 'i' or 'l'
    MJEPropertyTypeUInt32     = 7, ///< 'I' or 'L'
    MJEPropertyTypeInt64      = 8, ///< 'q'
    MJEPropertyTypeUInt64     = 9, ///< 'Q'
    MJEPropertyTypeFloat      = 10, ///< 'f'
    MJEPropertyTypeDouble     = 11, ///< 'd'
    MJEPropertyTypeLongDouble = 12, ///< 'D'
    
    MJEPropertyTypeObject     = 1 << 4, ///< '@'
    MJEPropertyTypeClass      = 2 << 4, ///< '#'
    MJEPropertyTypeBlock      = 3 << 4, ///< '@?'
    
    MJEPropertyTypeSEL        = 4 << 4, ///< ':'
    MJEPropertyTypePointer    = 5 << 4, ///< '^'
    MJEPropertyTypeCString    = 6 << 4, ///< '*'
    
    MJEPropertyTypeStruct     = 7 << 4, ///< '{'
    MJEPropertyTypeUnion      = 8 << 4, ///< '('
    
    MJEPropertyTypeCArray     = 9 << 4, ///< '['
//    MJEPropertyTypeBitField ///< 'bnum': A bit field of num bits **Property name cannot be a bit-field**
    MJEPropertyTypeVoid       = 10 << 4, ///< 'v'
};

/// Property Basic Object Type
///
/// @discussion e.g.: `NSString`, `NSSet`, `NSArray`, `NSDictionary`, etc.
typedef NS_ENUM(NSUInteger, MJEBasicType) {
    MJEBasicTypeUndefined = 0,
    
    MJEBasicTypeMutableString,
    MJEBasicTypeMutableSet,
    MJEBasicTypeMutableArray,
    MJEBasicTypeMutableDictionary,
    MJEBasicTypeMutableData,
    MJEBasicTypeDecimalNumber,
    MJEBasicTypeMutableAttributedString,
    MJEBasicTypeMutableOrderedSet,
    
    MJEBasicTypeString,
    MJEBasicTypeSet,
    MJEBasicTypeArray,
    MJEBasicTypeDictionary,
    MJEBasicTypeData,
    MJEBasicTypeNumber,
    MJEBasicTypeAttributedString,
    MJEBasicTypeOrderedSet,
    
    MJEBasicTypeValue,
    MJEBasicTypeDate,
    MJEBasicTypeURL,
};

NS_ASSUME_NONNULL_BEGIN

/// Objc property wrapper
@interface MJProperty : NSObject {
    @package
    /// has old to new value modifying method in Class containing.
    BOOL _hasValueModifier;
    /// has the ability to change generic class or common class(base class) based on value type.
    BOOL _hasClassModifier;
    /// If mappedMultiKeys exist, this value would be true
    BOOL _isMultiMapping;
    /// For multiple keys,  keypath, subkeys mapping.
    NSArray<NSArray <MJPropertyKey *> *> * _Nullable _mappedMultiKeys;
    /// For single key mapping.
    NSString * _Nullable _mappedKey;
    /// Type encoding string.
    NSString *_typeEncoding;
    /// True if property class is key value coding-compliant for the key dynamic.
    BOOL _isKVCCompliant;
    /// Foundation basic class and value container types(e.g: NSString, NSArray, NSDictionary, etc.)
    MJEBasicType _basicObjectType;
    /// True if property is a number (e.g: bool, double, int, etc.).
    BOOL _isBasicNumber;
}

/// `Property` name that defined by class.
@property (nonatomic, readonly) NSString *name;
/// `Property` ivar name synthesized
@property (nonatomic, readonly) NSString *ivarName;
/// `Property` value type that defined by belonged class.
@property (nonatomic, readonly) MJEPropertyType type;
/// True if _isBasicNumber or number object(NSNumber, NSDecimalNumber)
@property (nonatomic, readonly) BOOL isNumber;
/// `Property` belonged by what class. It may be from super class.
@property (nonatomic, readonly) Class srcClass;
/// The `Property` type class could be nil if `Property` is a standard value(int / double, Class ...)
@property (nullable, nonatomic, readonly) Class typeClass;
/// If the `Property` type is a not standard value(typeClass == nil) nor a basic object type(_basicObjectType == .undefined), this value will be true(YES).
@property (nonatomic, readonly) BOOL isCustomModelType;
/// If class type is a collection,  this value is the type of those element in it.
@property (nonatomic) Class classInCollection;
/// Could be nil if getter is not reponded in srcClass instances.
@property (nullable, nonatomic) SEL getter;
/// Could be nil if setter is not reponded in srcClass instances.
@property (nullable, nonatomic) SEL setter;

/// Handle the original key for this property to produce mapped keys.
- (void)handleOriginKey:(id)originKey;

- (void)setValue:(id)value forObject:(id)object;
- (id)valueForObject:(id)object;
- (NSNumber *)numberForObject:(id)object;

- (id)valueInDictionary:(NSDictionary *)dictionary;

/// Initializer by a objc_property_t struct
- (instancetype)initWithProperty:(objc_property_t)property inClass:(Class)cls;

@end

NS_ASSUME_NONNULL_END
