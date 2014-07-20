
#ifndef __MJConst__H__
#define __MJConst__H__

#ifdef DEBUG  // 调试状态
// 打开LOG功能
#define MJLog(...) NSLog(__VA_ARGS__)
// 打开断言功能
#define MJAssert(condition, desc) NSAssert(condition, @"\n报错文件：%@\n报错行数：第%d行\n报错方法：%s\n错误描述：%@", [NSString stringWithUTF8String:__FILE__], __LINE__,  __FUNCTION__, desc)
#define MJAssertParamNotNil(param) MJAssert(param, [[NSString stringWithFormat:@#param] stringByAppendingString:@"参数不能为nil"])
#else // 发布状态
// 关闭LOG功能
#define MJLog(...)
// 关闭断言功能
#define MJAssert(condition, desc)
#define MJAssertParamNotNil(param)
#endif

// 颜色
#define MJColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

// 随机色
#define MJRandomColor MJColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

#endif