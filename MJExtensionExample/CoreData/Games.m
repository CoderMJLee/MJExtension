//
//  Games.m
//  MJExtensionExample
//
//  Created by 陆晖 on 16/2/25.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import "Games.h"
#import "Platform.h"

@implementation Games

//+ (void)initialize {
//    if (self == [Games class]) {
//        [self mj_setupIdentityPropertyNames:^NSArray *{
//            return @[@"name"];
//        }];
//    }
//}

+ (NSMutableArray *)mj_identityPropertyNames {
    return @[@"name"].mutableCopy;
}

+ (NSArray *)mj_ignoredJSONSerializaitonPropertyNames {
    return [NSMutableArray arrayWithObjects:@"objectId", nil];
}

@end
