//
//  WHIData+Manager.h
//  whisky
//
//  Created by QiuFeng on 5/30/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHIData.h"
#import "WHIClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface WHIData (Manager)

- (NSDictionary *)toParams;

+ (void)upload:(NSArray *)result complete:(ArrayCompleteBlock)complete;
+ (void)uploadRemains:(NSArray *)result logOutUserId:(NSString *)uid token:(NSString *)oldToken complete:(ArrayCompleteBlock)complete;


@end

NS_ASSUME_NONNULL_END
