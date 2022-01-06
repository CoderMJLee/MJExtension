
#ifndef __MJExtensionPredefine__H__
#define __MJExtensionPredefine__H__

#import <Foundation/Foundation.h>

#import <objc/message.h>
#ifndef mj_msgSendOne
#define mj_msgSendOne(obj, sel, type, value) ((void (*)(id, SEL, type))objc_msgSend)(obj, sel, value)
#endif
#ifndef mj_msgSendGet
#define mj_msgSendGet(obj, sel, type) (((type (*)(id, SEL))objc_msgSend)(obj, sel))
#endif

#ifndef MJ_LOCK
#define MJ_LOCK(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#endif

#ifndef MJ_UNLOCK
#define MJ_UNLOCK(lock) dispatch_semaphore_signal(lock);
#endif

// 过期
#define MJE_API_Deprecated(instead) API_DEPRECATED(instead, ios(2.0, 4.0))

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
- (NSString *)description \
{ \
    return [self.mj_JSONObject description]; \
}
#define MJExtensionLogAllProperties MJLogAllIvars

/** 仅在 Debugger 展示所有的属性 */
#define MJImplementDebugDescription \
- (NSString *)debugDescription \
{ \
return [self.mj_JSONObject description]; \
}

#endif
