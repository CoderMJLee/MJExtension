//
//  MJFoundation.m
//  MJExtensionExample
//
//  Created by MJ Lee on 14/7/16.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "MJFoundation.h"
#import "MJConst.h"

static NSArray *_foundationClasses;

@implementation MJFoundation

+ (void)initialize
{
    _foundationClasses = @[@"NSArray",@"NSAutoreleasePool",@"NSBundle",@"NSByteOrder",@"NSCalendar",@"NSCharacterSet",@"NSCoder",@"NSData",@"NSDate",@"NSDateFormatter",@"NSDecimal",@"NSDecimalNumber",@"NSDictionary",@"NSEnumerator",@"NSError",@"NSException",@"NSFileHandle",@"NSFileManager",@"NSFormatter",@"NSHashTable",@"NSHTTPCookie",@"NSHTTPCookieStorage",@"NSIndexPath",@"NSIndexSet",@"NSInvocation",@"NSJSONSerialization",@"NSKeyValueCoding",@"NSKeyValueObserving",@"NSKeyedArchiver",@"NSLocale",@"NSLock",@"NSMapTable",@"NSMethodSignature",@"NSNotification",@"NSNotificationQueue",@"NSNull",@"NSNumberFormatter",@"NSObject",@"NSOperation",@"NSOrderedSet",@"NSOrthography",@"NSPathUtilities",@"NSPointerArray",@"NSPointerFunctions",@"NSPort",@"NSProcessInfo",@"NSPropertyList",@"NSProxy",@"NSRange",@"NSRegularExpression",@"NSRunLoop",@"NSScanner",@"NSSet",@"NSSortDescriptor",@"NSStream",@"NSString",@"NSTextCheckingResult",@"NSThread",@"NSTimeZone",@"NSTimer",@"NSURL",@"NSURLAuthenticationChallenge",@"NSURLCache",@"NSURLConnection",@"NSURLCredential",@"NSURLCredentialStorage",@"NSURLError",@"NSURLProtectionSpace",@"NSURLProtocol",@"NSURLRequest",@"NSURLResponse",@"NSUserDefaults",@"NSValue",@"NSValueTransformer",@"NSXMLParser",@"NSZone"];
}

+ (BOOL)isClassFromFoundation:(Class)c
{
    MJAssertParamNotNil(c);
    return [_foundationClasses containsObject:NSStringFromClass(c)];
}
@end
