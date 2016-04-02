//
//  Base+CoreDataProperties.h
//  MJExtensionExample
//
//  Created by 陆晖 on 16/2/25.
//  Copyright © 2016年 小码哥. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Base.h"

NS_ASSUME_NONNULL_BEGIN

@interface Base (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *objectId;

@end

NS_ASSUME_NONNULL_END
