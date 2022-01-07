//
//  MJExtensionProtocols.h
//  MJExtension
//
//  Created by Frank on 2021/12/1.
//  Copyright © 2021 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MJProperty;

@protocol MJEValueModifier <NSObject>
@optional

/// Uses to modify old value in JSON to a new one when JSON is converted to an object, which is occurred in property setting procedure. The new value will be set to specific property.
/// @param oldValue old value in JSON(value in dictionary)
/// @param property current property by setting.
/// @discussion By implementing @code mj_modifyOld2NewPropertyNames @endcode method, converting speed would be boosting multiple times. It is highly recommended to implement it.
- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property;
/// Filters for `mj_newValueFromOldValue:property` protocol method usage.
/// @discussion Boosts speed significantly for converting to object if sets.
+ (NSArray *)mj_modifyOldToNewPropertyNames;

/// Called after the object has been converted from JSON.
/// @param keyValues JSON dictionary
- (void)mj_didConvertToObjectWithKeyValues:(NSDictionary *)keyValues;

/// Called after the object has been converted to JSON.
/// @param keyValues JSON dictionary that can be modify.
- (void)mj_objectDidConvertToKeyValues:(NSMutableDictionary *)keyValues;

@end

@protocol MJECoding <NSObject, NSCoding>
@optional
/// Array for those properties that should only be allowed to coding.
+ (NSArray *)mj_allowedCodingPropertyNames;
/// Array for those properties that should be ignored to coding.
+ (NSArray *)mj_ignoredCodingPropertyNames;
@end

@protocol MJEConfiguration <MJEValueModifier, MJECoding>

@optional
/// Array for those properties that should only be allowed.
+ (NSArray *)mj_allowedPropertyNames;

/// Array for those properties that should be ignored.
+ (NSArray *)mj_ignoredPropertyNames;

/// Array for those properties that should only be allowed when converts into json. If not implemented, `mj_allowedPropertyNames` will be used.
+ (NSArray *)mj_allowedPropertyNamesToJSON;

/// Array for those properties that should be ignored when converts into json. If not implemented, `mj_ignoredPropertyNames` will be used.
+ (NSArray *)mj_ignoredPropertyNamesToJSON;

/// Dictionary for each property to correspond with replaced key.
/// @discussion - `key` is property name
///
/// - `value` is the replaced key to be recognized in JSON.
/// @warning This configuration has lower priorty to `mj_replacedKeyFromPropertyName121`. MJExtension would check the modifier `mj_replacedKeyFromPropertyName121` first, then this method.
/// @remark It is highly recommended to use these two methods separately.
+ (NSDictionary *)mj_replacedKeyFromPropertyName;

/// Gives an opportunity to customize modifier, which can be used replace property name to the corresponding key in dictionary.
/// @param propertyName property name
/// @discussion For examples:
/// Use @code propertyName.mj_underlineFromCamel @endcode in this category @link NSString+MJExtension @/link to do some changes.
/// @warning This configuration has higher priorty to `mj_replacedKeyFromPropertyName`. MJExtension would check this modifier first, then `mj_replacedKeyFromPropertyName`.
/// @remark It is highly recommended to use these two methods separately.
+ (id)mj_replacedKeyFromPropertyName121:(NSString *)propertyName;

/// Dictionary for each collection property (Array, Dictionary, Set, etc...) to correspond with object class.
/// @discussion - `key` is collection property name
///
/// - `value` is the class or class string for recongnizing in JSON.
+ (NSDictionary *)mj_classInfoInCollection;
+ (NSDictionary *)mj_objectClassInArray MJE_API_Deprecated("Use +mj_classInfoCollection instead.");

+ (Class)mj_modifiedClassForDictionary:(NSDictionary *)dictionary;

/// Used to coverts a string to a number.
/// @discussion Normally "100,500" = 100. But "100,500" = 100.5 in France.
+ (NSLocale *)mj_numberLocale;

/// Used in date formatter that converts a string to a date.
/// @discussion Following formatters have already been existed by default.
/// @code
/// "yyyy-MM-dd"
/// "yyyy-MM-dd'T'HH:mm:ss"
/// "yyyy-MM-dd'T'HH:mm:ss.SSS"
/// "yyyy-MM-dd'T'HH:mm:ssZ"
/// "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
/// @endcode
+ (NSDateFormatter *)mj_dateFormatter;

/// Inherits configurations from super class or not.
/// @discussion If not implements, default value is YES.
+ (BOOL)mj_shouldAutoInheritConfigurations;

/// Only works in replaced key configuration of JSON to Object. Other configurations are referenced.
/// @discussion Default value is `true`(YES), if not implements it.
+ (BOOL)mj_shouldReferenceKeyReplacementInJSONExport;
@end
