//
//  MJEClass.h
//  MJExtension
//
//  Created by Frank on 2021/12/1.
//  Copyright © 2021 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@class MJProperty;
@interface MJEClass : NSObject {
    @package
    NSArray<MJProperty *> *_allProperties;
    NSArray<MJProperty *> * _Nullable _allCodingProperties;
    
    NSArray<MJProperty *> * _Nullable _allProperties2JSON;
    
    BOOL _hasOld2NewModifier;
    BOOL _hasDictionary2ObjectModifier;
    BOOL _hasObject2DictionaryModifier;
    
    BOOL _needsUpdate;
    /// = _allProperties.count
    NSInteger _propertiesCount;
    NSLocale * _Nullable _numberLocale;
    NSDateFormatter * _Nullable _dateFormatter;
    BOOL _shouldReferenceKeyReplacementInJSONExport;
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
