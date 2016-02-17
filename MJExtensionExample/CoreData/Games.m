//
//  Games.m
//  MJExtensionExample
//
//  Created by 陆晖 on 16/2/17.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import "Games.h"

@implementation Games

// Insert code here to add functionality to your managed object subclass
+ (NSMutableArray *)mj_identityPropertyNames {
    return [NSMutableArray arrayWithObjects:@"gameId", nil];
}

+ (NSArray *)mj_ignoredJSONSerializaitonPropertyNames {
    return [NSMutableArray arrayWithObjects:@"gameId", nil];
}

@end
