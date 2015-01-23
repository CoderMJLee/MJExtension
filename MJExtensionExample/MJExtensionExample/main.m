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

/** main函数 */
int main(int argc, const char * argv[])
{
    @autoreleasepool {
        execute(keyValues2object, @"简单的字典 -> 模型");
        execute(keyValues2object2, @"复杂的字典 -> 模型 (模型里面包含了模型)");
        execute(keyValues2object3, @"复杂的字典 -> 模型 (模型的数组属性里面又装着模型)");
        execute(keyValues2object4, @"简单的字典 -> 模型（key替换，比如ID和id）");
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
                           };
    
    // 2.将字典转为User模型
    User *user = [User objectWithKeyValues:dict];
    
    // 3.打印User模型的属性
    NSLog(@"name=%@, icon=%@", user.name, user.icon);
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
                                       },
                                   
                                   @{
                                       @"text" : @"嘿嘿，这东西不错哦！",
                                       
                                       @"user" : @{
                                               @"name" : @"Jim",
                                               @"icon" : @"zero.png"
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
 * 简单的字典 -> 模型（key替换，比如ID和id）
 */
void keyValues2object4()
{
    // 1.定义一个字典
    NSDictionary *dict = @{
                           @"id" : @"20",
                           @"name" : @"lufy",
                           };
    
    // 2.将字典转为Student模型
    Student *stu = [Student objectWithKeyValues:dict];
    
    // 3.打印Student模型的属性
    NSLog(@"id=%@, name=%@", stu.ID, stu.name);
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
                               },
                           
                           @{
                               @"name" : @"Jim",
                               @"icon" : @"zero.png",
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
    //    NSDictionary *dict = [status keyValues];
    NSDictionary *dict = status.keyValues;
    NSLog(@"%@", dict);
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
    
    User *user3 = [[User alloc] init];
    user3.name = @"Jim";
    user3.icon = @"zero.png";
    
    NSArray *userArray = @[user1, user2, user3];
    
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