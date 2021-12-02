//
//  MJEClass.h
//  MJExtension
//
//  Created by Frank on 2021/12/1.
//  Copyright © 2021 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MJProperty;
@interface MJEClass : NSObject {
    @package
    NSArray<MJProperty *> *_allProperties;
    NSArray<MJProperty *> * _Nullable _allCodingProperties;
    
    NSArray<MJProperty *> * _Nullable _allProperties2KeyValues;
    
    BOOL _hasOld2NewModifier;
    BOOL _hasLocaleModifier;
    BOOL _hasDictionary2ObjectModifier;
    BOOL _hasObject2DictionaryModifier;
    BOOL _hasClassModifier;
    
    BOOL _needsUpdate;
}

- (void)setNeedsUpdate;

/// Return the `cacehd` class
/// @param cls given Class for pre-conditioning.
+ (nullable instancetype)cachedClass:(nullable Class)cls;

/// Create a new MJEClass.
/// @param cls given Class for pre-conditioning.
- (nullable instancetype)initWithClass:(nullable Class)cls NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
