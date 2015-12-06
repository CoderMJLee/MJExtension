//
//  MJStatus.h
//  字典与模型的互转
//
//  Created by MJ Lee on 14-5-21.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//  微博模型

#import <Foundation/Foundation.h>
@class MJUser;

@interface MJStatus : NSObject
/** 微博文本内容 */
@property (copy, nonatomic) NSString *text;
/** 微博作者 */
@property (strong, nonatomic) MJUser *user;
/** 转发的微博 */
@property (strong, nonatomic) MJStatus *retweetedStatus;
@end