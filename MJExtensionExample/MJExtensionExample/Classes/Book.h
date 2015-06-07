//
//  Book.h
//  MJExtensionExample
//
//  Created by MJ Lee on 15/6/7.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Book : NSObject
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *publisher;
@property (strong, nonatomic) NSDate *publishedTime;
@end
