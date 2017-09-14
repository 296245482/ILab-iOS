//
//  HeartRateDataUpload.h
//  whisky
//
//  Created by Jackie-iLab on 2017/9/13.
//  Copyright © 2017年 www.qiufeng.me. All rights reserved.
//

#import "HeartRateData.h"
#import "WHIData.h"
#import "WHIClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface HeartRateData (Manager)

+ (void)uploadHeart:(NSArray *)result complete:(ArrayCompleteBlock)complete;

@end

NS_ASSUME_NONNULL_END
