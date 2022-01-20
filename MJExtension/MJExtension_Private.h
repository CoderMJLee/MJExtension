//
//  MJExtension_Private.h
//  MJExtension
//
//  Created by Frank on 2022/1/3.
//  Copyright © 2022 MJ Lee. All rights reserved.
//
#import "MJProperty.h"

#ifndef MJExtension_Private_h
#define MJExtension_Private_h

NS_ASSUME_NONNULL_BEGIN
@interface NSString (MJExtension_Private)

@property (nonatomic, readonly) SEL mj_defaultSetter;

@end

@class MJPropertyKey;
@interface NSString (MJPropertyKey)

///  If JSON key is "xxx.xxx", so add one more key for it.
- (MJPropertyKey *)propertyKey;

/// Create keys with dot form, which is splitted by dot.
- (NSArray<MJPropertyKey *> *)mj_multiKeys;

@end

@interface NSObject(MJExtension_Private)

BOOL MJE_isFromFoundation(Class cls);

// Special dealing method. `value` should be NSString or NSNumber
+ (nullable NSNumber *)mj_numberWithValue:(nullable id)value
                            type:(MJEPropertyType)type
                          locale:(nullable NSLocale *)locale;

@end
NS_ASSUME_NONNULL_END
#endif /* MJExtension_Private_h */
