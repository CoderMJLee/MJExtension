#ifndef __MJConst__M__
#define __MJConst__M__

#import <Foundation/Foundation.h>

/**
 *  成员变量类型（属性类型）
 */
NSString *const MJTypeInt = @"i";
NSString *const MJTypeShort = @"s";
NSString *const MJTypeFloat = @"f";
NSString *const MJTypeDouble = @"d";
NSString *const MJTypeLong = @"q";
NSString *const MJTypeChar = @"c";
NSString *const MJTypeBOOL1 = @"c";
NSString *const MJTypeBOOL2 = @"b";
NSString *const MJTypePointer = @"*";

NSString *const MJTypeIvar = @"^{objc_ivar=}";
NSString *const MJTypeMethod = @"^{objc_method=}";
NSString *const MJTypeBlock = @"@?";
NSString *const MJTypeClass = @"#";
NSString *const MJTypeSEL = @":";
NSString *const MJTypeId = @"@";

#endif