//
//  Base.h
//  MJExtensionExample
//
//  Created by 陆晖 on 16/2/25.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MJExtension.h"

NS_ASSUME_NONNULL_BEGIN

@interface Base : NSManagedObject<MJCoreDataKeyValue>

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "Base+CoreDataProperties.h"
