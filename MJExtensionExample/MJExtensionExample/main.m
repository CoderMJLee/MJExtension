//
//  main.m
//  字典与模型的互转
//
//  Created by MJ Lee on 14-5-21.
//  Copyright (c) 2014年 itcast. All rights reserved.
//
/**
 MJ友情提醒：
 1.MJExtension是一套“字典和模型之间互相转换”的轻量级框架
 2.MJExtension能完成的功能
 * 字典 --> 模型
 * 模型 --> 字典
 * 字典数组 --> 模型数组
 * 模型数组 --> 字典数组
 3.具体用法主要参考 main.m中各个函数 以及 "NSObject+MJKeyValue.h"
 4.希望各位大神能用得爽
 */

#import <Foundation/Foundation.h>
#import "main.h"
#import "MJExtension.h"
#import "User.h"
#import "Ad.h"
#import "Status.h"
#import "Student.h"
#import "StatusResult.h"
#import "Bag.h"
#import "Weather.h"

/** main函数 */
int main(int argc, const char * argv[])
{
    @autoreleasepool {
        execute(keyValues2object, @"简单的字典 -> 模型");
        execute(keyValues2object2, @"复杂的字典 -> 模型 (模型里面包含了模型)");
        execute(keyValues2object3, @"复杂的字典 -> 模型 (模型的数组属性里面又装着模型)");
        execute(keyValues2object4, @"简单的字典 -> 模型（key替换，比如ID和id，支持多级映射）");
        execute(keyValues2object5, @"复杂的字典 -> 模型 (模型的数组属性里面装着NSDictionary/NSNumber等Foundation数据类型)");
        execute(keyValuesArray2objectArray, @"字典数组 -> 模型数组");
        execute(object2keyValues, @"模型转字典");
        execute(objectArray2keyValuesArray, @"模型数组 -> 字典数组");
    }
    return 0;
}

/**
 *  简单的字典 -> 模型
 */
void keyValues2object()
{
    // 1.定义一个字典
    NSDictionary *dict = @{
                           @"name" : @"Jack",
                           @"icon" : @"lufy.png",
                           @"age" : @20,
                           @"height" : @1.55,
                           @"money" : @"100.9",
                           @"sex" : @(SexFemale),
                           @"gay" : @"1"
                           };

    // 2.将字典转为User模型
    User *user = [User objectWithKeyValues:dict];

    // 3.打印User模型的属性
    NSLog(@"name=%@, icon=%@, age=%d, height=%@, money=%@, sex=%d, gay=%d", user.name, user.icon, user.age, user.height, user.money, user.sex, user.gay);
}

/**
 *  复杂的字典 -> 模型 (模型里面包含了模型)
 */
void keyValues2object2()
{
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
    Status *status = [Status objectWithKeyValues:dict];

    // 3.打印status的属性
    NSString *text = status.text;
    NSString *name = status.user.name;
    NSString *icon = status.user.icon;
    NSLog(@"text=%@, name=%@, icon=%@", text, name, icon);

    // 4.打印status.retweetedStatus的属性
    NSString *text2 = status.retweetedStatus.text;
    NSString *name2 = status.retweetedStatus.user.name;
    NSString *icon2 = status.retweetedStatus.user.icon;
    NSLog(@"text2=%@, name2=%@, icon2=%@", text2, name2, icon2);
}

/**
 *  复杂的字典 -> 模型 (模型的数组属性里面又装着模型)
 */
void keyValues2object3()
{
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

    // 2.将字典转为StatusResult模型
    StatusResult *result = [StatusResult objectWithKeyValues:dict];

    // 3.打印StatusResult模型的简单属性
    NSLog(@"totalNumber=%@, previousCursor=%lld, nextCursor=%lld", result.totalNumber, result.previousCursor, result.nextCursor);

    // 4.打印statuses数组中的模型属性
    for (Status *status in result.statuses) {
        NSString *text = status.text;
        NSString *name = status.user.name;
        NSString *icon = status.user.icon;
        NSLog(@"text=%@, name=%@, icon=%@", text, name, icon);
    }

    // 5.打印ads数组中的模型属性
    for (Ad *ad in result.ads) {
        NSLog(@"image=%@, url=%@", ad.image, ad.url);
    }
}

