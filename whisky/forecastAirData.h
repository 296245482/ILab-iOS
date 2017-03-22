//
//  forecastAirData.h
//  whisky
//
//  Created by Jackie-iLab on 2017/3/22.
//  Copyright © 2017年 www.qiufeng.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WHIBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface forecastAirData : WHIBaseModel

@property (nonatomic, strong) NSString *AQI;
@property (nonatomic, strong) NSString *PM25;
@property (nonatomic, strong) NSString *HTEMP;
@property (nonatomic, strong) NSString *LTEMP;

@end

NS_ASSUME_NONNULL_END
