//
//  Platform+CoreDataProperties.h
//  MJExtensionExample
//
//  Created by 陆晖 on 16/2/25.
//  Copyright © 2016年 小码哥. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Platform.h"

NS_ASSUME_NONNULL_BEGIN

@interface Platform (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *ignore;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<Games *> *games;

@end

@interface Platform (CoreDataGeneratedAccessors)

- (void)addGamesObject:(Games *)value;
- (void)removeGamesObject:(Games *)value;
- (void)addGames:(NSSet<Games *> *)values;
- (void)removeGames:(NSSet<Games *> *)values;

@end

NS_ASSUME_NONNULL_END
