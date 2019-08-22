//
//  MJExtensionTests.m
//  MJExtensionTests
//
//  Created by Frank on 2019/3/25.
//  Copyright © 2019 MJExtension. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "main.h"

@interface MJExtensionTests : XCTestCase

@end

@implementation MJExtensionTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    execute(keyValues2object, @"简单的字典 -> 模型");
    execute(keyValues2object1, @"JSON字符串 -> 模型");
    execute(keyValues2object2, @"复杂的字典 -> 模型 (模型里面包含了模型)");
    execute(keyValues2object3, @"复杂的字典 -> 模型 (模型的数组属性里面又装着模型)");
    execute(keyValues2object4, @"简单的字典 -> 模型（key替换，比如ID和id，支持多级映射）");
    execute(keyValuesArray2objectArray, @"字典数组 -> 模型数组");
    execute(object2keyValues, @"模型转字典");
    execute(objectArray2keyValuesArray, @"模型数组 -> 字典数组");
    execute(coreData, @"CoreData示例");
    execute(coding, @"NSCoding示例");
    execute(replacedKeyFromPropertyName121, @"统一转换属性名（比如驼峰转下划线）");
    execute(newValueFromOldValue, @"过滤字典的值（比如字符串日期处理为NSDate、字符串nil处理为@""）");
    execute(logAllProperties, @"使用MJExtensionLog打印模型的所有属性");
    execute(nullSituations, @"测试有关 Null 的情况");
}

@end
