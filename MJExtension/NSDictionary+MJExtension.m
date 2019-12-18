//
//  NSDictionary+MJExtension.m
//  MJExtension
//
//  Created by Frank on 2019/10/29.
//

#import "NSDictionary+MJExtension.h"
#import "NSObject+MJKeyValue.h"


@implementation NSDictionary (MJExtension)

- (NSMutableDictionary *)mj_enumerateKeyValues {
    NSMutableDictionary *subDict = NSMutableDictionary.dictionary;
    [self enumerateKeysAndObjectsUsingBlock:^(id key, NSObject *obj, BOOL *stop) {
        subDict[key] = obj.mj_keyValues;
    }];
    return subDict;
}

@end
