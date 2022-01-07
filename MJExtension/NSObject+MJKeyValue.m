//
//  NSObject+MJKeyValue.m
//  MJExtension
//
//  Created by mj on 13-8-24.
//  Copyright (c) 2013年 小码哥. All rights reserved.
//

#import "NSObject+MJKeyValue.h"
#import "NSString+MJExtension.h"
#import "MJProperty.h"
#import "MJExtensionPredefine.h"
#import "MJEClass.h"
#import "MJExtensionProtocols.h"
#import "NSDate+MJExtension.h"

#define mj_selfSend(sel, type, value) mj_msgSendOne(self, sel, type, value)
#define mj_selfSet(property, type, value) mj_selfSend(property.setter, type, value)
#define mj_selfGet(property, type) mj_msgSendGet(self, property.getter, type)

@interface NSObject () <MJEConfiguration>

@end
@implementation NSObject (MJKeyValue)

#pragma mark - 错误
static const char MJErrorKey = '\0';
+ (NSError *)mj_error
{
    return objc_getAssociatedObject(self, &MJErrorKey);
}

+ (void)setMj_error:(NSError *)error
{
    objc_setAssociatedObject(self, &MJErrorKey, error, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - --公共方法--
#pragma mark - JSON to Object
- (instancetype)mj_setKeyValues:(id)keyValues {
    return [self mj_setKeyValues:keyValues context:nil];
}

- (instancetype)mj_setKeyValues:(id)keyValues
                        context:(NSManagedObjectContext *)context {
    id object = keyValues;
    if (![object isKindOfClass:NSDictionary.class]) object = [object mj_shallowJSONObject];
    
    MJExtensionAssertError([object isKindOfClass:NSDictionary.class], self, self.class, @"keyValues参数不是一个字典");
    
    MJEClass *classCache = [MJEClass cachedClass:self.class];
    NSDictionary *dict = object;

    [self mj_enumerateProperties:classCache->_allProperties
                  withDictionary:dict classCache:classCache context:context];
//    [self mj_slowEnumerateProperties:classCache->_allProperties
//                  withDictionary:dict classCache:classCache context:context];

    // 转换完毕
    if (classCache->_hasDictionary2ObjectModifier) {
        [self mj_didConvertToObjectWithKeyValues:keyValues];
    }
    return self;
}

+ (instancetype)mj_objectWithKeyValues:(id)keyValues
{
    return [self mj_objectWithKeyValues:keyValues context:nil];
}

+ (instancetype)mj_objectWithKeyValues:(id)keyValues context:(NSManagedObjectContext *)context {
    id obj;
    if ([self isSubclassOfClass:NSManagedObject.class] && context) {
        NSString *entityName = [(NSManagedObject *)self entity].name;
        obj = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
    } else {
        obj = [self new];
    }
    return [obj mj_setKeyValues:keyValues context:context];
}

+ (instancetype)mj_objectWithFilename:(NSString *)filename
{
    MJExtensionAssertError(filename != nil, nil, [self class], @"filename参数为nil");
    
    return [self mj_objectWithFile:[[NSBundle mainBundle] pathForResource:filename ofType:nil]];
}

+ (instancetype)mj_objectWithFile:(NSString *)file
{
    MJExtensionAssertError(file != nil, nil, [self class], @"file参数为nil");
    
    return [self mj_objectWithKeyValues:[NSDictionary dictionaryWithContentsOfFile:file]];
}

#pragma mark - JSON -> Model Array
+ (NSMutableArray *)mj_objectArrayWithKeyValuesArray:(NSArray *)keyValuesArray
{
    return [self mj_objectArrayWithKeyValuesArray:keyValuesArray context:nil];
}

+ (NSMutableArray *)mj_objectArrayWithKeyValuesArray:(id)keyValuesArray context:(NSManagedObjectContext *)context {
    // 如果是JSON字符串
    if (![keyValuesArray isKindOfClass:NSArray.class]) {
        keyValuesArray = [keyValuesArray mj_shallowJSONObject];
    }
    // 1.判断真实性
    MJExtensionAssertError([keyValuesArray isKindOfClass:NSArray.class], nil, [self class], @"keyValuesArray参数不是一个数组");
    
    // 如果数组里面放的是NSString、NSNumber等数据
    if (MJE_isFromFoundation(self)) return [NSMutableArray arrayWithArray:keyValuesArray];
    
    // 2.创建数组
    NSMutableArray *modelArray = [NSMutableArray array];
    
    // 3.遍历
    for (NSDictionary *keyValues in keyValuesArray) {
        if ([keyValues isKindOfClass:NSArray.class]){
            [modelArray addObject:[self mj_objectArrayWithKeyValuesArray:keyValues context:context]];
        } else if ([keyValues isKindOfClass:NSDictionary.class]) {
            id model = [self mj_objectWithKeyValues:keyValues context:context];
            if (model) [modelArray addObject:model];
        }
    }
    
    return modelArray;
}

+ (NSMutableArray *)mj_objectArrayWithFilename:(NSString *)filename
{
    MJExtensionAssertError(filename != nil, nil, [self class], @"filename参数为nil");
    
    return [self mj_objectArrayWithFile:[[NSBundle mainBundle] pathForResource:filename ofType:nil]];
}

+ (NSMutableArray *)mj_objectArrayWithFile:(NSString *)file
{
    MJExtensionAssertError(file != nil, nil, [self class], @"file参数为nil");
    
    return [self mj_objectArrayWithKeyValuesArray:[NSArray arrayWithContentsOfFile:file]];
}

#pragma mark - Any to JSON
- (NSData *)mj_JSONData {
    id object = self.mj_JSONObject;
    if (!object || object == NSNull.null) return nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:kNilOptions error:nil];
    return data;
}

- (NSString *)mj_JSONString {
    NSData *data = self.mj_JSONData;
    if (!data.length) return nil;
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return string;
}

- (id)mj_JSONObject {
    return [self mj_JSONObjectWithKeys:nil ignoredKeys:nil];
}
- (id)mj_JSONObjectWithKeys:(NSArray *)keys {
    return [self mj_JSONObjectWithKeys:keys ignoredKeys:nil];
}
- (id)mj_JSONObjectWithIgnoredKeys:(NSArray *)ignoredKeys {
    return [self mj_JSONObjectWithKeys:nil ignoredKeys:ignoredKeys];
}

- (id)mj_JSONObjectWithKeys:(NSArray *)keys ignoredKeys:(NSArray *)ignoredKeys {
    return [self mj_JSONObjectWithKeys:keys ignoredKeys:ignoredKeys isRecursiveMode:YES];
}

#pragma mark - Private

- (id)mj_shallowJSONObject {
    return [self mj_JSONObjectWithKeys:nil
                           ignoredKeys:nil isRecursiveMode:NO];
}

- (id)mj_JSONObjectWithKeys:(NSArray *)keys ignoredKeys:(NSArray *)ignoredKeys isRecursiveMode:(BOOL)isRecusiveMode {
    if ([self isKindOfClass:NSString.class]) {
        return [NSJSONSerialization JSONObjectWithData:[(NSString *)self dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    } else if ([self isKindOfClass:NSData.class]) {
        return [NSJSONSerialization JSONObjectWithData:(NSData *)self options:kNilOptions error:nil];
    }
    
    id object = [self mj_unsafe_JSONObjectWithRecursiveMode:isRecusiveMode keys:keys ignoredKeys:ignoredKeys];
    if ([object isKindOfClass:NSArray.class]) return object;
    if ([object isKindOfClass:NSDictionary.class]) return object;
    return nil;
}

- (id)mj_unsafe_JSONObjectWithRecursiveMode:(BOOL)isRecursive keys:(NSArray *)keys ignoredKeys:(NSArray *)ignoredKeys {
    if (self == NSNull.null) return NSNull.null;
    if ([self isKindOfClass:NSString.class]) return self;
    if ([self isKindOfClass:NSNumber.class]) {
        NSNumber *number = (NSNumber *)self;
        // Inf and NaN should not be in JSON object.
        if (isinf(number.doubleValue)) return @(0);
        if ([number isEqualToNumber:NSDecimalNumber.notANumber]) return nil;
        return self;
    }
    if ([self isKindOfClass:NSDictionary.class]) {
        if (!isRecursive) return self;
        if ([NSJSONSerialization isValidJSONObject:self]) return self;
        NSDictionary *dictonary = (NSDictionary *)self;
        NSMutableDictionary *result = [NSMutableDictionary new];
        for (id anyKey in dictonary.allKeys) {
            id obj = dictonary[anyKey];
            NSString *key = [anyKey isKindOfClass:NSString.class] ? anyKey : [anyKey description];
            if (!key) continue;
            id objJSON = [obj mj_unsafe_JSONObjectWithRecursiveMode:YES
                                                               keys:nil ignoredKeys:nil];
            if (!objJSON) continue;
            result[key] = objJSON;
        }
        return result;
    }
    id array = self;
    if ([self isKindOfClass:NSSet.class]) {
        array = [(NSSet *)self allObjects];
    } else if ([self isKindOfClass:NSOrderedSet.class]) {
        array = [(NSOrderedSet *)self array];
    }
    if ([array isKindOfClass:NSArray.class]) {
        if (!isRecursive) return self;
        if ([NSJSONSerialization isValidJSONObject:array]) return array;
        NSMutableArray *result = [NSMutableArray new];
        for (id obj in array) {
            id objJSON = [obj mj_unsafe_JSONObjectWithRecursiveMode:YES
                                                                 keys:nil ignoredKeys:nil];
            if (objJSON) [result addObject:objJSON];
        }
        return result;
    }
    if ([self isKindOfClass:NSURL.class]) return [(NSURL *)self absoluteString];
    if ([self isKindOfClass:NSAttributedString.class]) return [(NSAttributedString *)self string];
    if ([self isKindOfClass:NSDate.class]) return [(NSDate *)self mj_defaultDateString];
    if ([self isKindOfClass:NSData.class]) return nil;
    
    // Check if the object is a "Model Object"(we defined) after basic type conversion finished
    if (MJE_isFromFoundation(self.class)) return nil;
    
    MJEClass *classCache = [MJEClass cachedClass:self.class];
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSArray<MJProperty *> *allProperties = classCache->_allProperties;
    
    for (MJProperty *property in allProperties) {
        // 0.检测是否被忽略
        if (keys.count && ![keys containsObject:property.name]) continue;
        if ([ignoredKeys containsObject:property.name]) continue;
        
        // 1.取出属性值
        id value;
        if (!property->_isKVCCompliant) value = NSNull.null;
        if (!property->_isBasicNumber) {
            value = mj_selfGet(property, id);
        } else {
            value = [property numberForObject:self];
        }
        
        if (!value) continue;
        
        if (property.typeClass) {
            value = [value mj_unsafe_JSONObjectWithRecursiveMode:YES
                                                            keys:nil ignoredKeys:nil];
        } else {
            switch (property.type) {
                case MJEPropertyTypeClass: {
                    Class cls = mj_selfGet(property, Class);
                    value = cls ? NSStringFromClass(cls) : nil;
                } break;
                case MJEPropertyTypeSEL: {
                    SEL selector = mj_selfGet(property, SEL);
                    value = selector ? NSStringFromSelector(selector) : nil;
                } break;
                default: break;
            }
        }
        
        // 4.赋值
        if (classCache->_shouldReferenceKeyReplacementInJSONExport) {
            if (property->_isMultiMapping) {
                NSArray *propertyKeys = [property->_mappedMultiKeys firstObject];
                NSUInteger keyCount = propertyKeys.count;
                // 创建字典
                __block id innerContainer = result;
                [propertyKeys enumerateObjectsUsingBlock:^(MJPropertyKey *propertyKey, NSUInteger idx, BOOL *stop) {
                    // 下一个属性
                    MJPropertyKey *nextPropertyKey = nil;
                    if (idx != keyCount - 1) {
                        nextPropertyKey = propertyKeys[idx + 1];
                    }
                    
                    if (nextPropertyKey) { // 不是最后一个key
                        // 当前propertyKey对应的字典或者数组
                        id tempInnerContainer = [propertyKey valueInObject:innerContainer];
                        if (tempInnerContainer == nil || tempInnerContainer == NSNull.null) {
                            if (nextPropertyKey.type == MJPropertyKeyTypeDictionary) {
                                tempInnerContainer = [NSMutableDictionary dictionary];
                            } else {
                                tempInnerContainer = [NSMutableArray array];
                            }
                            if (propertyKey.type == MJPropertyKeyTypeDictionary) {
                                innerContainer[propertyKey.name] = tempInnerContainer;
                            } else {
                                innerContainer[propertyKey.name.intValue] = tempInnerContainer;
                            }
                        }
                        
                        if ([tempInnerContainer isKindOfClass:[NSMutableArray class]]) {
                            NSMutableArray *tempInnerContainerArray = tempInnerContainer;
                            int index = nextPropertyKey.name.intValue;
                            while (tempInnerContainerArray.count < index + 1) {
                                [tempInnerContainerArray addObject:NSNull.null];
                            }
                        }
                        
                        innerContainer = tempInnerContainer;
                    } else { // 最后一个key
                        if (propertyKey.type == MJPropertyKeyTypeDictionary) {
                            innerContainer[propertyKey.name] = value;
                        } else {
                            innerContainer[propertyKey.name.intValue] = value;
                        }
                    }
                }];
            } else {
                result[property->_mappedKey] = value;
            }
        } else {
            result[property.name] = value;
        }
    }
    
    if (classCache->_hasObject2DictionaryModifier) {
        [self mj_objectDidConvertToKeyValues:result];
    }
    return result;
}

- (void)mj_enumerateProperties:(NSArray<MJProperty *> *)properties
                    withDictionary:(NSDictionary *)dictionary
                        classCache:(MJEClass *)classCache
                           context:(NSManagedObjectContext *)context {
    NSLocale *locale = classCache->_numberLocale;
    for (MJProperty *property in properties) {
        // get value from dictionary
        id value = nil;
        if (!property->_isMultiMapping) {
            value = dictionary[property->_mappedKey];
        } else {
            value = [property valueInDictionary:dictionary];
        }
        
        // Get value through the modifier
        if (classCache->_hasOld2NewModifier
            && property->_hasValueModifier) {
            id newValue = [self mj_newValueFromOldValue:value property:property];
            if (newValue != value) { // 有过滤后的新值
                [property setValue:newValue forObject:self];
                continue;
            }
        }
        
        if (!value) continue;
        if (value == NSNull.null) {
            mj_selfSet(property, id, nil);
            continue;
        }
        // convert as different cases
        MJEPropertyType type = property.type;
        Class typeClass = property.typeClass;
        Class classInCollecion = property.classInCollection;
        MJEBasicType basicObjectType = property->_basicObjectType;
        
        if (property->_isBasicNumber) {
            NSNumber *number = [self mj_numberWithValue:value
                                                   type:type
                                                 locale:locale];
            switch (type) {
                case MJEPropertyTypeBool: {
                    mj_selfSet(property, BOOL, number.boolValue);
                } break;
                case MJEPropertyTypeInt8: {
                    mj_selfSet(property, int8_t, number.charValue);
                } break;
                case MJEPropertyTypeUInt8: {
                    mj_selfSet(property, uint8_t, number.unsignedCharValue);
                } break;
                case MJEPropertyTypeInt16: {
                    mj_selfSet(property, int16_t, number.shortValue);
                } break;
                case MJEPropertyTypeUInt16: {
                    mj_selfSet(property, uint16_t, number.unsignedShortValue);
                } break;
                case MJEPropertyTypeInt32: {
                    mj_selfSet(property, int32_t, number.intValue);
                } break;
                case MJEPropertyTypeUInt32: {
                    mj_selfSet(property, uint32_t, number.unsignedIntValue);
                } break;
                case MJEPropertyTypeInt64: {
                    mj_selfSet(property, int64_t, number.longLongValue);
                } break;
                case MJEPropertyTypeUInt64: {
                    mj_selfSet(property, uint64_t, number.unsignedLongLongValue);
                } break;
                case MJEPropertyTypeFloat: {
                    mj_selfSet(property, float, number.floatValue);
                } break;
                case MJEPropertyTypeDouble: {
                    mj_selfSet(property, double, number.doubleValue);
                } break;
                case MJEPropertyTypeLongDouble: {
                    if ([value isKindOfClass:NSString.class]) {
                        long double num = [value mj_longDoubleValueWithLocale:locale];
                        mj_selfSet(property, long double, num);
                    } else {
                        mj_selfSet(property, long double, (long double)number.doubleValue);
                    }
                } break;
                default: break;
            }
        } else if (basicObjectType) {
            switch (basicObjectType) {
                case MJEBasicTypeString:
                case MJEBasicTypeMutableString:{
                    NSString *result;
                    if ([value isKindOfClass:NSString.class]) {
                        result = value;
                    } else if ([value isKindOfClass:NSNumber.class]) {
                        result = [value stringValue];
                    } else if ([value isKindOfClass:NSData.class]) {
                        result = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
                    } else if ([value isKindOfClass:NSURL.class]) {
                        result = [value absoluteString];
                    } else if ([value isKindOfClass:NSAttributedString.class]) {
                        result = [value string];
                    }
                    if (basicObjectType == MJEBasicTypeMutableString) {
                        result = result.mutableCopy;
                    }
                    mj_selfSet(property, id, result);
                } break;
                    
                case MJEBasicTypeDate:{
                    if ([value isKindOfClass:NSDate.class]) {
                        mj_selfSet(property, id, value);
                    } else if ([value isKindOfClass:NSString.class]) {
                        NSDateFormatter *formatter = classCache->_dateFormatter;
                        NSDate *date = formatter ? [formatter dateFromString:value] : [value mj_date];
                        mj_selfSet(property, id, date);
                    }
                } break;
                    
                case MJEBasicTypeURL:{
                    if ([value isKindOfClass:NSURL.class]) {
                        mj_selfSet(property, id, value);
                    } else if ([value isKindOfClass:NSString.class]) {
                        mj_selfSet(property, id, [value mj_url]);
                    }
                } break;
                case MJEBasicTypeValue: {
                    if ([value isKindOfClass:NSValue.class]) {
                        mj_selfSet(property, id, value);
                    }
                } break;
                case MJEBasicTypeNumber: {
                    NSNumber *num = [self mj_numberWithValue:value
                                                        type:type
                                                      locale:locale];
                    mj_selfSet(property, id, num);
                } break;
                case MJEBasicTypeDecimalNumber: {
                    if ([value isKindOfClass:NSDecimalNumber.class]) {
                        mj_selfSet(property, id, value);
                    } else if ([value isKindOfClass:NSNumber.class]) {
                        NSDecimalNumber *decimalNum = [NSDecimalNumber decimalNumberWithDecimal:[value decimalValue]];
                        mj_selfSet(property, id, decimalNum);
                    } else if ([value isKindOfClass:NSString.class]) {
                        NSDecimalNumber *decimalNum = [NSDecimalNumber decimalNumberWithString:value locale:locale];
                        if (decimalNum == NSDecimalNumber.notANumber) {
                            decimalNum = nil;
                        }
                        mj_selfSet(property, id, decimalNum);
                    }
                } break;
                
                case MJEBasicTypeData:
                case MJEBasicTypeMutableData:{
                    NSData *result;
                    if ([value isKindOfClass:NSData.class]) {
                        result = value;
                    } else if ([value isKindOfClass:NSString.class]) {
                        result = [value dataUsingEncoding:NSUTF8StringEncoding];
                    }
                    if (basicObjectType == MJEBasicTypeMutableData) {
                        result = result.mutableCopy;
                    }
                    mj_selfSet(property, id, result);
                } break;
                    
                case MJEBasicTypeArray:
                case MJEBasicTypeMutableArray:{
                    NSArray *result;
                    if ([value isKindOfClass:NSArray.class]) result = value;
                    else if ([value isKindOfClass:NSSet.class]) result = [value allObjects];
                    // generic
                    if (classInCollecion) {
                        NSMutableArray *objects = [NSMutableArray new];
                        // handle URL array
                        if (classInCollecion == NSURL.class) {
                            for (id element in result) {
                                if ([element isKindOfClass:NSString.class]) {
                                    id object = [element mj_url];
                                    if (object) [objects addObject:object];
                                } else if ([element isKindOfClass:NSArray.class]) {
                                    id object = [NSURL mj_objectArrayWithKeyValuesArray:element context:context];
                                    if (object) [objects addObject:object];
                                }
                            }
                        } else {
                            for (id element in result) {
                                if ([element isKindOfClass:NSDictionary.class]) {
                                    Class cls = classInCollecion;
                                    if (property->_hasClassModifier) {
                                        cls = [cls mj_modifiedClassForDictionary:element];
                                        if (!cls) cls = classInCollecion;
                                    }
                                    id object = [cls mj_objectWithKeyValues:element context:context];
                                    if (object) [objects addObject:object];
                                } else if ([element isKindOfClass:classInCollecion]) {
                                    [objects addObject:element];
                                } else if ([element isKindOfClass:NSArray.class]) {
                                    id object = [classInCollecion mj_objectArrayWithKeyValuesArray:element context:context];
                                    if (object) [objects addObject:object];
                                }
                            }
                        }
                        mj_selfSet(property, id, objects);
                        continue;
                    }
                    if (basicObjectType == MJEBasicTypeMutableArray) {
                        result = result.mutableCopy;
                    }
                    mj_selfSet(property, id, result);
                } break;
                
                case MJEBasicTypeDictionary:
                case MJEBasicTypeMutableDictionary:{
                    if (![value isKindOfClass:NSDictionary.class]) continue;
                    NSDictionary *result = value;
                    // generic
                    if (classInCollecion) {
                        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:result.count];
                        for (NSString *key in result.allKeys) {
                            id obj = result[key];
                            if ([obj isKindOfClass:NSDictionary.class]) {
                                Class cls = classInCollecion;
                                if (property->_hasClassModifier) {
                                    cls = [cls mj_modifiedClassForDictionary:obj];
                                    if (!cls) cls = classInCollecion;
                                }
                                id object = [cls mj_objectWithKeyValues:obj context:context];
                                if (object) dict[key] = object;
                            } else if ([obj isKindOfClass:NSArray.class]) {
                                id object = [classInCollecion mj_objectArrayWithKeyValuesArray:obj context:context];
                                if (object) dict[key] = object;
                            }
                        }
                        mj_selfSet(property, id, dict);
                        continue;
                    }
                    if (basicObjectType == MJEBasicTypeMutableDictionary) {
                        result = result.mutableCopy;
                    }
                    mj_selfSet(property, id, result);
                } break;
                    
                case MJEBasicTypeSet:
                case MJEBasicTypeMutableSet:{
                    NSSet *result;
                    if ([value isKindOfClass:NSArray.class]) result = [NSSet setWithArray:value];
                    else if ([value isKindOfClass:NSSet.class]) result = value;
                    // generic
                    if (classInCollecion) {
                        NSMutableSet *set = [NSMutableSet setWithCapacity:result.count];
                        for (id element in result) {
                            if ([element isKindOfClass:classInCollecion]) {
                                [set addObject:element];
                            } else if ([element isKindOfClass:NSDictionary.class]) {
                                Class cls = classInCollecion;
                                if (property->_hasClassModifier) {
                                    cls = [cls mj_modifiedClassForDictionary:element];
                                    if (!cls) cls = classInCollecion;
                                }
                                id object = [cls mj_objectWithKeyValues:element context:context];
                                if (object) [set addObject:object];
                            }
                        }
                        mj_selfSet(property, id, set);
                        continue;
                    }
                    if (basicObjectType == MJEBasicTypeMutableSet) {
                        result = result.mutableCopy;
                    }
                    mj_selfSet(property, id, result);
                } break;
                    
                case MJEBasicTypeOrderedSet:
                case MJEBasicTypeMutableOrderedSet:{
                    NSOrderedSet *result;
                    if ([value isKindOfClass:NSArray.class]) result = [NSOrderedSet orderedSetWithArray:value];
                    else if ([value isKindOfClass:NSSet.class]) result = [NSOrderedSet orderedSetWithSet:value];
                    else if ([value isKindOfClass:NSOrderedSet.class]) result = value;
                    // generic
                    if (classInCollecion) {
                        NSMutableOrderedSet *set = [NSMutableOrderedSet orderedSetWithCapacity:result.count];
                        for (id element in result) {
                            if ([element isKindOfClass:classInCollecion]) {
                                [set addObject:element];
                            } else if ([element isKindOfClass:NSDictionary.class]) {
                                Class cls = classInCollecion;
                                if (property->_hasClassModifier) {
                                    cls = [cls mj_modifiedClassForDictionary:element];
                                    if (!cls) cls = classInCollecion;
                                }
                                id object = [cls mj_objectWithKeyValues:element context:context];
                                if (object) [set addObject:object];
                            }
                        }
                        mj_selfSet(property, id, set);
                        continue;
                    }
                    if (basicObjectType == MJEBasicTypeMutableOrderedSet) {
                        result = result.mutableCopy;
                    }
                    mj_selfSet(property, id, result);
                } break;
                default: break;
            }
        } else {
            switch (type) {
                case MJEPropertyTypeObject: {
                    if ([value isKindOfClass:typeClass] || !typeClass) {
                        mj_selfSet(property, id, value);
                    } else if ([value isKindOfClass:NSDictionary.class]) {
                        NSObject *subObject = mj_selfGet(property, id);
                        if (subObject) {
                            [subObject mj_setKeyValues:value context:context];
                        } else {
                            Class cls = typeClass;
                            if (property->_hasClassModifier) {
                                cls = [cls mj_modifiedClassForDictionary:value];
                                if (!cls) cls = property.classInCollection;
                            }
                            subObject = [cls mj_objectWithKeyValues:value
                                                            context:context];
                            mj_selfSet(property, id, subObject);
                        }
                    }
                } break;
                case MJEPropertyTypeClass: {
                    Class cls = nil;
                    if ([value isKindOfClass:NSString.class]) {
                        cls = NSClassFromString(value);
                        if (cls) mj_selfSet(property, Class, cls);
                    } else {
                        cls = object_getClass(value);
                        if (cls && class_isMetaClass(cls)) {
                            mj_selfSet(property, Class, value);
                        }
                    }
                } break;
                case MJEPropertyTypeSEL: {
                    if ([value isKindOfClass:NSString.class]) {
                        SEL selector = NSSelectorFromString(value);
                        if (selector) mj_selfSet(property, SEL, selector);
                    }
                } break;
                default:
                    break;
            }
        }
    }
}

- (void)mj_slowEnumerateProperties:(NSArray<MJProperty *> *)properties
                withDictionary:(NSDictionary *)dictionary
                    classCache:(MJEClass *)classCache
                       context:(NSManagedObjectContext *)context {
    NSLocale *locale = classCache->_numberLocale;
    for (MJProperty *property in properties) {
        @try {
            // 1.取出属性值
            id value;
            if (!property->_isMultiMapping) {
                value = dictionary[property->_mappedKey];
            } else {
                value = [property valueInDictionary:dictionary];
            }
            
            if (classCache->_hasOld2NewModifier
                && property->_hasValueModifier) {
                id newValue = [self mj_newValueFromOldValue:value property:property];
                if (newValue != value) { // 有过滤后的新值
                    [property setValue:newValue forObject:self];
                    continue;
                }
            }
            
            // 如果没有值，就直接返回
            if (!value) continue;
            if (value == NSNull.null) {
                mj_selfSet(property, id, nil);
                continue;
            }
                
            // 2.复杂处理
            MJEPropertyType type = property.type;
            Class propertyClass = property.typeClass;
            Class objectClass = property.classInCollection;
            
            // 不可变 -> 可变处理
            if (propertyClass == [NSMutableArray class] && [value isKindOfClass:[NSArray class]]) {
                value = [NSMutableArray arrayWithArray:value];
            } else if (propertyClass == [NSMutableDictionary class] && [value isKindOfClass:[NSDictionary class]]) {
                value = [NSMutableDictionary dictionaryWithDictionary:value];
            } else if (propertyClass == [NSMutableString class] && [value isKindOfClass:[NSString class]]) {
                value = [NSMutableString stringWithString:value];
            } else if (propertyClass == [NSMutableData class] && [value isKindOfClass:[NSData class]]) {
                value = [NSMutableData dataWithData:value];
            }
            
            if (property->_basicObjectType == MJEBasicTypeUndefined && propertyClass) { // 模型属性
                value = [propertyClass mj_objectWithKeyValues:value context:context];
            } else if (objectClass) {
                if (objectClass == [NSURL class] && [value isKindOfClass:[NSArray class]]) {
                    // string array -> url array
                    NSMutableArray *urlArray = [NSMutableArray array];
                    for (NSString *string in value) {
                        if (![string isKindOfClass:[NSString class]]) continue;
                        [urlArray addObject:string.mj_url];
                    }
                    value = urlArray;
                } else { // 字典数组-->模型数组
                    value = [objectClass mj_objectArrayWithKeyValuesArray:value context:context];
                }
            } else if (propertyClass == [NSString class]) {
                if ([value isKindOfClass:[NSNumber class]]) {
                    // NSNumber -> NSString
                    value = [value description];
                } else if ([value isKindOfClass:[NSURL class]]) {
                    // NSURL -> NSString
                    value = [value absoluteString];
                }
            } else if ([value isKindOfClass:[NSString class]]) {
                if (propertyClass == [NSURL class]) {
                    // NSString -> NSURL
                    // 字符串转码
                    value = [value mj_url];
                } else if (type == MJEPropertyTypeLongDouble) {
                    long double num = [value mj_longDoubleValueWithLocale:locale];
                    mj_selfSend(property.setter, long double, num);
                    continue;
                } else if (type == MJEPropertyTypeDouble) {
                    double num = ((NSString *)value).doubleValue;
                    mj_selfSend(property.setter, double, num);
                    continue;
                } else if (property->_basicObjectType == MJEBasicTypeData || property->_basicObjectType == MJEBasicTypeMutableData) {
                    value = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding].mutableCopy;
                } else if (property.isNumber) {
                    NSString *oldValue = value;
                    
                    // NSString -> NSDecimalNumber, 使用 DecimalNumber 来转换数字, 避免丢失精度以及溢出
                    NSDecimalNumber *decimalValue = [NSDecimalNumber
                                                     decimalNumberWithString:oldValue
                                                     locale:locale];
                    
                    // 检查特殊情况
                    if (decimalValue == NSDecimalNumber.notANumber) {
                        value = @(0);
                    } else if (propertyClass != [NSDecimalNumber class]) {
                        switch (type) {
                            case MJEPropertyTypeInt64:
                                value = @(decimalValue.longLongValue);
                            case MJEPropertyTypeUInt64:
                                value = @(decimalValue.unsignedLongLongValue);
                            case MJEPropertyTypeInt32:
                                value = @(decimalValue.longValue);
                            case MJEPropertyTypeUInt32:
                                value = @(decimalValue.unsignedLongValue);
                            default:
                                value = @(decimalValue.doubleValue);
                        }
                    } else {
                        value = decimalValue;
                    }
                    
                    // 如果是BOOL
                    if (type == MJEPropertyTypeBool || type == MJEPropertyTypeInt8) {
                        // 字符串转BOOL（字符串没有charValue方法）
                        // 系统会调用字符串的charValue转为BOOL类型
                        NSString *lower = [oldValue lowercaseString];
                        if ([lower isEqualToString:@"yes"] || [lower isEqualToString:@"true"]) {
                            value = @YES;
                        } else if ([lower isEqualToString:@"no"] || [lower isEqualToString:@"false"]) {
                            value = @NO;
                        }
                    }
                }
            } else if ([value isKindOfClass:[NSNumber class]] && propertyClass == [NSDecimalNumber class]){
                // 过滤 NSDecimalNumber类型
                if (![value isKindOfClass:[NSDecimalNumber class]]) {
                    value = [NSDecimalNumber decimalNumberWithDecimal:[((NSNumber *)value) decimalValue]];
                }
            }
            
            // 经过转换后, 最终检查 value 与 property 是否匹配
            if (propertyClass && ![value isKindOfClass:propertyClass]) {
                value = nil;
            }
            
            // 3.赋值
            // long double 是不支持 KVC 的
            if (property.type == MJEPropertyTypeLongDouble) {
                mj_selfSend(property.setter, long double, ((NSNumber *)value).doubleValue);
                continue;
            } else {
                [property setValue:value forObject:self];
            }
        } @catch (NSException *exception) {
            MJExtensionBuildError([self class], exception.reason);
            MJExtensionLog(@"%@", exception);
#ifdef DEBUG
            [exception raise];
#endif
        }
    }
}

BOOL MJE_isFromFoundation(Class _Nonnull cls) {
    if (cls == NSObject.class || cls == NSManagedObject.class) return YES;
    
    static NSSet *foundationClasses;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 集合中没有NSObject，因为几乎所有的类都是继承自NSObject，具体是不是NSObject需要特殊判断
        foundationClasses = [NSSet setWithObjects:
                             NSURL.class,
                             NSDate.class,
                             NSValue.class,
                             NSData.class,
                             NSArray.class,
                             NSDictionary.class,
                             NSString.class,
                             NSAttributedString.class,
                             NSSet.class,
                             NSOrderedSet.class,
                             NSError.class, nil];
    });
    
    for (Class testedClass in foundationClasses) {
        if ([cls isSubclassOfClass:testedClass]) return YES;
    }
    return NO;
}

