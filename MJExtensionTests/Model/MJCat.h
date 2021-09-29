//
//  MJCat.h
//  MJExtensionTests
//
//  Created by Frank on 2020/6/9.
//  Copyright © 2020 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MJCat : NSObject <MJKeyValue>

@property (nonatomic, copy, nullable) NSString *name;
@property (nonatomic, copy, nullable) NSArray<NSString *> *nicknames;
@property (nonatomic, copy, nullable) NSString *address;
@property (nonatomic, copy, nullable) NSString *identifier;

@end

NS_ASSUME_NONNULL_END
