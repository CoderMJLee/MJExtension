//
//  NSManagedObject+MJCoreData.m
//  MJExtensionExample
//
//  Created by 陆晖 on 15/10/30.
//  Copyright © 2015年 陆晖. All rights reserved.
//

#import "NSManagedObject+MJCoreData.h"
#import "NSObject+MJClass.h"

@interface NSObject (MJClassPrivate)

+ (NSMutableArray *)mj_totalObjectsWithSelector:(SEL)selector key:(const char *)key;

@end

static const char MJCoreDataIdentityKey = '\0';

@implementation NSManagedObject (MJCoreData)

+ (void)mj_setupIdentityPropertyNames:(MJIdentityPropertyNames)ientityPropertyNames {
    [self mj_setupBlockReturnValue:ientityPropertyNames key:&MJCoreDataIdentityKey];
}

+ (NSMutableArray *)mj_totalIdentityPropertyNames {
    return [self mj_totalObjectsWithSelector:@selector(mj_identityPropertyNames) key:&MJCoreDataIdentityKey];
}

@end
