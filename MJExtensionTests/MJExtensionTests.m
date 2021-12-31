//
//  MJExtensionTests.m
//  MJExtensionTests
//
//  Created by Frank on 2019/3/25.
//  Copyright © 2019 MJExtension. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MJUser.h"
#import "MJAd.h"
#import "MJStatus.h"
#import "MJStudent.h"
#import "MJStatusResult.h"
#import "MJBag.h"
#import "MJDog.h"
#import "MJBook.h"
#import "MJBox.h"
#import <CoreData/CoreData.h>
#import "MJFrenchUser.h"
#import "MJCat.h"
#import <MJExtensionTests-Swift.h>
#import "MJPerson.h"

@interface MJExtensionTests : XCTestCase

@end

@implementation MJExtensionTests

#pragma mark 类型不匹配类型 -> 模型
- (void)testJSON2ModelUnmatched {
    // 1.定义一个字典
    NSDictionary *dict = @{
                           @"name" : @[],
                           @"icon" : @"lufy.png",
                           @"age" : @"2147483647",
                           @"age2": @"4294967295",
                           @"height" : @1.55,
                           @"money" : @"100.7777777",
                           @"sex" : @(SexFemale),
                           @"gay" : @"1",
                           @"speed" : @"120.5",
                           @"identifier" : @"9223372036854775807",
                           @"identifier2" : @"18446744073709551615",
                           @"price" : @"20.3",
                           @"rich" : @"2",
                           @"collect" : @"40个",
                           @"alien": @"yr Joking"
                           };
    
    // 2.将字典转为MJUser模型
    MJUser *user = [MJUser mj_objectWithKeyValues:dict];
    
    // 3.检测
    XCTAssert(!user.name);
    XCTAssert([user.icon isEqual:@"lufy.png"]);
    XCTAssert(user.age == INT_MAX);
    XCTAssert(user.age2 == UINT_MAX);
    XCTAssert([user.height isEqualToNumber:@(1.55)]);
    XCTAssert([user.money compare:[NSDecimalNumber decimalNumberWithString:@"100.7777777"]] == NSOrderedSame);
    XCTAssert(user.sex == SexFemale);
    XCTAssert(user.gay);
    XCTAssert(user.speed == 120);
    XCTAssert(user.identifier == LONG_LONG_MAX);
    XCTAssert(user.identifier2 == ULONG_LONG_MAX);
    XCTAssert(user.price == 20.3);
    XCTAssert(user.rich);
    XCTAssert(user.collect == 40);
    XCTAssert(!user.alien);
}