// Special dealing method. `value` should be NSString or NSNumber
- (NSNumber *)mj_numberWithValue:(id)value
                            type:(MJEPropertyType)type
                          locale:(NSLocale *)locale {
    static NSDictionary *boolStrings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        boolStrings = @{
            @"TRUE":   @(YES),
            @"True":   @(YES),
            @"true":   @(YES),
            @"YES":    @(YES),
            @"Yes":    @(YES),
            @"yes":    @(YES),
            
            @"FALSE":  @(NO),
            @"False":  @(NO),
            @"false":  @(NO),
            @"NO":     @(NO),
            @"No":     @(NO),
            @"no":     @(NO),
            @"NIL":    NSNull.null,
            @"Nil":    NSNull.null,
            @"nil":    NSNull.null,
            @"NULL":   NSNull.null,
            @"Null":   NSNull.null,
            @"null":   NSNull.null,
            @"(NULL)": NSNull.null,
            @"(Null)": NSNull.null,
            @"(null)": NSNull.null,
            @"<NULL>": NSNull.null,
            @"<Null>": NSNull.null,
            @"<null>": NSNull.null
        };
    });
    if (!value || value == NSNull.null) return nil;
    NSNumber *number;
    if ([value isKindOfClass:NSNumber.class]) number = value;
    if ([value isKindOfClass:NSString.class]) {
        NSString *string = value;
        NSNumber *num = boolStrings[string];
        if (num) {
            number = num;
        } else if (type == MJEPropertyTypeDouble) {
            number = @([string mj_doubleValueWithLocale:locale]);
        // LongDouble cannot be represented by NSNumber
        } else if (type != MJEPropertyTypeLongDouble) {
            number = [NSDecimalNumber
                      decimalNumberWithString:string locale:locale];
            if (number == NSDecimalNumber.notANumber) {
                number = nil;
            }
        }
    }
    return number;
}

@end
