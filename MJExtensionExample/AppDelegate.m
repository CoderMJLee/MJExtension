//
//  AppDelegate.m
//  MJExtensionExample
//
//  Created by MJ Lee on 15/11/8.
//  Copyright © 2015年 小码哥. All rights reserved.
//

#import "AppDelegate.h"
#import "MJBag.h"
#import "MJExtensionConst.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    /* 目的：想让模型有一个固定的属性名（做唯一标示用），方便存储数据，读取数据用。
     * 操作：MJBag 模型类遵循了modelProtocol协议，归档。
     * 结果：程序崩溃。
     * 原因：modelProtocol协议继承 NSObject协议，遍历属性时，获得了NSObject协议中的属性。导致归档失败。
     *
     *  #warning 防止遍历到当前类的父类属性，@"hash" 属性是NSObject 中的。
     *  if (!property.type.typeClass && [property.name isEqualToString:@"hash"])
     *  {
     *      break;
     *  }
     *
     */
    MJBag *bag = [[MJBag alloc] init];
    bag.modelID = @"100122222";
    bag.name = @"商品";
    bag.price = 11.5;
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:bag];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:bag.modelID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        id data = [[NSUserDefaults standardUserDefaults] objectForKey:bag.modelID];
        id <modelProtocol> model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        MJExtensionLog(@"model.modelID:%@",model.modelID);
    });
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
