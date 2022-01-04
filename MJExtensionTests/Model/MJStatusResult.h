//
//  MJStatusResult.h
//  字典与模型的互转
//
//  Created by MJ Lee on 14-5-21.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//  微博结果（用来表示大批量的微博数据）

#import "MJBaseObject.h"
@class MJStatus, MJAd;

@interface MJStatusResult : MJBaseObject
/** 存放着某一页微博数据（里面都是Status模型） */
@property (strong, nonatomic) NSMutableArray<MJStatus *> *statuses;
/** 存放着一堆的广告数据（里面都是MJAd模型, 假定为怪异数据类型, [array<array<ad>>]） */
@property (strong, nonatomic) NSArray<NSArray<MJAd *> *> *ads;
/** 总数 */
@property (strong, nonatomic) NSNumber *totalNumber;
/** 上一页的游标 */
@property (assign, nonatomic) long long previousCursor;
/** 下一页的游标 */
@property (assign, nonatomic) long long nextCursor;
@end
