
#ifndef __MJExtensionConst__H__
#define __MJExtensionConst__H__

#import <Foundation/Foundation.h>

// 过期
#define MJExtensionDeprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

// 构建错误
#define MJExtensionBuildError(error, msg) \
if (error) *error = [NSError errorWithDomain:msg code:250 userInfo:nil];

/**
 * 断言
 * @param condition   条件
 * @param returnValue 返回值
 */
#define MJExtensionAssertError(condition, returnValue, error, msg) \
if ((condition) == NO) { \
    MJExtensionBuildError(error, msg); \
    return returnValue;\
}

#define MJExtensionAssert2(condition, returnValue) \
if ((condition) == NO) return returnValue;

/**
 * 断言
 * @param condition   条件
 */
#define MJExtensionAssert(condition) MJExtensionAssert2(condition, )

/**
 * 断言
 * @param param         参数
 * @param returnValue   返回值
 */
#define MJExtensionAssertParamNotNil2(param, returnValue) \
MJExtensionAssert2((param) != nil, returnValue)

/**
 * 断言
 * @param param   参数
 */
#define MJExtensionAssertParamNotNil(param) MJExtensionAssertParamNotNil2(param, )

/**
 * 打印所有的属性
 */
#define MJLogAllIvars \
-(NSString *)description \
{ \
    return [self keyValues].description; \
}
#define MJExtensionLogAllProperties MJLogAllIvars

/**
 *  类型（属性类型）
 */
extern NSString *const MJPropertyTypeInt;
extern NSString *const MJPropertyTypeShort;
extern NSString *const MJPropertyTypeFloat;
extern NSString *const MJPropertyTypeDouble;
extern NSString *const MJPropertyTypeLong;
extern NSString *const MJPropertyTypeLongLong;
extern NSString *const MJPropertyTypeChar;
extern NSString *const MJPropertyTypeBOOL1;
extern NSString *const MJPropertyTypeBOOL2;
extern NSString *const MJPropertyTypePointer;

extern NSString *const MJPropertyTypeIvar;
extern NSString *const MJPropertyTypeMethod;
extern NSString *const MJPropertyTypeBlock;
extern NSString *const MJPropertyTypeClass;
extern NSString *const MJPropertyTypeSEL;
extern NSString *const MJPropertyTypeId;

#endif