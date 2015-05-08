![Logo](http://images.cnitblog.com/blog2015/497279/201505/051004316736641.png)
MJExtension
===
The fastest, most convenient and most nonintrusive conversion between JSON and model.

GitHub：[CoderMJLee](https://github.com/CoderMJLee) ｜ Blog：[mjios(Chinese)](http://www.cnblogs.com/mjios) ｜ PR is welcome，or [feedback](mailto:richermj123go@vip.qq.com)


## Contents
* [Getting Started](#Getting_Started)
	* [Installation](#Installation)
	* [Features](#Features)
	* [Why MJExtension](#Why_MJExtension)
* [Examples](#Examples)
	* [JSON -> Model](#JSON_Model)
	* [JSONString -> Model](#JSONString_Model)
	* [Model contains model](#Model_contains_model)
	* [Model contains model-array](#Model_contains_model_array)
	* [Model name - JSON key mapping](#Model_name_JSON_key_mapping)
	* [JSON array -> model array](#JSON_array_model_array)
	* [Model -> JSON](#Model_JSON)
	* [Model array -> JSON array](#Model_array_JSON_array)
	* [Core Data](#Core_Data)
	* [Coding](#Coding)
	* [More use cases](#More_use_cases)
* [Chinese Version](#Chinese_Version)

---

# <a id="Getting_Started"></a> Getting Started

## <a id="Installation"></a> Installation

### From CocoaPods

```ruby
pod 'MJExtension'
```

### Manually
Drag all source files under floder `MJExtensionExample/MJExtensionExample/MJExtension` to your project.
Import the main header file：`#import "MJExtension.h"`

```objc
MJExtension.h
MJConst.h               MJConst.m
MJFoundation.h          MJFoundation.m
MJProperty.h            MJProperty.m
MJType.h                MJType.m
NSObject+MJCoding.h     NSObject+MJCoding.m
NSObject+MJProperty.h   NSObject+MJProperty.m
NSObject+MJKeyValue.h   NSObject+MJKeyValue.m
```

## <a id="Features"></a> Features

* `JSON` --> `Model`、`Core Data Model`
* `JSONString` --> `Model`、`Core Data Model`
* `Model`、`Core Data Model` --> `JSON`
* `JSON Array` --> `Model Array`、`Core Data Model Array`
* `JSONString` --> `Model Array`、`Core Data Model Array`
* `Model Array`、`Core Data Model Array` --> `JSON Array`
* Coding all properties of model in one line code. 


## <a id="Why_MJExtension"></a> Why use MJExtension, why not use JSONModel or Mantle
#### MJExtension is faster than JSONModel and Mantle
`MJExtension` > `JSONModel` > `Mantle` _(Feel free to test it yourself)_
#### MJExtension is more easy to go
`JSONModel`：You `must` let `all` model class extends `JSONModel` class.

`Mantle`：You `must` let `all` model class extends `MTModel` class.

`MJExtension`：Your model class `don't need to` extends another base class. You don't need to modify any model file.  `Nonintrusive`, `convenient`.


# <a id="Examples"></a> Examples

### <a id="JSON_Model"></a> The most simple JSON -> Model

```objc
typedef enum {
    SexMale,
    SexFemale
} Sex;

@interface User : NSObject
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *icon;
@property (assign, nonatomic) unsigned int age;
@property (copy, nonatomic) NSString *height;
@property (strong, nonatomic) NSNumber *money;
@property (assign, nonatomic) Sex sex;
@property (assign, nonatomic, getter=isGay) BOOL gay;
@end

/***********************************************/

NSDictionary *dict = @{
    @"name" : @"Jack",
    @"icon" : @"lufy.png",
    @"age" : @20,
    @"height" : @"1.55",
    @"money" : @100.9,
    @"sex" : @(SexFemale),
    @"gay" : @"true"
};

// JSON -> User
User *user = [User objectWithKeyValues:dict];

NSLog(@"name=%@, icon=%@, age=%zd, height=%@, money=%@, sex=%d, gay=%d", user.name, user.icon, user.age, user.height, user.money, user.sex, user.gay);
// name=Jack, icon=lufy.png, age=20, height=1.550000, money=100.9, sex=1
```

### <a id="JSONString_Model"></a> JSONString -> Model

```objc
// 1.Define a JSONString
NSString *jsonString = @"{\"name\":\"Jack\", \"icon\":\"lufy.png\", \"age\":20}";

// 2.JSONString -> User
User *user = [User objectWithKeyValues:jsonString];

// 3.Print user's properties
NSLog(@"name=%@, icon=%@, age=%d", user.name, user.icon, user.age);
// name=Jack, icon=lufy.png, age=20
```

### <a id="Model_contains_model"></a> Model contains model

```objc
@interface Status : NSObject
@property (copy, nonatomic) NSString *text;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) Status *retweetedStatus;
@end

/***********************************************/

NSDictionary *dict = @{
    @"text" : @"Agree!Nice weather!",
    @"user" : @{
        @"name" : @"Jack",
        @"icon" : @"lufy.png"
    },
    @"retweetedStatus" : @{
        @"text" : @"Nice weather!",
        @"user" : @{
            @"name" : @"Rose",
            @"icon" : @"nami.png"
        }
    }
};

// JSON -> Status
Status *status = [Status objectWithKeyValues:dict];

NSString *text = status.text;
NSString *name = status.user.name;
NSString *icon = status.user.icon;
NSLog(@"text=%@, name=%@, icon=%@", text, name, icon);
// text=Agree!Nice weather!, name=Jack, icon=lufy.png

NSString *text2 = status.retweetedStatus.text;
NSString *name2 = status.retweetedStatus.user.name;
NSString *icon2 = status.retweetedStatus.user.icon;
NSLog(@"text2=%@, name2=%@, icon2=%@", text2, name2, icon2);
// text2=Nice weather!, name2=Rose, icon2=nami.png
```

### <a id="Model_contains_model_array"></a> Model contains model-array

```objc
@interface Ad : NSObject
@property (copy, nonatomic) NSString *image;
@property (copy, nonatomic) NSString *url;
@end

@interface StatusResult : NSObject
/** Contatins status model */
@property (strong, nonatomic) NSMutableArray *statuses;
/** Contatins ad model */
@property (strong, nonatomic) NSArray *ads;
@property (strong, nonatomic) NSNumber *totalNumber;
@end

/***********************************************/

// Tell MJExtension what type model will be contained in statuses and ads.
[StatusResult setupObjectClassInArray:^NSDictionary *{
    return @{
               @"statuses" : @"Status",
               @"ads" : @"Ad"
           };
}];
// Equals: StatusResult.m implements +objectClassInArray method.

NSDictionary *dict = @{
    @"statuses" : @[
                      @{
                          @"text" : @"Nice weather!",
                          @"user" : @{
                              @"name" : @"Rose",
                              @"icon" : @"nami.png"
                          }
                      },
                      @{
                          @"text" : @"Go camping tomorrow!",
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
    @"totalNumber" : @"2014"
};

// JSON -> StatusResult
StatusResult *result = [StatusResult objectWithKeyValues:dict];

NSLog(@"totalNumber=%@", result.totalNumber);
// totalNumber=2014

// Printing
for (Status *status in result.statuses) {
    NSString *text = status.text;
    NSString *name = status.user.name;
    NSString *icon = status.user.icon;
    NSLog(@"text=%@, name=%@, icon=%@", text, name, icon);
}
// text=Nice weather!, name=Rose, icon=nami.png
// text=Go camping tomorrow!, name=Jack, icon=lufy.png

// Printing
for (Ad *ad in result.ads) {
    NSLog(@"image=%@, url=%@", ad.image, ad.url);
}
// image=ad01.png, url=http://www.ad01.com
// image=ad02.png, url=http://www.ad02.com
```

### <a id="Model_name_JSON_key_mapping"></a> Model name - JSON key mapping

```objc
@interface Bag : NSObject
@property (copy, nonatomic) NSString *name;
@property (assign, nonatomic) double price;
@end

@interface Student : NSObject
@property (copy, nonatomic) NSString *ID;
@property (copy, nonatomic) NSString *desc;
@property (copy, nonatomic) NSString *nowName;
@property (copy, nonatomic) NSString *oldName;
@property (copy, nonatomic) NSString *nameChangedTime;
@property (strong, nonatomic) Bag *bag;
@end

/***********************************************/

// How to map
[Student setupReplacedKeyFromPropertyName:^NSDictionary *{
    return @{
               @"ID" : @"id",
               @"desc" : @"desciption",
               @"oldName" : @"name.oldName",
               @"nowName" : @"name.newName",
               @"nameChangedTime" : @"name.info.nameChangedTime",
               @"bag" : @"other.bag"
           };
}];
// Equals: Student.m implements +replacedKeyFromPropertyName method.

NSDictionary *dict = @{
    @"id" : @"20",
    @"desciption" : @"kids",
    @"name" : @{
        @"newName" : @"lufy",
        @"oldName" : @"kitty",
        @"info" : @{
            @"nameChangedTime" : @"2013-08"
        }
    },
    @"other" : @{
        @"bag" : @{
            @"name" : @"a red bag",
            @"price" : @100.7
        }
    }
};

// JSON -> Student
Student *stu = [Student objectWithKeyValues:dict];

// Printing
NSLog(@"ID=%@, desc=%@, oldName=%@, nowName=%@, nameChangedTime=%@",
      stu.ID, stu.desc, stu.oldName, stu.nowName, stu.nameChangedTime);
// ID=20, desc=kids, oldName=kitty, nowName=lufy, nameChangedTime=2013-08
NSLog(@"bagName=%@, bagPrice=%f", stu.bag.name, stu.bag.price);
// bagName=a red bag, bagPrice=100.700000
```


### <a id="JSON_array_model_array"></a> JSON array -> model array

```objc
NSArray *dictArray = @[
                         @{
                             @"name" : @"Jack",
                             @"icon" : @"lufy.png"
                         },
                         @{
                             @"name" : @"Rose",
                             @"icon" : @"nami.png"
                         }
                     ];

// JSON array -> User array
NSArray *userArray = [User objectArrayWithKeyValuesArray:dictArray];

// Printing
for (User *user in userArray) {
    NSLog(@"name=%@, icon=%@", user.name, user.icon);
}
// name=Jack, icon=lufy.png
// name=Rose, icon=nami.png
```

### <a id="Model_JSON"></a> Model -> JSON
```objc
// New model
User *user = [[User alloc] init];
user.name = @"Jack";
user.icon = @"lufy.png";

Status *status = [[Status alloc] init];
status.user = user;
status.text = @"Nice mood!";

// Status -> JSON
NSDictionary *statusDict = status.keyValues;
NSLog(@"%@", statusDict);
/*
 {
 text = "Nice mood!";
 user =     {
 icon = "lufy.png";
 name = Jack;
 };
 }
 */

// More complex situation
Student *stu = [[Student alloc] init];
stu.ID = @"123";
stu.oldName = @"rose";
stu.nowName = @"jack";
stu.desc = @"handsome";
stu.nameChangedTime = @"2018-09-08";

Bag *bag = [[Bag alloc] init];
bag.name = @"a red bag";
bag.price = 205;
stu.bag = bag;

NSDictionary *stuDict = stu.keyValues;
NSLog(@"%@", stuDict);
/*
 {
 desciption = handsome;
 id = 123;
 name =     {
 info =         {
 nameChangedTime = "2018-09-08";
 };
 newName = jack;
 oldName = rose;
 };
 other =     {
 bag =         {
 name = "a red bag";
 price = 205;
 };
 };
 }
 */
```

### <a id="Model_array_JSON_array"></a> Model array -> JSON array

```objc
// New model array
User *user1 = [[User alloc] init];
user1.name = @"Jack";
user1.icon = @"lufy.png";

User *user2 = [[User alloc] init];
user2.name = @"Rose";
user2.icon = @"nami.png";

NSArray *userArray = @[user1, user2];

// Model array -> JSON array
NSArray *dictArray = [User keyValuesArrayWithObjectArray:userArray];
NSLog(@"%@", dictArray);
/*
 (
 {
 icon = "lufy.png";
 name = Jack;
 },
 {
 icon = "nami.png";
 name = Rose;
 }
 )
 */
```

### <a id="Core_Data"></a> Core Data

```objc
NSDictionary *dict = @{
                         @"name" : @"Jack",
                         @"icon" : @"lufy.png",
                         @"age" : @20,
                         @"height" : @1.55,
                         @"money" : @"100.9",
                         @"sex" : @(SexFemale),
                         @"gay" : @"true"
                     };

// This demo just provide simple steps
NSManagedObjectContext *context = nil;
User *user = [User objectWithKeyValues:dict context:context];

[context save:nil];
```

### <a id="Coding"></a> Coding

```objc
#import "MJExtension.h"

@implementation User
// NSCoding Implementation
MJCodingImplementation
@end

/***********************************************/

// what properties not to be coded
[Bag setupIgnoredCodingPropertyNames:^NSArray *{
    return @[@"name"];
}];
// Equals: Bag.m implements +ignoredCodingPropertyNames method.

// Create model
Bag *bag = [[Bag alloc] init];
bag.name = @"Red bag";
bag.price = 200.8;

NSString *file = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop/bag.data"];
// Encoding
[NSKeyedArchiver archiveRootObject:bag toFile:file];

// Decoding
Bag *decodedBag = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
NSLog(@"name=%@, price=%f", decodedBag.name, decodedBag.price);
// name=(null), price=200.800000
```

### <a id="More_use_cases"></a> More use cases

Please reference to `NSObject+MJKeyValue.h` and `NSObject+MJCoding.h`


## <a id="Chinese_Version"></a> MJExtension(Chinese)
* 世界上转换速度最快、使用最简单方便的字典转模型框架

## 能做什么？
 * MJExtension是一套`字典和模型之间互相转换`的超轻量级框架
 * MJExtension能完成的功能
    * `字典（JSON）` --> `模型（Model）`、`CoreData模型（Core Data Model）`
    * `JSON字符串` --> `模型（Model）`、`CoreData模型（Core Data Model）`
    * `模型（Model）`、`CoreData模型（Core Data Model）` --> `字典（JSON）`
    * `字典数组（JSON Array）` --> `模型数组（Model Array）`、`Core Data模型数组（Core Data Model Array）`
    * `JSON字符串` --> `模型数组（Model Array）`、`Core Data模型数组（Core Data Model Array）`
    * `模型数组（Model Array）`、`Core Data模型数组（Core Data Model Array）` --> `字典数组（JSON Array）`
    * 只需要一行代码，就能实现模型的所有属性进行Coding（归档和解档）
 * 详尽用法主要参考 main.m中的各个函数 以及 `NSObject+MJKeyValue.h`

## MJExtension和JSONModel、Mantle等框架的区别
* 转换速率：
	* 最近一次测试表明：`MJExtension` > `JSONModel` > `Mantle`
	* 各位开发者也可以自行测试
* 具体用法：
	* `JSONModel`：要求所有模型类`必须`继承自JSONModel基类
	* `Mantle`：要求所有模型类`必须`继承自MTModel基类
	* `MJExtension`：`不需要`你的模型类继承任何特殊基类，也不需要修改任何模型代码，毫无污染，毫无侵入性

## 如何使用MJExtension
* cocoapods导入：`pod 'MJExtension'`
* 手动导入：
    * 将`MJExtensionExample/MJExtensionExample/MJExtension`文件夹中的所有源代码拽入项目中
    * 导入主头文件：`#import "MJExtension.h"`
```objc
MJExtension.h
MJConst.h               MJConst.m
MJFoundation.h          MJFoundation.m
MJIvar.h                MJIvar.m
MJType.h                MJType.m
NSObject+MJCoding.h     NSObject+MJCoding.m
NSObject+MJIvar.h       NSObject+MJIvar.m
NSObject+MJKeyValue.h   NSObject+MJKeyValue.m
```

## 最简单的字典转模型
```objc
typedef enum {
    SexMale,
    SexFemale
} Sex;

@interface User : NSObject
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *icon;
@property (assign, nonatomic) unsigned int age;
@property (copy, nonatomic) NSString *height;
@property (strong, nonatomic) NSNumber *money;
@property (assign, nonatomic) Sex sex;
@property (assign, nonatomic, getter=isGay) BOOL gay;
@end

/***********************************************/

NSDictionary *dict = @{
    @"name" : @"Jack",
    @"icon" : @"lufy.png",
    @"age" : @20,
    @"height" : @"1.55",
    @"money" : @100.9,
    @"sex" : @(SexFemale),
//	 @"gay" : @"1"
//	 @"gay" : @"NO"
    @"gay" : @"true"
};

// 将字典转为User模型
User *user = [User objectWithKeyValues:dict];

NSLog(@"name=%@, icon=%@, age=%zd, height=%@, money=%@, sex=%d, gay=%d", user.name, user.icon, user.age, user.height, user.money, user.sex, user.gay);
// name=Jack, icon=lufy.png, age=20, height=1.550000, money=100.9, sex=1
```
##### 核心代码
* `[User objectWithKeyValues:dict]`

## JSON字符串转模型
```objc
// 1.定义一个JSON字符串
NSString *jsonString = @"{\"name\":\"Jack\", \"icon\":\"lufy.png\", \"age\":20}";

// 2.将JSON字符串转为User模型
User *user = [User objectWithKeyValues:jsonString];

// 3.打印User模型的属性
NSLog(@"name=%@, icon=%@, age=%d", user.name, user.icon, user.age);
// name=Jack, icon=lufy.png, age=20
```
##### 核心代码
* `[User objectWithKeyValues:dict]`

## 模型中嵌套模型
```objc
@interface Status : NSObject
/** 微博文本内容 */
@property (copy, nonatomic) NSString *text;
/** 微博作者 */
@property (strong, nonatomic) User *user;
/** 转发的微博 */
@property (strong, nonatomic) Status *retweetedStatus;
@end

/***********************************************/

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

// 将字典转为Status模型
Status *status = [Status objectWithKeyValues:dict];

NSString *text = status.text;
NSString *name = status.user.name;
NSString *icon = status.user.icon;
NSLog(@"text=%@, name=%@, icon=%@", text, name, icon);
// text=是啊，今天天气确实不错！, name=Jack, icon=lufy.png

NSString *text2 = status.retweetedStatus.text;
NSString *name2 = status.retweetedStatus.user.name;
NSString *icon2 = status.retweetedStatus.user.icon;
NSLog(@"text2=%@, name2=%@, icon2=%@", text2, name2, icon2);
// text2=今天天气真不错！, name2=Rose, icon2=nami.png
```
##### 核心代码
* `[Status objectWithKeyValues:dict]`

## 模型中有个数组属性，数组里面又要装着其他模型
```objc
@interface Ad : NSObject
@property (copy, nonatomic) NSString *image;
@property (copy, nonatomic) NSString *url;
@end

@interface StatusResult : NSObject
/** 存放着一堆的微博数据（里面都是Status模型） */
@property (strong, nonatomic) NSMutableArray *statuses;
/** 存放着一堆的广告数据（里面都是Ad模型） */
@property (strong, nonatomic) NSArray *ads;
@property (strong, nonatomic) NSNumber *totalNumber;
@end

/***********************************************/

// StatusResult类中的statuses数组中存放的是Status模型
// StatusResult类中的ads数组中存放的是Ad模型
[StatusResult setupObjectClassInArray:^NSDictionary *{
    return @{
             @"statuses" : @"Status",
             @"ads" : @"Ad"
             };
}];
// 相当于在StatusResult.m中实现了+objectClassInArray方法

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
                       @"totalNumber" : @"2014"
                    };

// 将字典转为StatusResult模型
StatusResult *result = [StatusResult objectWithKeyValues:dict];

NSLog(@"totalNumber=%@", result.totalNumber);
// totalNumber=2014

// 打印statuses数组中的模型属性
for (Status *status in result.statuses) {
    NSString *text = status.text;
    NSString *name = status.user.name;
    NSString *icon = status.user.icon;
    NSLog(@"text=%@, name=%@, icon=%@", text, name, icon);
}
// text=今天天气真不错！, name=Rose, icon=nami.png
// text=明天去旅游了, name=Jack, icon=lufy.png

// 打印ads数组中的模型属性
for (Ad *ad in result.ads) {
    NSLog(@"image=%@, url=%@", ad.image, ad.url);
}
// image=ad01.png, url=http://www.ad01.com
// image=ad02.png, url=http://www.ad02.com
```
##### 核心代码
* 调用`+ (void)setupObjectClassInArray:`方法  
* `[StatusResult objectWithKeyValues:dict]`
* 提醒一句：如果NSArray\NSMutableArray属性中存放的不希望是模型，而是NSNumber、NSString等基本数据，那么就不需要调用`+ (void)setupObjectClassInArray:`方法

## 模型中的属性名和字典中的key不相同(或者需要多级映射)
```objc
@interface Bag : NSObject
@property (copy, nonatomic) NSString *name;
@property (assign, nonatomic) double price;
@end

@interface Student : NSObject
@property (copy, nonatomic) NSString *ID;
@property (copy, nonatomic) NSString *desc;
@property (copy, nonatomic) NSString *nowName;
@property (copy, nonatomic) NSString *oldName;
@property (copy, nonatomic) NSString *nameChangedTime;
@property (strong, nonatomic) Bag *bag;
@end

/***********************************************/

// Student中的ID属性对应着字典中的id
// ....
[Student setupReplacedKeyFromPropertyName:^NSDictionary *{
    return @{@"ID" : @"id",
             @"desc" : @"desciption",
             @"oldName" : @"name.oldName",
             @"nowName" : @"name.newName",
             @"nameChangedTime" : @"name.info.nameChangedTime",
             @"bag" : @"other.bag"
             };
}];
// 相当于在Student.m中实现了+replacedKeyFromPropertyName方法

NSDictionary *dict = @{
                       @"id" : @"20",
                       @"desciption" : @"孩子",
                       @"name" : @{
                            @"newName" : @"lufy",
                            @"oldName" : @"kitty",
                            @"info" : @{
                                @"nameChangedTime" : @"2013-08"
                            }
                       },
                       @"other" : @{
                            @"bag" : @{
                                @"name" : @"小书包",
                                @"price" : @100.7
                            }
                       }
                   };

// 将字典转为Student模型
Student *stu = [Student objectWithKeyValues:dict];

// 打印Student模型的属性
NSLog(@"ID=%@, desc=%@, oldName=%@, nowName=%@, nameChangedTime=%@",
          stu.ID, stu.desc, stu.oldName, stu.nowName, stu.nameChangedTime);
// ID=20, desc=孩子, oldName=kitty, nowName=lufy, nameChangedTime=2013-08
NSLog(@"bagName=%@, bagPrice=%f", stu.bag.name, stu.bag.price);
// bagName=小书包, bagPrice=100.700000
```
##### 核心代码
* 调用`+ (void)setupReplacedKeyFromPropertyName:`方法  
* `[Student objectWithKeyValues:dict]`

## 将一个字典数组转成模型数组
```objc
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

// 将字典数组转为User模型数组
NSArray *userArray = [User objectArrayWithKeyValuesArray:dictArray];

// 打印userArray数组中的User模型属性
for (User *user in userArray) {
    NSLog(@"name=%@, icon=%@", user.name, user.icon);
}
// name=Jack, icon=lufy.png
// name=Rose, icon=nami.png
```
##### 核心代码
* `[User objectArrayWithKeyValuesArray:dictArray]`

## 将一个模型转成字典
```objc
// 新建模型
User *user = [[User alloc] init];
user.name = @"Jack";
user.icon = @"lufy.png";

Status *status = [[Status alloc] init];
status.user = user;
status.text = @"今天的心情不错！";

// 将模型转为字典
NSDictionary *statusDict = status.keyValues;
NSLog(@"%@", statusDict);
/*
{
    text = "今天的心情不错！";
    user =     {
        icon = "lufy.png";
        name = Jack;
    };
}
*/

// 多级映射的模型
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
/*
{
    desciption = handsome;
    id = 123;
    name =     {
        info =         {
            nameChangedTime = "2018-09-08";
        };
        newName = jack;
        oldName = rose;
    };
    other =     {
        bag =         {
            name = "小书包";
            price = 205;
        };
    };
}
*/
```
##### 核心代码
* `status.keyValues`、`stu.keyValues`

## 将一个模型数组转成字典数组
```objc
// 新建模型数组
User *user1 = [[User alloc] init];
user1.name = @"Jack";
user1.icon = @"lufy.png";

User *user2 = [[User alloc] init];
user2.name = @"Rose";
user2.icon = @"nami.png";

NSArray *userArray = @[user1, user2];

// 将模型数组转为字典数组
NSArray *dictArray = [User keyValuesArrayWithObjectArray:userArray];
NSLog(@"%@", dictArray);
/*
(
    {
        icon = "lufy.png";
        name = Jack;
    },
    {
        icon = "nami.png";
        name = Rose;
    }
)
*/
```
##### 核心代码
* `[User keyValuesArrayWithObjectArray:userArray]`

## Core Data
```objc
NSDictionary *dict = @{
                       @"name" : @"Jack",
                       @"icon" : @"lufy.png",
                       @"age" : @20,
                       @"height" : @1.55,
                       @"money" : @"100.9",
                       @"sex" : @(SexFemale),
                       @"gay" : @"true"
                       };

// 这个Demo仅仅提供思路，具体的方法参数需要自己创建
NSManagedObjectContext *context = nil;
User *user = [User objectWithKeyValues:dict context:context];

// 利用CoreData保存模型
[context save:nil];
```
##### Core code
* `[User objectWithKeyValues:dict context:context]`

## Coding
```objc
#import "MJExtension.h"

@implementation User
// NSCoding实现
MJCodingImplementation
@end

/***********************************************/

// Bag类中的name属性不参与归档
[Bag setupIgnoredCodingPropertyNames:^NSArray *{
    return @[@"name"];
}];
// 相当于在Bag.m中实现了+ignoredCodingPropertyNames方法

// 创建模型
Bag *bag = [[Bag alloc] init];
bag.name = @"Red bag";
bag.price = 200.8;

NSString *file = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop/bag.data"];
// 归档
[NSKeyedArchiver archiveRootObject:bag toFile:file];

// 解档
Bag *decodedBag = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
NSLog(@"name=%@, price=%f", decodedBag.name, decodedBag.price);
// name=(null), price=200.800000
```
##### Core code
* `MJCodingImplementation`
* 调用`+ (void)setupIgnoredCodingPropertyNames`方法（如果全部属性都要归档、解档，那就不需要调用这个方法）

## 更多用法
* 参考`NSObject+MJKeyValue.h`
* 参考`NSObject+MJCoding.h`

## 期待
* 如果在使用过程中遇到BUG，希望你能Issues我，谢谢（或者尝试下载最新的框架代码看看BUG修复没有）
* 如果在使用过程中发现功能不够用，希望你能Issues我，我非常想为这个框架增加更多好用的功能，谢谢
* 如果你想为MJExtension输出代码，请拼命Pull Requests我
* 一起携手打造天朝乃至世界最好用的字典模型框架，做天朝程序员的骄傲
