//
//  Games+CoreDataProperties.h
//  MJExtensionExample
//
//  Created by 陆晖 on 16/3/25.
//  Copyright © 2016年 小码哥. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Games.h"

NS_ASSUME_NONNULL_BEGIN

@interface Games (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *isHot;
@property (nullable, nonatomic, retain) Platform *platform;

@end

NS_ASSUME_NONNULL_END