#pragma mark 简单的字典 -> 模型
- (void)testJSON2Model {
    // 1.定义一个字典
    NSDictionary *dict = @{
                           @"name" : @"Jack",
                           @"icon" : @"lufy.png",
                           @"age" : @"2147483647",
                           @"age2": @"4294967295",
                           @"height" : @1.55,
                           @"money" : @"100.7777777",
                           @"sex" : @(SexFemale),
                           @"gay" : @"1",
                           @"speed" : @"120.5",
                           @"identifier" : @"9223372036854775807",
                           @"identifier2" : @"18446744073709551615",
                           @"price" : @"20.3",
                           @"rich" : @"2",
                           @"collect" : @"40个",
                           @"alien": @"yr Joking"
                           };
    
    // 2.将字典转为MJUser模型
    MJUser *user = [MJUser mj_objectWithKeyValues:dict];
    
    // 3.检测
    XCTAssert([user.name isEqual:@"Jack"]);
    XCTAssert([user.icon isEqual:@"lufy.png"]);
    XCTAssert(user.age == INT_MAX);
    XCTAssert(user.age2 == UINT_MAX);
    XCTAssert([user.height isEqualToNumber:@(1.55)]);
    XCTAssert([user.money compare:[NSDecimalNumber decimalNumberWithString:@"100.7777777"]] == NSOrderedSame);
    XCTAssert(user.sex == SexFemale);
    XCTAssert(user.gay);
    XCTAssert(user.speed == 120);
    XCTAssert(user.identifier == LONG_LONG_MAX);
    XCTAssert(user.identifier2 == ULONG_LONG_MAX);
    XCTAssert(user.price == 20.3);
    XCTAssert(user.rich);
    XCTAssert(user.collect == 40);
    XCTAssert(!user.alien);
}
// 特殊模型, 数字为法语逗号为小数点的分隔符情况
- (void)testJSON2NumberModel {
    // 1.定义一个字典
    NSDictionary *dict = @{
                           @"age" : @"20",
                           @"height" : @1.55,
                           @"money" : @"100,9",
                           @"gay" : @"",
                           @"speed" : @"120,5",
                           @"identifier" : @"3443623624362",
                           @"price" : @"20,313422212",
                           @"like" : @"20个",
                           @"collect" : @"收藏5",
                           @"rich" : @"hehe",
                           @"money_longDouble": @"120,5",
                           @"cls": NSNull.null
                           };
    
    // 2.将字典转为MJFrenchUser模型
    MJFrenchUser *user = [MJFrenchUser mj_objectWithKeyValues:dict];
    
    XCTAssert(user.age == 20);
    XCTAssert(user.height.doubleValue == 1.55);
    XCTAssert(user.money.doubleValue == 100.9);
    XCTAssert(user.gay == NO);
    XCTAssert(user.speed == 120);
    XCTAssert(user.identifier == 3443623624362);
    XCTAssert(user.price == (double)20.313422212);
    XCTAssert(user.like == 20);
    XCTAssert(user.collect == 0);
    XCTAssert(user.rich == NO);
    XCTAssertEqual(user.money_longDouble, 120.5);
}

#pragma mark JSON字符串 -> 模型
- (void)testJSONString2Model {
    // 1.定义一个JSON字符串
    NSString *jsonString = @"{\"name\":\"Jack\", \"icon\":\"lufy.png\", \"age\":20, \"height\":333333.7, \"size.width\":55}";
    
    // 2.将JSON字符串转为MJUser模型
    MJUser *user = [MJUser mj_objectWithKeyValues:jsonString];
    
    // 3.检测
    XCTAssert([user.name isEqual:@"Jack"]);
    XCTAssert([user.icon isEqual:@"lufy.png"]);
    XCTAssert(user.age == 20);
    XCTAssert(user.height.doubleValue == 333333.7);
    XCTAssert(user.speed == 55, "带点的特殊 key 解析失败");
}

#pragma mark 复杂的字典 -> 模型 (模型里面包含了模型)
- (void)testNestedModel {
    // 1.定义一个字典
    NSDictionary *dict = @{
                           @"text" : @"是啊，今天天气确实不错！",
                           
                           @"user" : @{
                                   @"name" : @"Jack",
                                   @"icon" : @"lufy.png"
                                   },
                           
                           @"retweetedStatus" : @{
                                   @"text" : @"今天天气真不错！",
                                   
                                   @"user" : @{
                                           @"name" : @"Rose",
                                           @"icon" : @"nami.png"
                                           }
                                   }
                           };
    
    // 2.将字典转为Status模型
    MJStatus *status = [MJStatus mj_objectWithKeyValues:dict];
    
    // 3.检测status的属性
    NSString *text = status.text;
    NSString *name = status.user.name;
    NSString *icon = status.user.icon;
    XCTAssert([text isEqual:@"是啊，今天天气确实不错！"]);
    XCTAssert([name isEqual:@"Jack"]);
    XCTAssert([icon isEqual:@"lufy.png"]);
    
    // 4.检测status.retweetedStatus的属性
    NSString *text2 = status.retweetedStatus.text;
    NSString *name2 = status.retweetedStatus.user.name;
    NSString *icon2 = status.retweetedStatus.user.icon;
    XCTAssert([text2 isEqual:@"今天天气真不错！"]);
    XCTAssert([name2 isEqual:@"Rose"]);
    XCTAssert([icon2 isEqual:@"nami.png"]);
}

