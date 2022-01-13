//
//  MJEClass.m
//  MJExtension
//
//  Created by Frank on 2021/12/1.
//  Copyright © 2021 MJ Lee. All rights reserved.
//

#import "MJEClass.h"
#import "MJExtensionPredefine.h"
#import "MJExtensionProtocols.h"
#import "MJProperty.h"
#import "MJExtension_Private.h"

typedef void (^MJClassesEnumeration)(Class c, BOOL *stop);

@interface NSObject (MJEClass)
/// eumerate all classes except Foundation basic classes
+ (void)mj_enumerateClasses:(MJClassesEnumeration)enumeration;
@end

@implementation NSObject (MJEClass)

+ (void)mj_enumerateClasses:(MJClassesEnumeration)enumeration {
    if (enumeration == nil) return;
    BOOL stop = NO;
    Class c = self;
    while (c && !stop) {
        enumeration(c, &stop);
        c = class_getSuperclass(c);
        if (MJE_isFromFoundation(c)) break;
    }
}
@end

@implementation MJEClass

- (instancetype)initWithClass:(Class)cls {
    if (!cls) return nil;
    self = [super init];
    
    _isNSManaged = [cls isSubclassOfClass:NSManagedObject.class];
    
    // Check inheritance of configurations
    BOOL shouldAutoInheritFromSuper = YES;
    if ([cls respondsToSelector:@selector(mj_shouldAutoInheritConfigurations)]) {
        shouldAutoInheritFromSuper = [cls mj_shouldAutoInheritConfigurations];
    }
    _shouldReferToKeyReplacementInJSONExport = YES;
    if ([cls respondsToSelector:@selector(mj_shouldReferToKeyReplacementInJSONExport)]) {
        _shouldReferToKeyReplacementInJSONExport = [cls mj_shouldReferToKeyReplacementInJSONExport];
    }
    
    NSMutableSet *ignoredList = [NSMutableSet new];
    NSMutableSet *allowedList = [NSMutableSet new];
    NSMutableSet *ignoredList2JSON = [NSMutableSet new];
    NSMutableSet *allowedList2JSON = [NSMutableSet new];
    NSMutableSet *ignoredCodingList = [NSMutableSet new];
    NSMutableSet *allowedCodingList = [NSMutableSet new];
    NSMutableDictionary *genericClasses = [NSMutableDictionary new];
    NSMutableDictionary *replacedKeys = [NSMutableDictionary new];
    NSMutableSet *old2NewList = [NSMutableSet new];
    
    Class<MJEConfiguration> currentClass = cls;
    while (1) {
        // get ignored property names
        MJEAddSelectorResult2Set(currentClass,
                                 @selector(mj_ignoredPropertyNames),
                                 ignoredList);
        
        // get allowed property names
        MJEAddSelectorResult2Set(currentClass,
                                 @selector(mj_allowedPropertyNames),
                                 allowedList);
        
        // get ignored property names to JSON
        MJEAddSelectorResult2Set(currentClass,
                                 @selector(mj_ignoredPropertyNamesToJSON),
                                 ignoredList2JSON);
        
        // get allowed property names to JSON
        MJEAddSelectorResult2Set(currentClass,
                                 @selector(mj_allowedPropertyNamesToJSON),
                                 allowedList2JSON);
        
        // get ignored coding property names
        MJEAddSelectorResult2Set(currentClass,
                                 @selector(mj_ignoredCodingPropertyNames),
                                 ignoredCodingList);
        
        // get allowed coding property names
        MJEAddSelectorResult2Set(currentClass,
                                 @selector(mj_allowedCodingPropertyNames),
                                 allowedCodingList);
        
        // get old value to new one property name list
        MJEAddSelectorResult2Set(currentClass,
                                 @selector(mj_modifyOldToNewPropertyNames),
                                 old2NewList);
        
        // get generic classes
        MJEAddSelectorResult2Dictionary(currentClass,
                                        @selector(mj_classInfoInCollection),
                                        genericClasses);
        // Deprecated API compatibility
        if (![currentClass respondsToSelector:@selector(mj_classInfoInCollection)]) {
            MJEAddSelectorResult2Dictionary(currentClass,
                                            @selector(mj_objectClassInArray),
                                            genericClasses);
        }
        
        // get replaced keys
        MJEAddSelectorResult2Dictionary(currentClass,
                                        @selector(mj_replacedKeyFromPropertyName),
                                        replacedKeys);
        
        // Check if need inherit from super class. Break loop if not.
        if (!shouldAutoInheritFromSuper) break;
        
        Class superClass = class_getSuperclass(currentClass);
        // Break the loop if current class is root class (NSObject / NSProxy)
        if (currentClass && !superClass) break;
        currentClass = superClass;
    }
    
    // Check replacing modifier
    BOOL hasKeyReplacementModifier = [cls respondsToSelector:@selector(mj_replacedKeyFromPropertyName121:)];
    // get the property lists
    [self mj_handlePropertiesWithAllowedList:allowedList
                                 ignoredList:ignoredList
                            allowedList2JSON:allowedList2JSON
                            ignoredList2JSON:ignoredList2JSON
                           allowedCodingList:allowedCodingList
                           ignoredCodingList:ignoredCodingList
                                 old2NewList:old2NewList
                              genericClasses:genericClasses
                                replacedKeys:replacedKeys
                   hasKeyReplacementModifier:hasKeyReplacementModifier
                                     inClass:cls];
    
    if ([cls respondsToSelector:@selector(mj_numberLocale)]) {
        _numberLocale = [cls mj_numberLocale];
    }
    
    if ([cls respondsToSelector:@selector(mj_dateFormatter)]) {
        _dateFormatter = [cls mj_dateFormatter];
    }
    _hasOld2NewModifier = [cls instancesRespondToSelector:@selector(mj_newValueFromOldValue:property:)];
    _hasDictionary2ObjectModifier = [cls instancesRespondToSelector:@selector(mj_didConvertToObjectWithKeyValues:)];
    _hasObject2DictionaryModifier = [cls instancesRespondToSelector:@selector(mj_objectDidConvertToKeyValues:)];
    
    return self;
}

