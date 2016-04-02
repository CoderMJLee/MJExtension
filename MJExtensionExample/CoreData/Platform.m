//
//  Platform.m
//  MJExtensionExample
//
//  Created by 陆晖 on 16/2/25.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import "Platform.h"
#import "Games.h"

@implementation Platform

+ (void)initialize {
    if (self == [Platform class]) {
        [self mj_setupObjectMappingPropertyNames:^NSArray *{
            return @[@"objectId", @"name", @"games"];
        }];
        
        [self mj_setupJSONSerializationPropertyNames:^NSArray *{
            return @[@"name", @"games"];
        }];
        
        [self mj_setupObjectClassInArray:^NSDictionary *{
            return @{@"games": [Games class]};
        }];
    }
}

@end
