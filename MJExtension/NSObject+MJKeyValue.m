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
#import "MJExtensionConst.h"
#import "MJFoundation.h"
#import "MJEClass.h"
#import "MJExtensionProtocols.h"
#import "NSDate+MJExtension.h"

#define mj_selfSend(sel, type, value) mj_msgSendOne(self, sel, type, value)
#define mj_selfSet(property, type, value) mj_selfSend(property.setter, type, value)
#define mj_selfGet(property, type) mj_msgSendGet(self, property.getter, type)

@interface NSObject () <MJEConfiguration>

@end
@implementation NSObject (MJKeyValue)

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
        } else if (type != MJEPropertyTypeLongDouble) {
            // LongDouble cannot be represented by NSNumber
            number = [NSDecimalNumber
                      decimalNumberWithString:string locale:locale];
            if (number == NSDecimalNumber.notANumber) {
                number = nil;
            }
        }
    }
    return number;
}

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

#pragma mark - 模型 -> 字典时的参考
/** 模型转字典时，字典的key是否参考replacedKeyFromPropertyName等方法（父类设置了，子类也会继承下来） */
static const char MJReferenceReplacedKeyWhenCreatingKeyValuesKey = '\0';

+ (void)mj_referenceReplacedKeyWhenCreatingKeyValues:(BOOL)reference
{
    objc_setAssociatedObject(self, &MJReferenceReplacedKeyWhenCreatingKeyValuesKey, @(reference), OBJC_ASSOCIATION_ASSIGN);
}

+ (BOOL)mj_isReferenceReplacedKeyWhenCreatingKeyValues
{
    id value = objc_getAssociatedObject(self, &MJReferenceReplacedKeyWhenCreatingKeyValuesKey);
    return [value boolValue];
}

#pragma mark - --常用的对象--
+ (void)load
{
    // 默认设置
    [self mj_referenceReplacedKeyWhenCreatingKeyValues:YES];
}

#pragma mark - --公共方法--
#pragma mark - 字典 -> 模型
- (instancetype)mj_setKeyValues:(id)keyValues {
    return [self mj_setKeyValues:keyValues context:nil];
}

/** 核心代码: */
- (instancetype)mj_setKeyValues:(id)keyValues
                        context:(NSManagedObjectContext *)context {
    id object = keyValues;
    if (![object isKindOfClass:NSDictionary.class]) object = [object mj_JSONObject];
    
    MJExtensionAssertError([object isKindOfClass:[NSDictionary class]], self, [self class], @"keyValues参数不是一个字典");
    
    MJEClass *classCache = [MJEClass cachedClass:self.class];
    NSDictionary *dict = object;

    [self mj_enumerateProperties:classCache->_allProperties
                  withDictionary:dict classCache:classCache context:context];

    // 转换完毕
    if (classCache->_hasDictionary2ObjectModifier) {
        [self mj_didConvertToObjectWithKeyValues:keyValues];
    }
    return self;
}

- (void)mj_enumerateProperties:(NSArray<MJProperty *> *)properties
                    withDictionary:(NSDictionary *)dictionary
                        classCache:(MJEClass *)classCache
                           context:(NSManagedObjectContext *)context {
    NSLocale *locale = classCache->_locale;
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
                                                 locale:classCache->_locale];
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
                                                      locale:classCache->_locale];
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
                                if ([element isKindOfClass:NSString.class]) [objects addObject:[element mj_url]];
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
                        [result enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
                            if ([obj isKindOfClass:[NSDictionary class]]) {
                                Class cls = classInCollecion;
                                if (property->_hasClassModifier) {
                                    cls = [cls mj_modifiedClassForDictionary:obj];
                                    if (!cls) cls = classInCollecion;
                                }
                                id object = [cls mj_objectWithKeyValues:obj context:context];
                                if (object) dict[key] = object;
                            }
                        }];
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
    NSLocale *locale = classCache->_locale;
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
                //FIXME: Bottleneck #4: Do not call method
                [property setValue:value forObject:self];
