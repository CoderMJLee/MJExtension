//
//  main.m
//  MJExtensionExample
//
//  Created by MJ Lee on 15/11/8.
//  Copyright © 2015年 小码哥. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "main.h"
#import "MJExtension.h"
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
#import "Platform.h"
#import "Games.h"


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
int main(int argc, char * argv[]) {
    @autoreleasepool {
        // 关于模型的具体配置可以参考：MJExtensionConfig.m
        // 或者参考每个模型的.m文件中被注释掉的配置
        
//        execute(keyValues2object, @"简单的字典 -> 模型");
//        execute(keyValues2object1, @"JSON字符串 -> 模型");
//        execute(keyValues2object2, @"复杂的字典 -> 模型 (模型里面包含了模型)");
//        execute(keyValues2object3, @"复杂的字典 -> 模型 (模型的数组属性里面又装着模型)");
//        execute(keyValues2object4, @"简单的字典 -> 模型（key替换，比如ID和id，支持多级映射）");
//        execute(keyValuesArray2objectArray, @"字典数组 -> 模型数组");
//        execute(object2keyValues, @"模型转字典");
//        execute(objectArray2keyValuesArray, @"模型数组 -> 字典数组");
        execute(coreData, @"CoreData示例");
        execute(coreData2, @"双向CoreData示例");
//        execute(coding, @"NSCoding示例");
//        execute(replacedKeyFromPropertyName121, @"统一转换属性名（比如驼峰转下划线）");
//        execute(newValueFromOldValue, @"过滤字典的值（比如字符串日期处理为NSDate、字符串nil处理为@""）");
//        execute(logAllProperties, @"使用MJExtensionLog打印模型的所有属性");
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
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
                           @"age" : @"20",
                           @"height" : @1.55,
                           @"money" : @"100.9",
                           @"sex" : @(SexFemale),
                           @"gay" : @"1"
                       //  @"gay" : @"NO"
                       //  @"gay" : @"true"
                           };
    
    // 2.将字典转为MJUser模型
    MJUser *user = [MJUser mj_objectWithKeyValues:dict];
    
    // 3.打印MJUser模型的属性
    MJExtensionLog(@"name=%@, icon=%@, age=%zd, height=%@, money=%@, sex=%d, gay=%d", user.name, user.icon, user.age, user.height, user.money, user.sex, user.gay);
}

/**
 *  JSON字符串 -> 模型
 */
void keyValues2object1()
{
    // 1.定义一个JSON字符串
    NSString *jsonString = @"{\"name\":\"Jack\", \"icon\":\"lufy.png\", \"age\":20, \"height\":333333.7}";
    
    // 2.将JSON字符串转为MJUser模型
    MJUser *user = [MJUser mj_objectWithKeyValues:jsonString];
    
    // 3.打印MJUser模型的属性
    MJExtensionLog(@"name=%@, icon=%@, age=%d, height=%@", user.name, user.icon, user.age, user.height);
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
    MJStatus *status = [MJStatus mj_objectWithKeyValues:dict];
    
    // 3.打印status的属性
    NSString *text = status.text;
    NSString *name = status.user.name;
    NSString *icon = status.user.icon;
    MJExtensionLog(@"text=%@, name=%@, icon=%@", text, name, icon);
    
    // 4.打印status.retweetedStatus的属性
    NSString *text2 = status.retweetedStatus.text;
    NSString *name2 = status.retweetedStatus.user.name;
    NSString *icon2 = status.retweetedStatus.user.icon;
    MJExtensionLog(@"text2=%@, name2=%@, icon2=%@", text2, name2, icon2);
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
                                       @"url" : @"http://www.小码哥ad01.com"
                                       },
                                   @{
                                       @"image" : @"ad02.png",
                                       @"url" : @"http://www.小码哥ad02.com"
                                       }
                                   ],
                           
                           @"totalNumber" : @"2014",
                           @"previousCursor" : @"13476589",
                           @"nextCursor" : @"13476599"
                           };
    
    // 2.将字典转为MJStatusResult模型
    MJStatusResult *result = [MJStatusResult mj_objectWithKeyValues:dict];
    
    // 3.打印MJStatusResult模型的简单属性
    MJExtensionLog(@"totalNumber=%@, previousCursor=%lld, nextCursor=%lld", result.totalNumber, result.previousCursor, result.nextCursor);
    
    // 4.打印statuses数组中的模型属性
    for (MJStatus *status in result.statuses) {
        NSString *text = status.text;
        NSString *name = status.user.name;
        NSString *icon = status.user.icon;
        MJExtensionLog(@"text=%@, name=%@, icon=%@", text, name, icon);
    }
    
    // 5.打印ads数组中的模型属性
    for (MJAd *ad in result.ads) {
        MJExtensionLog(@"image=%@, url=%@", ad.image, ad.url);
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
    
    // 3.打印MJStudent模型的属性
    MJExtensionLog(@"ID=%@, desc=%@, otherName=%@, oldName=%@, nowName=%@, nameChangedTime=%@", stu.ID, stu.desc, stu.otherName, stu.oldName, stu.nowName, stu.nameChangedTime);
    MJExtensionLog(@"bagName=%@, bagPrice=%f", stu.bag.name, stu.bag.price);
    
    //    CFTimeInterval begin = CFAbsoluteTimeGetCurrent();
    //    for (int i = 0; i< 10000; i++) {
    //        [MJStudent mj_objectWithKeyValues:dict];
    //    }
    //    CFTimeInterval end = CFAbsoluteTimeGetCurrent();
    //    MJExtensionLog(@"%f", end - begin);
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
    
    // 2.将字典数组转为MJUser模型数组
    NSArray *userArray = [MJUser mj_objectArrayWithKeyValuesArray:dictArray];
    
    // 3.打印userArray数组中的MJUser模型属性
    for (MJUser *user in userArray) {
        MJExtensionLog(@"name=%@, icon=%@", user.name, user.icon);
    }
}

