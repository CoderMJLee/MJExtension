//
//  MJType.m
//  MJExtension
//
//  Created by mj on 14-1-15.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import "MJType.h"
#import "MJExtension.h"
#import "MJFoundation.h"
#import "MJConst.h"

@implementation MJType

static NSMutableDictionary *_cachedTypes;
+ (void)load
{
    _cachedTypes = [NSMutableDictionary dictionary];
}

+ (instancetype)cachedTypeWithCode:(NSString *)code
{
    MJAssertParamNotNil2(code, nil);
    
    MJType *type = _cachedTypes[code];
    if (type == nil) {
        type = [[self alloc] init];
        type.code = code;
        _cachedTypes[code] = type;
    }
    return type;
}

- (void)setCode:(NSString *)code
{
    _code = code;
    
    MJAssertParamNotNil(code);
    
    if ([code isEqualToString:MJTypeId]) {
        _idType = YES;
    } else if (code.length == 0) {
        _KVCDisabled = YES;
    } else if (code.length > 3 && [code hasPrefix:@"@\""]) {
        // 去掉@"和"，截取中间的类型名称
        _code = [code substringWithRange:NSMakeRange(2, code.length - 3)];
        _typeClass = NSClassFromString(_code);
        _fromFoundation = [MJFoundation isClassFromFoundation:_typeClass];
        _numberType = (_typeClass == [NSNumber class] || [_typeClass isSubclassOfClass:[NSNumber class]]);
    } else if ([code isEqualToString:MJTypeSEL] ||
               [code isEqualToString:MJTypeIvar] ||
               [code isEqualToString:MJTypeMethod]) {
        _KVCDisabled = YES;
    }
    
    // 是否为数字类型
    NSString *lowerCode = _code.lowercaseString;
    NSArray *numberTypes = @[MJTypeInt, MJTypeShort, MJTypeBOOL1, MJTypeBOOL2, MJTypeFloat, MJTypeDouble, MJTypeLong, MJTypeChar];
    if ([numberTypes containsObject:lowerCode]) {
        _numberType = YES;
        
        if ([lowerCode isEqualToString:MJTypeBOOL1]
            || [lowerCode isEqualToString:MJTypeBOOL2]) {
            _boolType = YES;
        }
    }
}
@end