//                if (!property->_isKVCCompliant || value == nil) return;
//                //FIXME: Bottleneck #4: Enhanced
//                [self setValue:value forKey:property.name];
//            //    mj_msgSendOne(object, _setter, id, value);
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

+ (instancetype)mj_objectWithKeyValues:(id)keyValues
{
    return [self mj_objectWithKeyValues:keyValues context:nil];
}

+ (instancetype)mj_objectWithKeyValues:(id)keyValues context:(NSManagedObjectContext *)context {
    if ([self isSubclassOfClass:[NSManagedObject class]] && context) {
        NSString *entityName = [(NSManagedObject *)self entity].name;
        return [[NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context] mj_setKeyValues:keyValues context:context];
    }
    return [[[self alloc] init] mj_setKeyValues:keyValues];
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

#pragma mark - 字典数组 -> 模型数组
+ (NSMutableArray *)mj_objectArrayWithKeyValuesArray:(NSArray *)keyValuesArray
{
    return [self mj_objectArrayWithKeyValuesArray:keyValuesArray context:nil];
}

+ (NSMutableArray *)mj_objectArrayWithKeyValuesArray:(id)keyValuesArray context:(NSManagedObjectContext *)context
{
    id objects = keyValuesArray;
    // 如果是JSON字符串
    if (![keyValuesArray isKindOfClass:NSArray.class]) {
        keyValuesArray = [keyValuesArray mj_JSONObject];
    }
    // 1.判断真实性
    MJExtensionAssertError([keyValuesArray isKindOfClass:[NSArray class]], nil, [self class], @"keyValuesArray参数不是一个数组");
    
    // 如果数组里面放的是NSString、NSNumber等数据
    if ([MJFoundation isClassFromFoundation:self]) return [NSMutableArray arrayWithArray:keyValuesArray];
    
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

#pragma mark - 模型 -> 字典
- (NSMutableDictionary *)mj_keyValues
{
    return [self mj_keyValuesWithKeys:nil ignoredKeys:nil];
}

- (NSMutableDictionary *)mj_keyValuesWithKeys:(NSArray *)keys
{
    return [self mj_keyValuesWithKeys:keys ignoredKeys:nil];
}

- (NSMutableDictionary *)mj_keyValuesWithIgnoredKeys:(NSArray *)ignoredKeys
{
    return [self mj_keyValuesWithKeys:nil ignoredKeys:ignoredKeys];
}

- (NSMutableDictionary *)mj_keyValuesWithKeys:(NSArray *)keys ignoredKeys:(NSArray *)ignoredKeys
{
    // 如果自己不是模型类, 那就返回自己
    // 模型类过滤掉 NSNull
    // 唯一一个不返回自己的
    if (self == NSNull.null) return nil;
    // 这里虽然返回了自己, 但是其实是有报错信息的.
    // TODO: 报错机制不好, 需要重做
    MJExtensionAssertError(![MJFoundation isClassFromFoundation:[self class]], (NSMutableDictionary *)self, [self class], @"不是自定义的模型类")
    
    id keyValues = [NSMutableDictionary dictionary];
    
    MJEClass *mjeClass = [MJEClass cachedClass:self.class];
    NSArray<MJProperty *> *allProperties = mjeClass->_allProperties;
    
    for (MJProperty *property in allProperties) {
        @try {
            // 0.检测是否被忽略
            if (keys.count && ![keys containsObject:property.name]) continue;
            if ([ignoredKeys containsObject:property.name]) continue;
            
            // 1.取出属性值
            id value = [property valueForObject:self];
            if (!value) continue;
            
            // 2.如果是模型属性
            Class propertyClass = property.typeClass;
            MJEBasicType basicObjectType = property->_basicObjectType;
            if (basicObjectType == MJEBasicTypeUndefined && propertyClass) {
                value = [value mj_keyValues];
            } else if ([value isKindOfClass:[NSArray class]]) {
                // 3.处理数组里面有模型的情况
                value = [NSObject mj_keyValuesArrayWithObjectArray:value];
            } else if (basicObjectType == MJEBasicTypeURL) {
                value = [value absoluteString];
            } else if (basicObjectType == MJEBasicTypeAttributedString || property->_basicObjectType == MJEBasicTypeMutableAttributedString) {
                value = [(NSAttributedString *)value string];
            } else if (basicObjectType == MJEBasicTypeDate) {
                value = [value mj_defaultDateString];
            }
            
            // 4.赋值
            if ([self.class mj_isReferenceReplacedKeyWhenCreatingKeyValues]) {
                if (property->_isMultiMapping) {
                    NSArray *propertyKeys = [property->_mappedMultiKeys firstObject];
                    NSUInteger keyCount = propertyKeys.count;
                    // 创建字典
                    __block id innerContainer = keyValues;
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
                    keyValues[property->_mappedKey] = value;
                }
            } else {
                keyValues[property.name] = value;
            }
        } @catch (NSException *exception) {
            MJExtensionBuildError([self class], exception.reason);
            MJExtensionLog(@"%@", exception);
#ifdef DEBUG
            [exception raise];
#endif
        }
    }
    
    // 转换完毕
    if (mjeClass->_hasObject2DictionaryModifier) {
        [self mj_objectDidConvertToKeyValues:keyValues];
    }
    
    return keyValues;
}
#pragma mark - 模型数组 -> 字典数组
+ (NSMutableArray *)mj_keyValuesArrayWithObjectArray:(NSArray *)objectArray
{
    return [self mj_keyValuesArrayWithObjectArray:objectArray keys:nil ignoredKeys:nil];
}

+ (NSMutableArray *)mj_keyValuesArrayWithObjectArray:(NSArray *)objectArray keys:(NSArray *)keys
{
    return [self mj_keyValuesArrayWithObjectArray:objectArray keys:keys ignoredKeys:nil];
}

+ (NSMutableArray *)mj_keyValuesArrayWithObjectArray:(NSArray *)objectArray ignoredKeys:(NSArray *)ignoredKeys
{
    return [self mj_keyValuesArrayWithObjectArray:objectArray keys:nil ignoredKeys:ignoredKeys];
}

+ (NSMutableArray *)mj_keyValuesArrayWithObjectArray:(NSArray *)objectArray keys:(NSArray *)keys ignoredKeys:(NSArray *)ignoredKeys
{
    // 0.判断真实性
    MJExtensionAssertError([objectArray isKindOfClass:[NSArray class]], nil, [self class], @"objectArray参数不是一个数组");
    
    // 1.创建数组
    NSMutableArray *keyValuesArray = [NSMutableArray array];
    for (id object in objectArray) {
        if (keys) {
            id convertedObj = [object mj_keyValuesWithKeys:keys];
            if (!convertedObj) { continue; }
            [keyValuesArray addObject:convertedObj];
        } else {
            id convertedObj = [object mj_keyValuesWithIgnoredKeys:ignoredKeys];
            if (!convertedObj) { continue; }
            [keyValuesArray addObject:convertedObj];
        }
    }
    return keyValuesArray;
}

#pragma mark - 转换为JSON
- (NSData *)mj_JSONData
{
    if ([self isKindOfClass:[NSString class]]) {
        return [((NSString *)self) dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([self isKindOfClass:[NSData class]]) {
        return (NSData *)self;
    }
    
    return [NSJSONSerialization dataWithJSONObject:[self mj_JSONObject] options:kNilOptions error:nil];
}

- (id)mj_JSONObject
{
    if ([self isKindOfClass:[NSString class]]) {
        return [NSJSONSerialization JSONObjectWithData:[((NSString *)self) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    } else if ([self isKindOfClass:[NSData class]]) {
        return [NSJSONSerialization JSONObjectWithData:(NSData *)self options:kNilOptions error:nil];
    }
    
    return self.mj_keyValues;
}

- (NSString *)mj_JSONString
{
    if ([self isKindOfClass:[NSString class]]) {
        return (NSString *)self;
    } else if ([self isKindOfClass:[NSData class]]) {
        return [[NSString alloc] initWithData:(NSData *)self encoding:NSUTF8StringEncoding];
    }
    
    return [[NSString alloc] initWithData:[self mj_JSONData] encoding:NSUTF8StringEncoding];
}

@end