/**
 *  模型 -> 字典
 */
void object2keyValues()
{
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

/**
 *  模型数组 -> 字典数组
 */
void objectArray2keyValuesArray()
{
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

static NSManagedObjectContext *moc;

void initializeCoreData()
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CoreData" withExtension:@"momd"];
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [moc setPersistentStoreCoordinator:psc];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [documentsURL URLByAppendingPathComponent:@"DataModel.sqlite"];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSError *error = nil;
        NSPersistentStoreCoordinator *psc = [moc persistentStoreCoordinator];
        [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    });
}

/**
 *  CoreData示例
 */
void coreData()
{
    NSArray *games = @[@{
                           @"name": @"火影忍者",
                           @"id": @"1"
                           },
                       @{
                           @"name": @"海贼王",
                           @"id": @"2"
                           }];
    NSDictionary *platform = @{
                               @"name": @"QQ",
                               @"id": @"QQ",
                               @"ignore": @"ignore",
                               @"games": games
                               };
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        initializeCoreData();
    });
    
    [Platform mj_objectWithKeyValues:platform context:moc];
    
    // 利用CoreData保存模型
    [moc save:nil];
    
    MJExtensionLog(@"第一次映射core data数据: %@", platform);
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Platform"];
    NSArray *platforms = [moc executeFetchRequest:request error:nil];
    for (Platform *p in platforms) {
        MJExtensionLog(@"platformJSON = %@", p.mj_keyValues);
        for (Games *g in p.games) {
            MJExtensionLog(@"gameJson = %@", g.mj_keyValues);
        }
    }
    
    NSMutableDictionary *newPlatform = (NSMutableDictionary *)platform.mutableCopy;
    [newPlatform setObject:@"wechat" forKey:@"name"];
    [Platform mj_objectWithKeyValues:newPlatform context:moc];
    
    [moc save:nil];
    
    platforms = [moc executeFetchRequest:request error:nil];
    MJExtensionLog(@"第二次映射core data数据: %@", newPlatform);
    for (Platform *p in platforms) {
        MJExtensionLog(@"platformJSON = %@", p.mj_keyValues);
        for (Games *g in p.games) {
            MJExtensionLog(@"gameJson = %@", g.mj_keyValues);
        }
    }
}

/**
 *  CoreData示例
 */
void coreData2()
{
    NSDictionary *games = @{
                       @"name": @"海贼王*改",
                       @"id": @"2",
                       @"platform": @{@"id": @"QQ"}
                       };
    
    [Games mj_objectWithKeyValues:games context:moc];
    
    // 利用CoreData保存模型
    [moc save:nil];
    
    MJExtensionLog(@"双向映射core data数据: %@", games);
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Platform"];
    NSArray *platforms = [moc executeFetchRequest:request error:nil];
    for (Platform *p in platforms) {
        MJExtensionLog(@"platformJSON = %@", p.mj_keyValues);
        for (Games *g in p.games) {
            MJExtensionLog(@"gameJson = %@", g.mj_keyValues);
        }
    }
}

/**
 * NSCoding示例
 */
void coding()
{
    // 创建模型
    MJBag *bag = [[MJBag alloc] init];
    bag.name = @"Red bag";
    bag.price = 200.8;
    
    NSString *file = [NSTemporaryDirectory() stringByAppendingPathComponent:@"bag.data"];
    // 归档
    [NSKeyedArchiver archiveRootObject:bag toFile:file];
    
    // 解档
    MJBag *decodedBag = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
    MJExtensionLog(@"name=%@, price=%f", decodedBag.name, decodedBag.price);
}

/**
 *  统一转换属性名（比如驼峰转下划线）
 */
void replacedKeyFromPropertyName121()
{
    // 1.定义一个字典
    NSDictionary *dict = @{
                           @"nick_name" : @"旺财",
                           @"sale_price" : @"10.5",
                           @"run_speed" : @"100.9"
                           };
    
    // 2.将字典转为MJUser模型
    MJDog *dog = [MJDog mj_objectWithKeyValues:dict];
    
    // 3.打印MJUser模型的属性
    MJExtensionLog(@"nickName=%@, scalePrice=%f runSpeed=%f", dog.nickName, dog.salePrice, dog.runSpeed);
}

/**
 *  过滤字典的值（比如字符串日期处理为NSDate、字符串nil处理为@""）
 */
void newValueFromOldValue()
{
    // 1.定义一个字典
    NSDictionary *dict = @{
                           @"name" : @"5分钟突破iOS开发",
                           @"publishedTime" : @"2011-09-10"
                           };
    
    // 2.将字典转为MJUser模型
    MJBook *book = [MJBook mj_objectWithKeyValues:dict];
    
    // 3.打印MJUser模型的属性
    MJExtensionLog(@"name=%@, publisher=%@, publishedTime=%@", book.name, book.publisher, book.publishedTime);
}

/**
 *  使用MJExtensionLog打印模型的所有属性
 */
void logAllProperties()
{
    MJUser *user = [[MJUser alloc] init];
    user.name = @"MJ";
    user.age = 10;
    user.sex = SexMale;
    user.icon = @"test.png";
    
    MJExtensionLog(@"%@", user);
}

void execute(void (*fn)(), NSString *comment)
{
    MJExtensionLog(@"[******************%@******************开始]", comment);
    fn();
    MJExtensionLog(@"[******************%@******************结尾]\n ", comment);
}