#pragma mark 复杂的字典 -> 模型 (模型的数组属性里面又装着模型)
- (void)testNestedModelArray {
    // 1.定义一个字典
    NSDictionary *dict = @{
                           @"statuses" : @[
                                   @{
                                       @"text" : @"今天天气真不错！",
                                       
                                       @"user" : @{
                                               @"name" : @"Rose",
                                               @"icon" : @"nami.png"
                                               }
                                       },
                                   
                                   @{
                                       @"text" : @"明天去旅游了",
                                       
                                       @"user" : @{
                                               @"name" : @"Jack",
                                               @"icon" : @"lufy.png"
                                               }
                                       }
                                   
                                   ],
                           
                           @"ads" : @[
                                   @{
                                       @"image" : @"ad01.png",
                                       @"url" : @"http://www.ad01.com"
                                       },
                                   @{
                                       @"image" : @"ad02.png",
                                       @"url" : @"http://www.ad02.com"
                                       }
                                   ],
                           
                           @"totalNumber" : @"2014",
                           @"previousCursor" : @"13476589",
                           @"nextCursor" : @"13476599"
                           };
    
    // 2.将字典转为MJStatusResult模型
    MJStatusResult *result = [MJStatusResult mj_objectWithKeyValues:dict];
    
    // 3.检测MJStatusResult模型的简单属性
    XCTAssert(result.totalNumber.intValue == 2014);
    XCTAssert(result.previousCursor == 13476589);
    XCTAssert(result.nextCursor == 13476599);
    
    // 4.检测statuses数组中的模型属性
    XCTAssert([result.statuses[0].text isEqual:@"今天天气真不错！"]);
    XCTAssert([result.statuses[0].user.name isEqual:@"Rose"]);
    XCTAssert([result.statuses[0].user.icon isEqual:@"nami.png"]);
    
    XCTAssert([result.statuses[1].text isEqual:@"明天去旅游了"]);
    XCTAssert([result.statuses[1].user.name isEqual:@"Jack"]);
    XCTAssert([result.statuses[1].user.icon isEqual:@"lufy.png"]);
    
    // 5.检测ads数组中的模型属性
    XCTAssert([result.ads[0].image isEqual:@"ad01.png"]);
    XCTAssert([result.ads[0].url.absoluteString isEqual:@"http://www.ad01.com"]);
    XCTAssert([result.ads[1].image isEqual:@"ad02.png"]);
    XCTAssert([result.ads[1].url.absoluteString isEqual:@"http://www.ad02.com"]);
}

#pragma mark KeyMapping
// key替换，比如ID和id。多级映射，比如 oldName 和 name.oldName
- (void)testKeyMapping {
    // 1.定义一个字典
    NSDictionary *dict = @{
                           @"id" : @"20",
                           @"desciption" : @"好孩子",
                           @"name" : @{
                                   @"newName" : @"lufy",
                                   @"oldName" : @"kitty",
                                   @"info" : @[
                                           @"test-data",
                                           @{@"nameChangedTime" : @"2013-08-07"}
                                           ]
                                   },
                           @"other" : @{
                                   @"bag" : @{
                                           @"name" : @"小书包",
                                           @"price" : @100.7
                                           }
                                   }
                           };
    
    // 2.将字典转为MJStudent模型
    MJStudent *stu = [MJStudent mj_objectWithKeyValues:dict];
    
    // 3.检测MJStudent模型的属性
    XCTAssert([stu.ID isEqual:@"20"]);
    XCTAssert([stu.desc isEqual:@"好孩子"]);
    XCTAssert([stu.otherName isEqual:@"lufy"]);
    XCTAssert([stu.nowName isEqual:@"lufy"]);
    XCTAssert([stu.oldName isEqual:@"kitty"]);
    XCTAssert([stu.nameChangedTime isEqual:@"2013-08-07"]);
    XCTAssert([stu.bag.name isEqual:@"小书包"]);
    XCTAssert(stu.bag.price == 100.7);
}

