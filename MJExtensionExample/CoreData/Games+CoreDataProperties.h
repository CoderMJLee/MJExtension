//
//  Games+CoreDataProperties.h
//  MJExtensionExample
//
//  Created by 陆晖 on 16/2/17.
//  Copyright © 2016年 小码哥. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Games.h"
@class Platform;

NS_ASSUME_NONNULL_BEGIN

@interface Games (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *gameId;
@property (nullable, nonatomic, retain) Platform *platform;

@end

NS_ASSUME_NONNULL_END
