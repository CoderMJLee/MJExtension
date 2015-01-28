//
//  MJAd.h
//  MJExtensionExample
//
//  Created by MJ Lee on 15/1/5.
//  Copyright (c) 2015年 itcast. All rights reserved.
//  广告模型

#import <Foundation/Foundation.h>

@interface MJAd : NSObject
/** 广告图片 */
@property (copy, nonatomic) NSString *image;
/** 广告url */
@property (copy, nonatomic) NSString *url;
@end
