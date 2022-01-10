//
//  NSObject+MJCoding.h
//  MJExtension
//
//  Created by mj on 14-1-15.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtensionPredefine.h"
#import "MJExtensionProtocols.h"

@interface NSObject (MJCoding) <MJECoding>
- (void)mj_decode:(NSCoder *)decoder;
- (void)mj_encode:(NSCoder *)encoder;
@end

/// Coding implementation
#define MJCodingImplementation \
- (nullable instancetype)initWithCoder:(nonnull NSCoder *)decoder { \
if (self = [super init]) [self mj_decode:decoder]; \
return self; \
} \
\
- (void)encodeWithCoder:(nonnull NSCoder *)encoder { \
[self mj_encode:encoder]; \
}\

#define MJExtensionCodingImplementation MJCodingImplementation

/// SecureCoding implementation
#define MJSecureCodingImplementation(CLASS, FLAG) \
@interface CLASS (MJSecureCoding) <NSSecureCoding> \
@end \
@implementation CLASS (MJSecureCoding) \
MJCodingImplementation \
+ (BOOL)supportsSecureCoding { \
return FLAG; \
} \
@end \

