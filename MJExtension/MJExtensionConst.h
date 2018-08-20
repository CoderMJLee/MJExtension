
#ifndef __MJExtensionConst__H__
#define __MJExtensionConst__H__

#import <Foundation/Foundation.h>

// 信号量
#define MJExtensionSemaphoreCreate \
static dispatch_semaphore_t signalSemaphore; \
static dispatch_once_t onceTokenSemaphore; \
dispatch_once(&onceTokenSemaphore, ^{ \
    signalSemaphore = dispatch_semaphore_create(1); \
});

#define MJExtensionSemaphoreWait \
dispatch_semaphore_wait(signalSemaphore, DISPATCH_TIME_FOREVER);

#define MJExtensionSemaphoreSignal \
dispatch_semaphore_signal(signalSemaphore);

// 过期
#define MJExtensionDeprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

// 构建错误
#define MJExtensionBuildError(clazz, msg) \
NSError *error = [NSError errorWithDomain:msg code:250 userInfo:nil]; \
[clazz setMj_error:error];

// 日志输出
#ifdef DEBUG
#define MJExtensionLog(...) NSLog(__VA_ARGS__)
#else
#define MJExtensionLog(...)
#endif

/**
 * 断言
 * @param condition   条件
 * @param returnValue 返回值
 */
#define MJExtensionAssertError(condition, returnValue, clazz, msg) \
[clazz setMj_error:nil]; \
if ((condition) == NO) { \
    MJExtensionBuildError(clazz, msg); \
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
    return [self mj_keyValues].description; \
}
#define MJExtensionLogAllProperties MJLogAllIvars

/**
 *  类型（属性类型）
 */
extern NSString * _Nonnull const MJPropertyTypeInt;
extern NSString * _Nonnull const MJPropertyTypeShort;
extern NSString * _Nonnull const MJPropertyTypeFloat;
extern NSString * _Nonnull const MJPropertyTypeDouble;
extern NSString * _Nonnull const MJPropertyTypeLong;
extern NSString * _Nonnull const MJPropertyTypeLongLong;
extern NSString * _Nonnull const MJPropertyTypeChar;
extern NSString * _Nonnull const MJPropertyTypeBOOL1;
extern NSString * _Nonnull const MJPropertyTypeBOOL2;
extern NSString * _Nonnull const MJPropertyTypePointer;

extern NSString * _Nonnull const MJPropertyTypeIvar;
extern NSString * _Nonnull const MJPropertyTypeMethod;
extern NSString * _Nonnull const MJPropertyTypeBlock;
extern NSString * _Nonnull const MJPropertyTypeClass;
extern NSString * _Nonnull const MJPropertyTypeSEL;
extern NSString * _Nonnull const MJPropertyTypeId;

#endif
