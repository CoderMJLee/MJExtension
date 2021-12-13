//
//  MJPerson.h
//  MJExtensionTests
//
//  Created by MJ Lee on 2019/8/29.
//  Copyright © 2019 MJExtension. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TestCrashProtocol <NSObject>

@property (copy, readonly, nonatomic) NSString *oldCrash;

@end

@interface MJPerson : NSObject <TestCrashProtocol>
@property (copy, nonatomic) NSString *name;
@property (nonatomic) BOOL isVIP;
@property (strong, nonatomic) NSArray<MJPerson *> *friends;
@property (strong, nonatomic) NSArray<NSString *> *books;
@end

NS_ASSUME_NONNULL_END
