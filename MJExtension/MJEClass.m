//
//  MJEClass.m
//  MJExtension
//
//  Created by Frank on 2021/12/1.
//  Copyright © 2021 MJ Lee. All rights reserved.
//

#import "MJEClass.h"
#import "MJExtensionConst.h"
#import "MJExtensionProtocols.h"
#import "MJFoundation.h"
#import "MJProperty.h"

#define always_inline __inline__ __attribute__((always_inline))

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
        if ([MJFoundation isClassFromFoundation:c]) break;
    }
}
@end

@implementation MJEClass

- (instancetype)initWithClass:(Class)cls {
    if (!cls) return nil;
    self = [super init];
    
    // Check inheritance of configurations
    BOOL shouldAutoInheritFromSuper = YES;
    if ([cls respondsToSelector:@selector(mj_shouldAutoInheritConfigurations)]) {
        shouldAutoInheritFromSuper = [cls mj_shouldAutoInheritConfigurations];
    }
    
    NSMutableSet *ignoredList = [NSMutableSet new];
    NSMutableSet *allowedList = [NSMutableSet new];
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
        
        // get old value to new one property name list
        MJEAddSelectorResult2Set(currentClass,
                                 @selector(mj_modifyOld2NewPropertyNames),
                                 old2NewList);
        
        // get generic classes
        MJEAddSelectorResult2Dictionary(currentClass,
                                        @selector(mj_objectClassInCollection),
                                        genericClasses);
        
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
    // get the property list
    _allProperties = [self
                      mj_allPropertiesWithAllowedList:allowedList
                      ignoredList:ignoredList
                      old2NewList:old2NewList
                      genericClasses:genericClasses
                      replacedKeys:replacedKeys
                      hasKeyReplacementModifier:hasKeyReplacementModifier
                      inClass:cls];
    
    _hasLocaleModifier = [cls respondsToSelector:@selector(mj_locale)];
    _hasOld2NewModifier = [cls instancesRespondToSelector:@selector(mj_newValueFromOldValue:property:)];
    // TODO: 4.0.0 new feature
//    _hasClassModifier = [
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
    // uses only 1 lock to avoid concurrent operation from a mess.
    // too many locks before 4.0.0 version.
    MJ_LOCK(lock);
    MJEClass *cachedClass = classCache[cls];
    if (!cachedClass || cachedClass->_needsUpdate) {
        cachedClass = [[MJEClass alloc] initWithClass:cls];
        classCache[(id)cls] = cachedClass;
    }
    MJ_UNLOCK(lock);
    
    return cachedClass;
}

- (NSArray<MJProperty *> *)mj_allPropertiesWithAllowedList:(NSSet *)allowedList
                                               ignoredList:(NSSet *)ignoredList
                                               old2NewList:(NSSet *)old2NewList
                                            genericClasses:(NSDictionary *)genericClasses
                                              replacedKeys:(NSDictionary *)replacedKeys
                                 hasKeyReplacementModifier:(BOOL)hasKeyReplacementModifier
                                                   inClass:(Class)cls {
    NSMutableArray<MJProperty *> *allProperties = [NSMutableArray array];
    [cls mj_enumerateClasses:^(__unsafe_unretained Class c, BOOL *stop) {
        // 1. get all property list
        unsigned int outCount = 0;
        objc_property_t *properties = class_copyPropertyList(c, &outCount);
        
        // 2. interate property list
        for (unsigned int i = 0; i < outCount; i++) {
            MJProperty *property = [MJProperty cachedPropertyWithProperty:properties[i]];
            // check allowed list
            if (allowedList.count && ![allowedList containsObject:property.name]) continue;
            // check ingored list
            if ([ignoredList containsObject:property.name]) continue;
            
            // filter out Foundation classes
            if ([MJFoundation isClassFromFoundation:property.srcClass]) continue;
            // filter out NSObject default properties `hash`, `superclass`, `description`, `debugDescription`
            if ([MJFoundation isFromNSObjectProtocolProperty:property.name]) continue;
            // only 2 ways to set value modifier flag to true
            // 1. old2NewList exists and contains specific value
            // 2. old2NewList does not exist (that would be allowed but converting speed will be slower.)
            if ([old2NewList containsObject:property.name]
                || !old2NewList.count) {
                property->hasValueModifier = YES;
            }
            
            id key = property.name;
            // Modify replaced key using special method
            if (hasKeyReplacementModifier) {
                key = [cls mj_replacedKeyFromPropertyName121:key] ?: key;
            }
            // serch key in replaced dictionary
            key = replacedKeys[property.name] ?: key;
            
            property.srcClass = c;
            // handle keypath / keypath array / keypath array(with subkey)
            [property handleOriginKey:key];
            // handle generic class
            id clazz = genericClasses[property.name];
            if ([clazz isKindOfClass:[NSString class]]) {
                clazz = NSClassFromString(clazz);
            }
            property.classInArray = clazz;
            
            [allProperties addObject:property];
        }
        
        // 3. release the memory
        free(properties);
    }];
    
    return allProperties.copy;
}

- (void)setNeedsUpdate {
    _needsUpdate = YES;
}

always_inline void MJEAddSelectorResult2Set(Class cls, SEL selector, NSMutableSet *set) {
    if ([cls respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSArray *result = [cls performSelector:selector];
#pragma clang diagnostic pop
        if (result) {
            [set addObjectsFromArray:result];
        }
    }
}

always_inline void MJEAddSelectorResult2Dictionary(Class cls, SEL selector, NSMutableDictionary *dictionary) {
    if ([cls respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSDictionary *result = [cls performSelector:selector];
#pragma clang diagnostic pop
        if (result) {
            [dictionary addEntriesFromDictionary:result];
        }
    }
}

@end
