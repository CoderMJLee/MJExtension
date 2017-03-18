//
//  MJ_config.h
//  MyClock
//
//  Created by 段自强 on 2017/3/18.
//  Copyright © 2017年 段自强. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MJConfig : NSObject
//用来存储子模型的类名
@property (nonatomic, strong) NSDictionary *mj_innerObjectKeyValue;
+ (instancetype)single;
@end
