
![Logo](http://images.cnitblog.com/blog2015/497279/201505/051004316736641.png)
MJExtension
===
- A fast, convenient and nonintrusive conversion between JSON and model.
- 转换速度快、使用简单方便的字典转模型框架

GitHub：[CoderMJLee](https://github.com/CoderMJLee) ｜ Blog：[mjios(Chinese)](http://www.cnblogs.com/mjios) ｜ PR is welcome，or [feedback](mailto:richermj123go@vip.qq.com)


## Contents
* [Getting Started 【开始使用】](#Getting_Started)
	* [Features 【能做什么】](#Features)
	* [Why MJExtension 【为什么使用MJExtension】](#Why_MJExtension)
	* [Installation 【安装】](#Installation)
* [Examples 【示例】](#Examples)
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
	* [Camel -> underline](#Camel_underline)
	* [NSString -> NSDate, nil -> @""](#NSString_NSDate)
	* [More use cases](#More_use_cases)

---

# <a id="Getting_Started"></a> Getting Started【开始使用】

## <a id="Features"></a> Features【能做什么】
- MJExtension是一套字典和模型之间互相转换的超轻量级框架
* `JSON` --> `Model`、`Core Data Model`
* `JSONString` --> `Model`、`Core Data Model`
* `Model`、`Core Data Model` --> `JSON`
* `JSON Array` --> `Model Array`、`Core Data Model Array`
* `JSONString` --> `Model Array`、`Core Data Model Array`
* `Model Array`、`Core Data Model Array` --> `JSON Array`
* Coding all properties of model in one line code.
    * 只需要一行代码，就能实现模型的所有属性进行Coding（归档和解档）

## <a id="Why_MJExtension"></a> Why use MJExtension, why not use JSONModel or Mantle
#### MJExtension is faster than JSONModel and Mantle【转换速率】
- `MJExtension` > `JSONModel` > `Mantle` _(Feel free to test it yourself)_
- 各位开发者也可以自行测试

#### MJExtension is more easy to go【MJExtension更加容易使用】
- `JSONModel`
	- You `must` let `all` model class extend `JSONModel` class
   - 要求所有模型类`必须`继承自JSONModel基类

- `Mantle`
	- You `must` let `all` model class extend `MTModel` class.
   - 要求所有模型类`必须`继承自MTModel基类

- `MJExtension`
	- Your model class `doesn't need to` extend another base class. You don't need to modify any model file.  `Nonintrusive`, `convenient`.
   - `不需要`你的模型类继承任何特殊基类，也不需要修改任何模型代码，毫无污染，毫无侵入性

## <a id="Installation"></a> Installation【安装】

### From CocoaPods【使用CocoaPods】

```ruby
pod 'MJExtension'
```

### Manually【手动导入】
- Drag all source files under floder `MJExtension` to your project.【将`MJExtension`文件夹中的所有源代码拽入项目中】
- Import the main header file：`#import "MJExtension.h"`【导入主头文件：`#import "MJExtension.h"`】

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

# <a id="Examples"></a> Examples【示例】

### <a id="JSON_Model"></a> The most simple JSON -> Model【最简单的字典转模型】

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
//   @"gay" : @"1"
//   @"gay" : @"NO"
};

// JSON -> User
User *user = [User objectWithKeyValues:dict];

NSLog(@"name=%@, icon=%@, age=%zd, height=%@, money=%@, sex=%d, gay=%d", user.name, user.icon, user.age, user.height, user.money, user.sex, user.gay);
// name=Jack, icon=lufy.png, age=20, height=1.550000, money=100.9, sex=1
```

### <a id="JSONString_Model"></a> JSONString -> Model【JSON字符串转模型】

```objc
// 1.Define a JSONString
NSString *jsonString = @"{\"name\":\"Jack\", \"icon\":\"lufy.png\", \"age\":20}";

// 2.JSONString -> User
User *user = [User objectWithKeyValues:jsonString];

// 3.Print user's properties
NSLog(@"name=%@, icon=%@, age=%d", user.name, user.icon, user.age);
// name=Jack, icon=lufy.png, age=20
```

### <a id="Model_contains_model"></a> Model contains model【模型中嵌套模型】

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

### <a id="Model_contains_model_array"></a> Model contains model-array【模型中有个数组属性，数组里面又要装着其他模型】

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
               // @"statuses" : [Status class],
               @"ads" : @"Ad"
               // @"ads" : [Ad class]
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

### <a id="Model_name_JSON_key_mapping"></a> Model name - JSON key mapping【模型中的属性名和字典中的key不相同(或者需要多级映射)】

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
               @"nameChangedTime" : @"name.info[1].nameChangedTime",
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
        @"info" : @[
        		 @"test-data",
        		 @{
            	             @"nameChangedTime" : @"2013-08"
                         }
                  ]
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


### <a id="JSON_array_model_array"></a> JSON array -> model array【将一个字典数组转成模型数组】

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

### <a id="Model_JSON"></a> Model -> JSON【将一个模型转成字典】
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
    ID = 123;
    bag =     {
        name = "\U5c0f\U4e66\U5305";
        price = 205;
    };
    desc = handsome;
    nameChangedTime = "2018-09-08";
    nowName = jack;
    oldName = rose;
}
 */
```

### <a id="Model_array_JSON_array"></a> Model array -> JSON array【将一个模型数组转成字典数组】

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

@implementation Bag
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

### <a id="Camel_underline"></a> Camel -> underline【统一转换属性名（比如驼峰转下划线）】
```objc
// Dog
#import "MJExtension.h"

@implementation Dog
+ (NSString *)replacedKeyFromPropertyName121:(NSString *)propertyName
{
    // nickName -> nick_name
    return [propertyName underlineFromCamel];
}
@end

// NSDictionary
NSDictionary *dict = @{
                       @"nick_name" : @"旺财",
                       @"sale_price" : @"10.5",
                       @"run_speed" : @"100.9"
                       };
// NSDictionary -> Dog
Dog *dog = [Dog objectWithKeyValues:dict];

// printing
NSLog(@"nickName=%@, scalePrice=%f runSpeed=%f", dog.nickName, dog.salePrice, dog.runSpeed);
```

### <a id="NSString_NSDate"></a> NSString -> NSDate, nil -> @""【过滤字典的值（比如字符串日期处理为NSDate、字符串nil处理为@""）】
```objc
// Book
#import "MJExtension.h"

@implementation Book
- (id)newValueFromOldValue:(id)oldValue property:(MJProperty *)property
{
    if ([property.name isEqualToString:@"publisher"]) {
        if (oldValue == nil) return @"";
    } else if (property.type.typeClass == [NSDate class]) {
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        fmt.dateFormat = @"yyyy-MM-dd";
        return [fmt dateFromString:oldValue];
    }

    return oldValue;
}
@end

// NSDictionary
NSDictionary *dict = @{
                       @"name" : @"5分钟突破iOS开发",
                       @"publishedTime" : @"2011-09-10"
                       };
// NSDictionary -> Book
Book *book = [Book objectWithKeyValues:dict];

// printing
NSLog(@"name=%@, publisher=%@, publishedTime=%@", book.name, book.publisher, book.publishedTime);
```

### <a id="More_use_cases"></a> More use cases【更多用法】
- Please reference to `NSObject+MJKeyValue.h` and `NSObject+MJCoding.h`


## 期待
* 如果在使用过程中遇到BUG，希望你能Issues我，谢谢（或者尝试下载最新的框架代码看看BUG修复没有）
* 如果在使用过程中发现功能不够用，希望你能Issues我，我非常想为这个框架增加更多好用的功能，谢谢
* 如果你想为MJExtension输出代码，请拼命Pull Requests我
* 一起携手打造天朝乃至世界最好用的字典模型框架，做天朝程序员的骄傲
