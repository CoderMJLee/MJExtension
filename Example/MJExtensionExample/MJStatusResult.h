//
//  MJStatusResult.h
//  字典与模型的互转
//
//  Created by MJ Lee on 14-5-21.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//  微博结果（用来表示大批量的微博数据）

#import "MJBaseObject.h"

@interface MJStatusResult : MJBaseObject
/** 存放着某一页微博数据（里面都是Status模型） */
@property (strong, nonatomic) NSMutableArray *statuses;
/** 存放着一堆的广告数据（里面都是MJAd模型） */
@property (strong, nonatomic) NSArray *ads;
/** 总数 */
@property (strong, nonatomic) NSNumber *totalNumber;
/** 上一页的游标 */
@property (assign, nonatomic) long long previousCursor;
/** 下一页的游标 */
@property (assign, nonatomic) long long nextCursor;
@end
