//
//  MJFrenchUser.h
//  MJExtensionTests
//
//  Created by Frank on 2019/9/26.
//  Copyright © 2019 MJ Lee. All rights reserved.
//

#import "MJUser.h"
#import "MJCat.h"

NS_ASSUME_NONNULL_BEGIN

@interface MJFrenchUser : MJUser

@property (nonatomic) NSSet<MJCat *> *cats;

@property (nonatomic) long double money_longDouble;

@end

NS_ASSUME_NONNULL_END
