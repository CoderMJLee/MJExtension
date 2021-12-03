//
//  MJPerson.h
//  MJExtensionTests
//
//  Created by MJ Lee on 2019/8/29.
//  Copyright © 2019 MJExtension. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MJPerson : NSObject
@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray<MJPerson *> *friends;
@property (strong, nonatomic) NSArray<NSString *> *books;
@end

NS_ASSUME_NONNULL_END
