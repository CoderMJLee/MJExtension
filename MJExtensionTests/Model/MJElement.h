//
//  MJElement.h
//  MJExtensionTests
//
//  Created by libin14 on 2020/10/20.
//  Copyright © 2020 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MJElement : NSObject

@property (assign, nonatomic) NSInteger count;

@end


@interface MJRenderElement : MJElement

@property (copy, nonatomic) NSString *renderName;

@end

NS_ASSUME_NONNULL_END
