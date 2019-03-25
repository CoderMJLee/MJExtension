//
//  MJStudent.h
//  MJExtensionExample
//
//  Created by MJ Lee on 15/1/5.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MJBag;

@interface MJStudent : NSObject
@property (copy, nonatomic) NSString *ID;
@property (copy, nonatomic) NSString *otherName;
@property (copy, nonatomic) NSString *nowName;
@property (copy, nonatomic) NSString *oldName;
@property (copy, nonatomic) NSString *nameChangedTime;
@property (copy, nonatomic) NSString *desc;
@property (strong, nonatomic) MJBag *bag;
@property (strong, nonatomic) NSArray *books;
@end
