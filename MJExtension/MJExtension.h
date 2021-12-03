//
//  MJExtension.h
//  MJExtension
//
//  Created by mj on 14-1-15.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include(<MJExtension/MJExtension.h>)
FOUNDATION_EXPORT double MJExtensionVersionNumber;
FOUNDATION_EXPORT const unsigned char MJExtensionVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <MJExtension/PublicHeader.h>
#import <MJExtension/NSObject+MJCoding.h>
#import <MJExtension/NSObject+MJKeyValue.h>
#import <MJExtension/NSString+MJExtension.h>
#import <MJExtension/MJExtensionConst.h>
#import <MJExtension/MJProperty.h>
#import <MJExtension/MJExtensionProtocols.h>
#else
#import "NSObject+MJCoding.h"
#import "NSObject+MJKeyValue.h"
#import "NSString+MJExtension.h"
#import "MJExtensionConst.h"
#import "MJProperty.h"
#import "MJExtensionProtocols.h"
#endif

