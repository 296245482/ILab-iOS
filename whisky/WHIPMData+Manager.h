//
//  WHIPMData+Manager.h
//  whisky
//
//  Created by QiuFeng on 4/27/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHIPMData.h"
#import "WHIClient.h"
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@class WHIPMData;

typedef void (^PMDataCompleteBlock)           (WHIPMData *_Nullable result, NSError * _Nullable error);

@interface WHIPMData (Manager)

+ (void)getPMData:(CLLocationCoordinate2D)location complete:(PMDataCompleteBlock)complete;
+ (void)getPMDataByDevice:(NSString *)deviceId date:(NSDate *)date complete:(PMDataCompleteBlock)complete;

@end

NS_ASSUME_NONNULL_END
