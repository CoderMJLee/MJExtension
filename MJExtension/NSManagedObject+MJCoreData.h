//
//  NSManagedObject+MJCoreData.h
//  MJExtensionExample
//
//  Created by 陆晖 on 15/10/30.
//  Copyright © 2015年 陆晖. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "NSObject+MJKeyValue.h"

/** 这个数组中的属性名将会作为唯一键值判断，如果所有键值都存在且相等，则从数据获取数据进行更新 */
typedef NSArray * (^MJIdentityPropertyNames)();

@protocol MJCoreDataKeyValue <MJKeyValue>

@optional
/**
 *  CoreData里的unique key，映射之前，先通过unique key去查找对应的data，如果存在，则更新，不存在，则新建
 */
+ (NSMutableArray *)mj_identityPropertyNames;

@end

@interface NSManagedObject (MJCoreData)<MJCoreDataKeyValue>

/**
 *  CoreData里的unique key，映射之前，先通过unique key去查找对应的data，如果存在，则更新，不存在，则新建
 */
+ (void)mj_setupIdentityPropertyNames:(MJIdentityPropertyNames)ientityPropertyNames;
+ (NSMutableArray *)mj_totalIdentityPropertyNames;

@end
