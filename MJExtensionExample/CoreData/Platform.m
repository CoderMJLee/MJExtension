//
//  Platform.m
//  MJExtensionExample
//
//  Created by 陆晖 on 16/2/17.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import "Platform.h"
#import "MJExtension.h"
#import "Games.h"

@implementation Platform

+ (void)initialize {
    [self mj_setupIdentityPropertyNames:^NSArray *{
        return @[@"platformId"];
    }];
    
    [self mj_setupObjectMappingPropertyNames:^NSArray *{
        return @[@"platformId", @"name", @"games"];
    }];
    
    [self mj_setupJSONSerializationPropertyNames:^NSArray *{
        return @[@"name", @"games"];
    }];
    
    [self mj_setupObjectClassInArray:^NSDictionary *{
        return @{@"games": [Games class]};
    }];
}

// Insert code here to add functionality to your managed object subclass

@end
