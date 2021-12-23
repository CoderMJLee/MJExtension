//
//  MJCat.h
//  MJExtensionTests
//
//  Created by Frank on 2020/6/9.
//  Copyright © 2020 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MJCat : NSObject <MJEConfiguration>

@property (nonatomic, copy, nullable) NSString *name;
@property (nonatomic, copy, nullable) NSArray<NSString *> *nicknames;
@property (nonatomic, copy, nullable) NSString *address;
@property (nonatomic, copy, nullable) NSString *identifier;

@property (nonatomic) UIColor *color;

@end

NS_ASSUME_NONNULL_END