/**
 * 简单的字典 -> 模型（key替换，比如ID和id。多级映射，比如 oldName 和 name.oldName）
 */
void keyValues2object4()
{
    // 1.定义一个字典
    NSDictionary *dict = @{
                           @"id" : @"20",
                           @"desciption" : @"好孩子",
                           @"name" : @{
                                @"newName" : @"lufy",
                                @"oldName" : @"kitty",
                                @"info" : @{
                                    @"nameChangedTime" : @"2013-08-07"
                                }
                           },
                           @"other" : @{
                                @"bag" : @{
                                    @"name" : @"小书包",
                                    @"price" : @100.7
                                }
                           }
                        };

    // 2.将字典转为Student模型
    Student *stu = [Student objectWithKeyValues:dict];

    // 3.打印Student模型的属性
    NSLog(@"ID=%@, desc=%@, oldName=%@, nowName=%@, nameChangedTime=%@",
          stu.ID, stu.desc, stu.oldName, stu.nowName, stu.nameChangedTime);
    NSLog(@"bagName=%@, bagPrice=%f",
          stu.bag.name, stu.bag.price);
}

/**
 *  复杂的字典 -> 模型 (模型的数组属性里面又装着模型)
 */
void keyValues2object5()
{
    // 1.定义一个字典
    NSDictionary *dict = @{
                           @"temperatures":@[ @(5.7), @(5.7), @(7.8), @(9.2) ,@(8.1), @(4.1), @(4.0), @(3.7)],
                           @"cloud":@[
                                   @{
                                       @"direction":@"西北",
                                       @"speed":@"1"
                                       },
                                   @{
                                       @"direction":@"西",
                                       @"speed":@"3"
                                       },
                                   @{
                                       @"direction":@"北",
                                       @"speed":@"1"
                                       }
                                      ]
                           };
    
    // 2.将字典转为StatusResult模型
    Weather *result = [Weather objectWithKeyValues:dict];
    
    for (NSNumber *temp in result.temperatures) {
        NSLog(@"%f", temp.floatValue);
    }
    
    for (NSDictionary *cloud in result.cloud) {
        NSLog(@"%@", cloud);
    }
}

/**
 *  字典数组 -> 模型数组
 */
void keyValuesArray2objectArray()
{
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
    
    // 2.将字典数组转为User模型数组
    NSArray *userArray = [User objectArrayWithKeyValuesArray:dictArray];
    
    // 3.打印userArray数组中的User模型属性
    for (User *user in userArray) {
        NSLog(@"name=%@, icon=%@", user.name, user.icon);
    }
}

/**
 *  模型 -> 字典
 */
void object2keyValues()
{
    // 1.新建模型
    User *user = [[User alloc] init];
    user.name = @"Jack";
    user.icon = @"lufy.png";
    
    Status *status = [[Status alloc] init];
    status.user = user;
    status.text = @"今天的心情不错！";
    
    // 2.将模型转为字典
    NSDictionary *statusDict = status.keyValues;
    NSLog(@"%@", statusDict);

    // 3.新建多级映射的模型
    Student *stu = [[Student alloc] init];
    stu.ID = @"123";
    stu.oldName = @"rose";
    stu.nowName = @"jack";
    stu.desc = @"handsome";
    stu.nameChangedTime = @"2018-09-08";
    
    Bag *bag = [[Bag alloc] init];
    bag.name = @"小书包";
    bag.price = 205;
    stu.bag = bag;
    
    NSDictionary *stuDict = stu.keyValues;
    NSLog(@"%@", stuDict);
}

/**
 *  模型数组 -> 字典数组
 */
void objectArray2keyValuesArray()
{
    // 1.新建模型数组
    User *user1 = [[User alloc] init];
    user1.name = @"Jack";
    user1.icon = @"lufy.png";
    
    User *user2 = [[User alloc] init];
    user2.name = @"Rose";
    user2.icon = @"nami.png";
    
    NSArray *userArray = @[user1, user2];
    
    // 2.将模型数组转为字典数组
    NSArray *dictArray = [User keyValuesArrayWithObjectArray:userArray];
    NSLog(@"%@", dictArray);
}

void execute(void (*fn)(), NSString *comment)
{
    NSLog(@"[******************%@******************开始]", comment);
    fn();
    NSLog(@"[******************%@******************结尾]\n ", comment);
}