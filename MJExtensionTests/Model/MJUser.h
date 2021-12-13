//
//  MJUser.h
//  字典与模型的互转
//
//  Created by MJ Lee on 14-5-21.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//  用户模型

#import <Foundation/Foundation.h>

typedef enum {
    SexMale,
    SexFemale
} Sex;

@interface MJUser : NSObject <MJEConfiguration>
/** 名称 */
@property (copy, nonatomic) NSString *name;
/** 头像 */
@property (copy, nonatomic) NSString *icon;
/** 年龄 */
@property (assign, nonatomic) int age;
@property (assign, nonatomic) unsigned int age2;
/** 身高 */
@property (strong, nonatomic) NSNumber *height;
/** 财富 */
@property (strong, nonatomic) NSDecimalNumber *money;
/** 性别 */
@property (assign, nonatomic) Sex sex;
/** 同性恋 */
@property (assign, nonatomic, getter=isGay) BOOL gay;
/** 速度 */
@property (assign, nonatomic) NSInteger speed;
/** 标识 */
@property (assign, nonatomic) long long identifier;
@property (assign, nonatomic) unsigned long long identifier2;
/** 价格 */
@property (assign, nonatomic) double price;
/** 赞 */
@property (assign, nonatomic) int like;
/** 收藏 */
@property (assign, nonatomic) int collect;
/** 富有 */
@property (assign, nonatomic) BOOL rich;

/** 一定为 NO, 用来测试无效数据 @"alien": @"yr Joking"  */
@property (assign, nonatomic) BOOL alien;

@end