+ (instancetype)cachedClass:(Class)cls {
    if (!cls) return nil;
    static NSMutableDictionary *classCache;
    static dispatch_semaphore_t lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        classCache = [NSMutableDictionary new];
        lock = dispatch_semaphore_create(1);
    });
    // Uses only 1 lock to avoid concurrent operation from a mess.
    // There are too many locks before 4.0.0 version.
    MJ_LOCK(lock);
    MJEClass *cachedClass = classCache[cls];
    if (!cachedClass || cachedClass->_needsUpdate) {
        cachedClass = [[MJEClass alloc] initWithClass:cls];
        classCache[(id)cls] = cachedClass;
        cachedClass->_needsUpdate = NO;
    }
    MJ_UNLOCK(lock);
    
    return cachedClass;
}

- (void)mj_handlePropertiesWithAllowedList:(NSSet *)allowedList
                               ignoredList:(NSSet *)ignoredList
                          allowedList2JSON:(NSSet *)allowedList2JSON
                          ignoredList2JSON:(NSSet *)ignoredList2JSON
                         allowedCodingList:(NSSet *)allowedCodingList
                         ignoredCodingList:(NSSet *)ignoredCodingList
                               old2NewList:(NSSet *)old2NewList
                            genericClasses:(NSDictionary *)genericClasses
                              replacedKeys:(NSDictionary *)replacedKeys
                 hasKeyReplacementModifier:(BOOL)hasKeyReplacementModifier
                                   inClass:(Class)cls {
    NSMutableArray<MJProperty *> *allProperties = NSMutableArray.array;
    NSMutableArray<MJProperty *> *codingProperties = NSMutableArray.array;
    NSMutableArray<MJProperty *> *allProperties2JSON = NSMutableArray.array;
    NSMutableDictionary *mapper = NSMutableDictionary.dictionary;
    NSMutableArray<MJProperty *> *multiKeysProperties = NSMutableArray.array;

    [cls mj_enumerateClasses:^(__unsafe_unretained Class c, BOOL *stop) {
        // 1. get all property list
        unsigned int outCount = 0;
        objc_property_t *properties = class_copyPropertyList(c, &outCount);
        
        // 2. iterate property list
        for (unsigned int i = 0; i < outCount; i++) {
            MJProperty *property = [[MJProperty alloc]
                                    initWithProperty:properties[i] inClass:c];
            // If neither of setter and getter is not existed, this value should not be treated as property we cares.
            // e.g.: NSObject default properties `hash`, `superclass`, `description`, `debugDescription`, , which is defined by `NSObject` protocol.
            // Computed property (readonly). It is not a real property, which is just a get method.
            if (!property.setter || !property.getter) continue;
            // handle properties for coding
            if (!allowedCodingList.count || [allowedCodingList containsObject:property.name]) {
                if (![ignoredCodingList containsObject:property.name]) {
                    [codingProperties addObject:property];
                }
            }
            // handle properties for object to JSON conversion.
            if (!allowedList2JSON.count || [allowedList2JSON containsObject:property.name]) {
                if (![ignoredList2JSON containsObject:property.name]) {
                    [allProperties2JSON addObject:property];
                }
            }
            // check allowed list
            if (allowedList.count && ![allowedList containsObject:property.name]) continue;
            // check ingored list
            if ([ignoredList containsObject:property.name]) continue;
            // only 2 ways to set value modifier flag to true
            // 1. old2NewList exists and contains specific value
            // 2. old2NewList does not exist (that would be allowed but converting speed will be slower.)
            if ([old2NewList containsObject:property.name]
                || !old2NewList.count) {
                property->_hasValueModifier = YES;
            }
            // handle generic class
            {
                id genericClass = genericClasses[property.name];
                if ([genericClass isKindOfClass:NSString.class]) {
                    genericClass = NSClassFromString(genericClass);
                }
                property.classInCollection = genericClass;
                // check the ability to change class.
                if (genericClass) { // generic
                    property->_hasClassModifier = [genericClass respondsToSelector:@selector(mj_modifiedClassForDictionary:)];
                } else if (property.isCustomModelType) { // for those superclass and subclass customization
                    property->_hasClassModifier = [property.typeClass respondsToSelector:@selector(mj_modifiedClassForDictionary:)];
                }
            }
            
            // handle key modifier and replacement
            {
                id key = property.name;
                // Modify replaced key using special method
                if (hasKeyReplacementModifier) {
                    key = [cls mj_replacedKeyFromPropertyName121:key] ?: key;
                }
                // serch key in replaced dictionary
                key = replacedKeys[property.name] ?: key;
                
                // handle keypath / keypath array / keypath array(with subkey)
                [property handleOriginKey:key];
                
                // The property matched with a singular key is the only condition for dictionary enumeration.
                if (property->_isMultiMapping) {
                    [multiKeysProperties addObject:property];
                } else {
                    property->_nextSame = mapper[property->_mappedKey] ?: nil;
                    mapper[property->_mappedKey] = property;
                }
            }
            
            [allProperties addObject:property];
        }
        
        // 3. release the memory
        free(properties);
    }];
    
    _allProperties = allProperties.copy;
    _allCodingProperties = codingProperties.copy;
    _allProperties2JSON = allProperties2JSON.copy;
    _mapper = mapper.copy;
    _multiKeysProperties = multiKeysProperties.copy;

    _propertiesCount = _allProperties.count;
}

- (void)setNeedsUpdate {
    _needsUpdate = YES;
}

void MJEAddSelectorResult2Set(Class cls, SEL selector, NSMutableSet *set) {
    if ([cls respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSArray *result = [cls performSelector:selector];
#pragma clang diagnostic pop
        if (result) {
            [set addObjectsFromArray:result];
        }
    }
    if (!set.count) set = nil;
}

void MJEAddSelectorResult2Dictionary(Class cls, SEL selector, NSMutableDictionary *dictionary) {
    if ([cls respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSDictionary *result = [cls performSelector:selector];
#pragma clang diagnostic pop
        if (result) {
            [dictionary addEntriesFromDictionary:result];
        }
    }
    if (!dictionary.count) dictionary = nil;
}

@end
