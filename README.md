MJExtension
===========
一、MJ友情提醒
-----------
 * MJExtension是一套“字典和模型之间互相转换”的轻量级框架(Conversion between JSON and modle)
 * MJExtension能完成的功能
  * 字典（JSON） --> 模型（model）
  * 模型（model） --> 字典（JSON）
  * 字典数组（JSON array） --> 模型数组（model array）
  * 模型数组（model array） --> 字典数组（JSON array）
 * 具体用法主要参考 main.m中各个函数 以及 "NSObject+MJKeyValue.h"
 * 希望各位大神能用得爽

二、部分API用法
-----------
 * 将字典的键值对转成模型属性
  * - (void)setKeyValues:(NSDictionary *)keyValues;

 * 将模型转成字典
  * - (NSDictionary *)keyValues;

 * 通过模型数组来创建一个字典数组
  * + (NSArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray;

 * 通过字典来创建一个模型
  * + (instancetype)objectWithKeyValues:(NSDictionary *)keyValues;

 * 通过plist来创建一个模型(仅限于mainBundle中的文件)
  * + (instancetype)objectWithFilename:(NSString *)filename;

 * 通过plist来创建一个模型
  * + (instancetype)objectWithFile:(NSString *)file;

 * 通过字典数组来创建一个模型数组
  * + (NSArray *)objectArrayWithKeyValuesArray:(NSArray *)keyValuesArray;

 * 通过plist来创建一个模型数组
  * + (NSArray *)objectArrayWithFilename:(NSString *)filename;

 * 通过plist来创建一个模型数组
  * + (NSArray *)objectArrayWithFile:(NSString *)file;
