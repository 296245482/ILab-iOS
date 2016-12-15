//
//  WHIPMData.h
//  whisky
//
//  Created by QiuFeng on 4/27/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHIBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, WHIPMSource) {
    WHIPMSourceUnkonw = 0,
    WHIPMSourceUrbanAir = 1, //MSRA的数据
    WHIPMSourcePM25in = 2, //全国各地的环保部站点的监测数据
    WHIPMSourceDevice = 3,
};

@interface WHIPMData : WHIBaseModel

@property (nonatomic, copy) NSNumber *AQI;
@property (nonatomic, copy) NSNumber *PM25;
@property (nonatomic, assign) WHIPMSource source;

@end

NS_ASSUME_NONNULL_END