#pragma mark 字典数组 -> 模型数组
- (void)testJSONArray2ModelArray {
    // 1.定义一个字典数组
    NSArray *dictArray = @[
                           @{
                               @"name" : @"Jack",
                               @"icon" : @"lufy.png",
                               },
                           @{
                               @"name" : @"Rose",
                               @"icon" : @"nami.png",
                               }
                           ];
    
    // 2.将字典数组转为MJUser模型数组
    NSArray<MJUser *> *users = [MJUser mj_objectArrayWithKeyValuesArray:dictArray];
    
    // 3.检测users数组中的MJUser模型属性
    XCTAssert([users[0].name isEqual:@"Jack"]);
    XCTAssert([users[0].icon isEqual:@"lufy.png"]);
    XCTAssert([users[1].name isEqual:@"Rose"]);
    XCTAssert([users[1].icon isEqual:@"nami.png"]);
}

#pragma mark 模型 -> 字典
- (void)testModel2JSON {
    // 1.新建模型
    MJUser *user = [[MJUser alloc] init];
    user.name = @"Jack";
    user.icon = @"lufy.png";
    
    MJStatus *status = [[MJStatus alloc] init];
    status.user = user;
    status.text = @"今天的心情不错！";
    
    // 2.将模型转为字典
    NSDictionary *statusDict = status.mj_keyValues;
    MJExtensionLog(@"%@", statusDict);
    
    MJExtensionLog(@"%@", [status mj_keyValuesWithKeys:@[@"text"]]);
    
    // 3.新建多级映射的模型
    MJStudent *stu = [[MJStudent alloc] init];
    stu.ID = @"123";
    stu.oldName = @"rose";
    stu.nowName = @"jack";
    stu.desc = @"handsome";
    stu.nameChangedTime = @"2018-09-08";
    stu.books = @[@"Good book", @"Red book"];
    stu.isAthlete = YES;
    
    MJBag *bag = [[MJBag alloc] init];
    bag.name = @"小书包";
    bag.price = 205;
    stu.bag = bag;
    
    NSDictionary *stuDict = stu.mj_keyValues;
    MJExtensionLog(@"%@", stuDict);
    MJExtensionLog(@"%@", [stu mj_keyValuesWithIgnoredKeys:@[@"bag", @"oldName", @"nowName"]]);
    MJExtensionLog(@"%@", stu.mj_JSONString);
    
    [MJStudent mj_referenceReplacedKeyWhenCreatingKeyValues:NO];
    MJExtensionLog(@"\n模型转字典时，字典的key参考replacedKeyFromPropertyName等方法:\n%@", stu.mj_keyValues);
}

#pragma mark 模型数组 -> 字典数组
- (void)testModelArray2JSONArray {
    // 1.新建模型数组
    MJUser *user1 = [[MJUser alloc] init];
    user1.name = @"Jack";
    user1.icon = @"lufy.png";
    
    MJUser *user2 = [[MJUser alloc] init];
    user2.name = @"Rose";
    user2.icon = @"nami.png";
    NSArray *userArray = @[user1, user2];
    
    // 2.将模型数组转为字典数组
    NSArray *dictArray = [MJUser mj_keyValuesArrayWithObjectArray:userArray];
    MJExtensionLog(@"%@", dictArray);
}

