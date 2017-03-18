//
//  MJPerson.h
//  MJExtensionExample
//
//  Created by 段自强 on 2017/3/18.
//  Copyright © 2017年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MJGoodGroup : NSObject
//组头的商品种类
@property (nonatomic, strong) NSString *goodCategory;
//组头的商品图标
@property (nonatomic, strong) NSString *goodCategoryImage;
//所有商品
@property (nonatomic, strong) NSArray *goods;
@end
