//
//  MJType.m
//  MJExtension
//
//  Created by mj on 14-1-15.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "MJType.h"
#import "MJExtension.h"

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
    
    if (_code.length == 0 || [_code isEqualToString:MJTypeSEL] ||
        [_code isEqualToString:MJTypeIvar] ||
        [_code isEqualToString:MJTypeMethod]) {
        _KVCDisabled = YES;
    } else if ([_code hasPrefix:@"@"] && _code.length > 3) {
        // 去掉@"和"，截取中间的类型名称
        _code = [_code substringFromIndex:2];
        _code = [_code substringToIndex:_code.length - 1];
        _typeClass = NSClassFromString(_code);
        
        _fromFoundation = [_code hasPrefix:@"NS"];
    }
}

MJLogAllIvrs
@end
