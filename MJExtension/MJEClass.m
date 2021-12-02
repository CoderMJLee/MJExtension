//
//  MJEClass.m
//  MJExtension
//
//  Created by Frank on 2021/12/1.
//  Copyright © 2021 MJ Lee. All rights reserved.
//

#import "MJEClass.h"
#import "MJExtensionConst.h"
#import "MJKeyValue.h"
#import "MJFoundation.h"
#import "MJProperty.h"
#import "NSObject+MJProperty.h"
#import "NSObject+MJClass.h"


/// 遍历所有类的block（父类）
typedef void (^MJClassesEnumeration)(Class c, BOOL *stop);

/// 类相关的扩展
@interface NSObject (MJEClass)
/// 遍历所有的类
+ (void)mj_enumerateClasses:(MJClassesEnumeration)enumeration;
+ (void)mj_enumerateAllClasses:(MJClassesEnumeration)enumeration;

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

+ (void)mj_enumerateAllClasses:(MJClassesEnumeration)enumeration {
    if (enumeration == nil) return;
    BOOL stop = NO;
    Class c = self;
    while (c && !stop) {
        enumeration(c, &stop);
        c = class_getSuperclass(c);
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
        shouldAutoInheritFromSuper = [(id<MJKeyValue>)cls mj_shouldAutoInheritConfigurations];
    }
    
    NSMutableSet *ignoredList = [NSMutableSet new];
    NSMutableSet *allowedList = [NSMutableSet new];
    NSMutableDictionary *genericClasses = [NSMutableDictionary new];
    NSMutableDictionary *replacedKeys = [NSMutableDictionary new];
    
    Class currentClass = cls;
    while (1) {
        // get ignored property names
        if ([currentClass respondsToSelector:@selector(mj_ignoredPropertyNames)]) {
            NSArray *names = [(id<MJKeyValue>)currentClass mj_ignoredPropertyNames];
            if (names) {
                [ignoredList addObjectsFromArray:names];
            }
        }
        
        // get allowed property names
        if ([currentClass respondsToSelector:@selector(mj_allowedPropertyNames)]) {
            NSArray *names = [(id<MJKeyValue>)currentClass mj_allowedPropertyNames];
            if (names) {
                [allowedList addObjectsFromArray:names];
            }
        }
        
        // get generic classes
        if ([currentClass respondsToSelector:@selector(mj_objectClassInArray)]) {
            NSDictionary *classArr = [(id<MJKeyValue>)currentClass mj_objectClassInArray];
            if (classArr) {
                [genericClasses addEntriesFromDictionary:classArr];
            }
        }
        
        // get replaced keys
        if ([currentClass respondsToSelector:@selector(mj_replacedKeyFromPropertyName)]) {
            NSDictionary *keys = [(id<MJKeyValue>)currentClass mj_replacedKeyFromPropertyName];
            if (keys) {
                [replacedKeys addEntriesFromDictionary:keys];
            }
        }
        
        if (!shouldAutoInheritFromSuper) break;
        
        Class superClass = class_getSuperclass(currentClass);
        // current class is root class (NSObject / NSProxy)
        if (currentClass && !superClass) break;
        currentClass = superClass;
    }
    
    // Check replacing modifier
    BOOL hasReplacingModifier = [cls respondsToSelector:@selector(mj_replacedKeyFromPropertyName121:)];
    // get the property list
    _allProperties = [self
                      mj_allPropertiesWithAllowedList:allowedList
                      ignoredList:ignoredList
                      genericClasses:genericClasses
                      replacedKeys:replacedKeys
                      hasReplacingModifier:hasReplacingModifier
                      inClass:cls];
    
    _hasLocaleModifier = [cls respondsToSelector:@selector(mj_numberLocale)];
    _hasOld2NewModifier = [cls respondsToSelector:@selector(mj_newValueFromOldValue:property:)];
    // TODO: 4.0.0 new feature
//    _hasClassModifier = [
    _hasDictionary2ObjectModifier = [cls respondsToSelector:@selector(mj_didConvertToObjectWithKeyValues:)];
    _hasObject2DictionaryModifier = [cls respondsToSelector:@selector(mj_objectDidConvertToKeyValues:)];
    
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
    // uses 1 lock to avoid concurrent operation.
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
                                            genericClasses:(NSDictionary *)genericClasses
                                              replacedKeys:(NSDictionary *)replacedKeys
                                      hasReplacingModifier:(BOOL)hasReplacingModifier
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
            
            id key = property.name;
            // Modify replaced key using special method
            if (hasReplacingModifier) {
                key = [cls mj_replacedKeyFromPropertyName121:key] ?: key;
            }
            // serch key in replaced keys
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

@end
