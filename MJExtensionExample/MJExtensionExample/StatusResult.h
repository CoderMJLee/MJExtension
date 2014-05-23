//
//  StatusResult.h
//  字典与模型的互转
//
//  Created by MJ Lee on 14-5-21.
//  Copyright (c) 2014年 itcast. All rights reserved.
//  微博结果（用来表示大批量的微博数据）

#import <Foundation/Foundation.h>

@interface StatusResult : NSObject
/**
 *  存放着某一页微博数据（里面都是Status模型）
 */
@property (strong, nonatomic) NSArray *statuses;

/**
 *  总数
 */
@property (assign, nonatomic) int totalNumber;

/**
 *  上一页的游标
 */
@property (assign, nonatomic) long long previousCursor;

/**
 *  下一页的游标
 */
@property (assign, nonatomic) long long nextCursor;
@end
