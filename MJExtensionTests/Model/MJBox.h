//
//  MJBox.h
//  MJExtensionExample
//
//  Created by MJ Lee on 15/6/10.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MJBoxDelegate <NSObject>

@optional
@property (copy, nonatomic) NSString *name;
@end

@interface MJBox : NSObject <MJBoxDelegate>
@property (assign, nonatomic) double weight;
@property (assign, nonatomic) int size;
@end
