//
//  NSDate+MJExtension.h
//  MJExtensionExample
//
//  Created by ricky on 15/9/7.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (MJExtension)

+ (instancetype)mj_dateWithString:(NSString *)aString;
+ (void)mj_registerDateFormat:(NSString *)format;

@end
