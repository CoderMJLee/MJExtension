//
//  MJType.m
//  MJExtension
//
//  Created by mj on 14-1-15.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "MJType.h"
#import "MJExtension.h"
#import "MJFoundation.h"
#import "MJConst.h"

@implementation MJType

- (instancetype)initWithCode:(NSString *)code
{
    if (self = [super init]) {
        self.code = code;
    }
    return self;
}

/** 类型标识符 */
- (void)setCode:(NSString *)code
{
    _code = code;
    
    MJAssertParamNotNil(code);
    
    if (code.length == 0 || [code isEqualToString:MJTypeSEL] ||
        [code isEqualToString:MJTypeIvar] ||
        [code isEqualToString:MJTypeMethod]) {
        _KVCDisabled = YES;
    } else if ([code hasPrefix:@"@"] && code.length > 3) {
        // 去掉@"和"，截取中间的类型名称
        _code = [code substringFromIndex:2];
        _code = [_code substringToIndex:_code.length - 1];
        _typeClass = NSClassFromString(_code);
        
        _fromFoundation = [MJFoundation isClassFromFoundation:_typeClass];
    }
}

MJLogAllIvrs
@end
