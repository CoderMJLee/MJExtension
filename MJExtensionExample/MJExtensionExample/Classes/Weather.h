//
//  Weather.h
//  MJExtensionExample
//
//  Created by 开发者 on 15/4/9.
//  Copyright (c) 2015年 itcast. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Weather : NSObject
/** 存放着一天之中每小时的温度（NSNumber类型） */
@property (nonatomic, strong) NSArray *temperatures;
/** 存放着最近一周的风力状况，包括风向和风力（NSDictionary类型） */
@property (nonatomic, strong) NSArray *cloud;
@end