#pragma mark NSNull相关的测试
- (void)testNull {
    NSNull *null = [NSNull null];
    id obj2 = [null mj_keyValues];
    MJExtensionLog(@"%@", obj2);
    
    MJUser *user1 = [[MJUser alloc] init];
    user1.name = @"user1";
    MJUser *user2 = [[MJUser alloc] init];
    user2.name = @"user2";
    NSArray *users = @[user1, [NSNull null], user2];
    NSArray *usersDictArr = [MJUser mj_keyValuesArrayWithObjectArray:users];
    MJExtensionLog(@"%@", usersDictArr);
    NSString *str = [usersDictArr mj_JSONObject];
    MJExtensionLog(@"%@", str);
    
    
    NSArray *dictArray = @[
                           @{
                               @"name" : @"Jack",
                               @"icon" : @"lufy.png",
                               },
                           [NSNull null],
                           @{
                               @"name" : @"Rose",
                               @"icon" : @"nami.png",
                               }
                           ];
    
    NSArray *userArray = [MJUser mj_objectArrayWithKeyValuesArray:dictArray];
    MJExtensionLog(@"%@", userArray);
    
    
    NSDictionary *dic = @{
                          @"name": [NSNull null],
                          @"icon": @"lufy.png"
                          };
    MJUser *testNull = [MJUser mj_objectWithKeyValues:dic];
    MJExtensionLog(@"%@", testNull);
    
    
    NSDictionary *catDict = @{
        @"name": @"Tom",
        @"address": [NSNull null],
        @"nicknames": @[
                @"Jerry's Heart",
                [NSNull null],
                @"Cowboy Tom",
        ]
    };
    MJCat *cat = [MJCat mj_objectWithKeyValues:catDict];
    MJExtensionLog(@"%@", cat);
}

#pragma mark NSCoding示例
- (void)testCoding {
    // 创建模型
    MJBag *bag = [[MJBag alloc] init];
    bag.name = @"Red bag";
    bag.price = 200.8;
    bag.isBig = YES;
    bag.weight = 200;
    
    NSString *file = [NSTemporaryDirectory() stringByAppendingPathComponent:@"bag.data"];
    
    NSError *error = nil;
    // 归档
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:bag requiringSecureCoding:YES error:&error];
    BOOL isFinished = [data writeToFile:file atomically:true];
    XCTAssertNil(error);
    XCTAssert(isFinished);

    // 解档
    NSData *readData = [NSFileManager.defaultManager contentsAtPath:file];
    error = nil;
    MJBag *decodedBag = [NSKeyedUnarchiver unarchivedObjectOfClass:MJBag.class fromData:readData error:&error];
    // name has been ignored
    XCTAssertNotEqual(decodedBag.name, bag.name);
    XCTAssertNil(decodedBag.name);
    XCTAssert(decodedBag.price == bag.price);
    XCTAssertEqual(decodedBag.isBig, bag.isBig);
    XCTAssert(decodedBag.weight == bag.weight);
}

- (void)testCodingModelArrayProperty {
    // 有 NSArray 属性 模型
    MJPerson *person = [[MJPerson alloc] init];
    person.name = @"boy1";
    person.isVIP = YES;
    
    MJPerson *friend1 = [[MJPerson alloc] init];
    friend1.name = @"friend1";
    friend1.isVIP = YES;
    
    MJPerson *friend2 = [[MJPerson alloc] init];
    friend2.name = @"friend2";
    friend2.isVIP = NO;

    person.friends = @[friend1, friend2];
    person.books = @[@"book1", @"book2"];
    
    NSString *file = [NSTemporaryDirectory() stringByAppendingPathComponent:@"person.data"];
    NSError *error = nil;
    // 归档
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:person
                                         requiringSecureCoding:YES
                                                         error:&error];
    BOOL write = [data writeToFile:file atomically:true];
    XCTAssert(write);
    
    // 解档
    NSData *readData = [NSFileManager.defaultManager contentsAtPath:file];
    error = nil;
    MJPerson *decodedPerson = [NSKeyedUnarchiver unarchivedObjectOfClass:MJPerson.class
                                                                  fromData:readData
                                                                     error:&error];
    XCTAssert(decodedPerson.friends.count == 2);
    XCTAssert(decodedPerson.books.count == 2);
}

#pragma mark  统一转换属性名（比如驼峰转下划线）
- (void)testReplacedKeyFromPropertyName121 {
    // 1.定义一个字典
    NSDictionary *dict = @{
                           @"nick_name" : @"旺财",
                           @"sale_price" : @"10.5",
                           @"run_speed" : @"100.9"
                           };
    
    // 2.将字典转为MJUser模型
    MJDog *dog = [MJDog mj_objectWithKeyValues:dict];
    
    // 3.检测MJUser模型的属性
    XCTAssert([dog.nickName isEqual:@"旺财"]);
    XCTAssert(dog.salePrice == 10.5);
    XCTAssert(dog.runSpeed == (float)100.9);
}

