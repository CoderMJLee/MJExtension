
#ifndef __MJConst__H__
#define __MJConst__H__

#import <Foundation/Foundation.h>

// 过期
#define MJDeprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

#ifdef DEBUG  // 调试状态
// 打开LOG功能
#define MJLog(...) NSLog(__VA_ARGS__)
#else // 发布状态
// 关闭LOG功能
#define MJLog(...)
#endif

// 构建错误
#define MJBuildError(error, msg) \
if (error) *error = [NSError errorWithDomain:msg code:250 userInfo:nil];

/**
 * 断言
 * @param condition   条件
 * @param returnValue 返回值
 */
#define MJAssertError(condition, returnValue, error, msg) \
if ((condition) == NO) { \
    MJBuildError(error, msg); \
    return returnValue;\
}

#define MJAssert2(condition, returnValue) \
if ((condition) == NO) return returnValue;

/**
 * 断言
 * @param condition   条件
 */
#define MJAssert(condition) MJAssert2(condition, )

/**
 * 断言
 * @param param         参数
 * @param returnValue   返回值
 */
#define MJAssertParamNotNil2(param, returnValue) \
MJAssert2((param) != nil, returnValue)

/**
 * 断言
 * @param param   参数
 */
#define MJAssertParamNotNil(param) MJAssertParamNotNil2(param, )

/**
 * 打印所有的属性
 */
#define MJLogAllIvars \
-(NSString *)description \
{ \
    return [self keyValues].description; \
}

/**
 *  类型（属性类型）
 */
extern NSString *const MJTypeInt;
extern NSString *const MJTypeFloat;
extern NSString *const MJTypeDouble;
extern NSString *const MJTypeLong;
extern NSString *const MJTypeLongLong;
extern NSString *const MJTypeChar;
extern NSString *const MJTypeBOOL;
extern NSString *const MJTypePointer;

extern NSString *const MJTypeIvar;
extern NSString *const MJTypeMethod;
extern NSString *const MJTypeBlock;
extern NSString *const MJTypeClass;
extern NSString *const MJTypeSEL;
extern NSString *const MJTypeId;

#endif