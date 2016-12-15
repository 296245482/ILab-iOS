//
//  NSDate+Formatter.h
//  erp
//
//  Created by QiuFeng on 11/9/15.
//  Copyright © 2015 www.sui.me. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Formatter)

/**
 *  format @"yyyy-MM-dd HH:mm:ss"
 */
- (NSString *)whi_dateWithFormat:(NSString *)format;

- (NSString *)whi_xAxisString;

@end

NS_ASSUME_NONNULL_END
