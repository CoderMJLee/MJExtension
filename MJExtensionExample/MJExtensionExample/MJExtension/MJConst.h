
#ifndef __MJConst__H__
#define __MJConst__H__

#ifdef DEBUG  // 调试状态
// 打开LOG功能
#define MJLog(...) NSLog(__VA_ARGS__)
#else // 发布状态
// 关闭LOG功能
#define MJLog(...)
#endif

// 断言
#define MJAssert2(condition, returnValue) \
if ((condition) == NO) return returnValue;

#define MJAssert(condition) MJAssert2(condition, )

#define MJAssertParamNotNil2(param, returnValue) \
MJAssert2(param != nil, returnValue)

#define MJAssertParamNotNil(param) MJAssertParamNotNil2(param, )

#endif