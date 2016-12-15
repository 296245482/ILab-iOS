//
//  SUIClientConfigure.h
//  erp
//
//  Created by QiuFeng on 11/2/15.
//  Copyright © 2015 www.sui.me. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WHIClientConfigure : NSObject

@property (nonatomic, copy, nullable) NSString *token;
@property (nonatomic, assign) BOOL requiredToken;
@property (nonatomic, assign) BOOL onCompletionQueue;

@end

NS_ASSUME_NONNULL_END