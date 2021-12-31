//
//  NSDate+MJExtension.h
//  MJExtension
//
//  Created by Frank on 2021/12/31.
//  Copyright © 2021 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (MJExtension)

/// Return date string based on "yyyy-MM-dd'T'HH:mm:ssZ".
- (NSString *)mj_defaultDateString;

@end
