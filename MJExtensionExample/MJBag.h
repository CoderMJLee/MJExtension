//
//  MJBag.h
//  MJExtensionExample
//
//  Created by MJ Lee on 15/1/28.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol modelProtocol <NSObject>

@property (nonatomic, copy) NSString *modelID;

@end

@interface MJBag : NSObject <modelProtocol>
@property (copy, nonatomic) NSString *name;
@property (assign, nonatomic) double price;
/** 协议属性,模型唯一标示，存储数据时使用 */
@property (nonatomic, copy) NSString *modelID;
@end