#pragma mark 过滤字典的值（比如字符串日期处理为NSDate、字符串nil处理为@""）
- (void)testNewValueFromOldValue {
    // JSON -> Object
    // 1.定义一个字典
    NSDictionary *dict = @{
                           @"name" : @"5分钟突破iOS开发",
                           @"publishedTime" : @"2011-09-10",
                           @"box": @{
                               @"name": @"bee",
                               @"weight": @(15)
                           }
    };
    
    // 2.将字典转为MJUser模型
    MJBook *book = [MJBook mj_objectWithKeyValues:dict];
    
    // 3.检测MJUser模型的属性
    XCTAssert([book.name isEqual:@"5分钟突破iOS开发"]);
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    XCTAssert([[fmt stringFromDate:book.publishedTime] isEqual:@"2011-09-10"]);
    
    //Object -> JSON
    NSDictionary *bookDict = [book mj_keyValues];
    
    XCTAssert([bookDict[@"name"] isEqualToString:@"5分钟突破iOS开发"]);
    XCTAssert([bookDict[@"publishedTime"] isEqualToString:@"2011-09-10"]);
}

#pragma mark 使用MJExtensionLog打印模型的所有属性
- (void)testLogAllProperties {
    MJUser *user = [[MJUser alloc] init];
    user.name = @"MJ";
    user.age = 10;
    user.sex = SexMale;
    user.icon = @"test.png";
    
    MJExtensionLog(@"%@", user);
}

#pragma mark 测试含有 UIColor 的属性
- (void)testUIColorPropertyModel {
    NSDictionary *catDict = @{
        @"name": @"五更琉璃",
        @"address": [NSNull null],
        @"nicknames": @[
                @"黑猫",
                @"我老婆",
        ],
        @"color": @{
            @"systemColorName": @"blackColor"
        },
    };
    MJCat *cat = [MJCat mj_objectWithKeyValues:catDict];
    
    XCTAssertEqual(cat.name, catDict[@"name"]);
    XCTAssertNil(cat.address);
    XCTAssert(cat.nicknames.count == 2);
    // 这个 Color 是不能被正常当普通的 UIColor 使用的.
    XCTAssert(cat.color);
}

- (void)testUIColor2JSON {
    MJCat *ごこうるり = [[MJCat alloc] init];
    ごこうるり.name = @"五更瑠璃";
    ごこうるり.nicknames = @[@"黑猫", @"我老婆"];
    ごこうるり.color = UIColor.blackColor;
    
    NSDictionary *JSON = ごこうるり.mj_keyValues;
    XCTAssertEqual(JSON[@"name"], ごこうるり.name);
    XCTAssert(((NSArray *)JSON[@"nicknames"]).count == 2);
}

- (void)testUIColorCoding {
    // 创建模型
    MJCat *master = [[MJCat alloc] init];
    master.name = @"要变了";
    master.color = UIColor.whiteColor;
    master.nicknames = @[@"主人", @"陛下"];
    
    NSString *file = [NSTemporaryDirectory() stringByAppendingPathComponent:@" cat.data"];
    NSError *error = nil;
    // 归档
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:master requiringSecureCoding:YES error:&error];
    BOOL isFinished = [data writeToFile:file atomically:true];
    XCTAssertNil(error);
    XCTAssert(isFinished);

    // 解档
    NSData *readData = [NSFileManager.defaultManager contentsAtPath:file];
    error = nil;
    MJCat *decodedMaster = [NSKeyedUnarchiver unarchivedObjectOfClass:MJCat.class fromData:readData error:&error];
    XCTAssertNil(error);
    XCTAssert([decodedMaster.name isEqualToString:master.name]);
    XCTAssert(decodedMaster.nicknames.count == 2);
    XCTAssert(decodedMaster.color == master.color);
}
@end
