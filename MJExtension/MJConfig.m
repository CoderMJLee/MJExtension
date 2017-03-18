//
//  MJ_config.m
//  MyClock
//
//  Created by 段自强 on 2017/3/18.
//  Copyright © 2017年 段自强. All rights reserved.
//

#import "MJConfig.h"

@implementation MJConfig
+ (instancetype)single
{
    static MJConfig *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 添加同步锁，一次只能一个线程访问。如果有多个线程访问，等待。一个访问结束后下一个。
        @synchronized(self)
        {
            if (nil ==  instance)
            {
                instance = [[super allocWithZone:nil] init];
            }
        }
    });
    return instance;
}

+ (instancetype)alloc
{
    return [self single];
}

@end
