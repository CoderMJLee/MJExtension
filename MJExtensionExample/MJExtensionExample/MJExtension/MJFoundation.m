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
    _foundationClasses = @[@"NSArray",@"NSAutoreleasePool",@"NSBundle",@"NSByteOrder",@"NSCalendar",@"NSCharacterSet",@"NSCoder",@"NSData",@"NSDate",@"NSDateFormatter",@"NSDecimal",@"NSDecimalNumber",@"NSDictionary",@"NSEnumerator",@"NSError",@"NSException",@"NSFileHandle",@"NSFileManager",@"NSFormatter",@"NSHashTable",@"NSHTTPCookie",@"NSHTTPCookieStorage",@"NSIndexPath",@"NSIndexSet",@"NSInvocation",@"NSJSONSerialization",@"NSKeyValueCoding",@"NSKeyValueObserving",@"NSKeyedArchiver",@"NSLocale",@"NSLock",@"NSMapTable",@"NSMethodSignature",@"NSNotification",@"NSNotificationQueue",@"NSNull",@"NSNumberFormatter",@"NSOperation",@"NSOrderedSet",@"NSOrthography",@"NSPathUtilities",@"NSPointerArray",@"NSPointerFunctions",@"NSPort",@"NSProcessInfo",@"NSPropertyList",@"NSProxy",@"NSRange",@"NSSet",@"NSSortDescriptor",@"NSStream",@"NSString",@"NSTextCheckingResult",@"NSThread",@"NSTimeZone",@"NSTimer",@"NSURL",@"NSURLAuthenticationChallenge",@"NSURLCache",@"NSURLConnection",@"NSURLCredential",@"NSURLCredentialStorage",@"NSURLError",@"NSURLProtectionSpace",@"NSURLProtocol",@"NSURLRequest",@"NSURLResponse",@"NSUserDefaults",@"NSValue",@"NSValueTransformer",@"NSXMLParser",@"NSZone"];
}

+ (BOOL)isClassFromFoundation:(Class)c
{
    MJAssertParamNotNil(c);
    __block BOOL contains = [_foundationClasses containsObject:NSStringFromClass(c)];
    if (!contains) {
        [_foundationClasses enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
            Class superc = NSClassFromString(obj);
            if ([c isSubclassOfClass:superc]) {
                contains = YES;
                *stop = YES;
            }
        }];
    }
    return contains;
}
@end
