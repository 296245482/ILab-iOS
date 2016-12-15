

//
//  WHIPMData+Manager.m
//  whisky
//
//  Created by QiuFeng on 4/27/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHIPMData+Manager.h"
#import "NSValue+Location.h"
#import "Mantle.h"
#import "NSDate+Formatter.h"
#import "WHIUserDefaults.h"

@implementation WHIPMData (Manager)

+ (void)getPMDataByDevice:(NSString *)deviceId date:(NSDate *)date complete:(PMDataCompleteBlock)complete {
    NSDictionary *params = @{@"time_point": [date whi_dateWithFormat:@"yyyy-MM-dd HH:mm:ss"],
                             @"devid": deviceId};
    [[WHIClient sharedClient] get:@"device-datas" parameters:params complete:^(id  _Nullable result, NSError * _Nullable error) {
        if (error) {
            complete(nil, error);
        }  else {
            if ([result isKindOfClass:[NSArray class]] && [result count] >= 1) {
                WHIPMData *pmData = [MTLJSONAdapter modelOfClass:[WHIPMData class] fromJSONDictionary:result[@"data"] error:&error];
                pmData.source = 3;
                complete(pmData, error);
            } else {
                complete(nil, [[NSError alloc] init]);
            }
        }
    }];
}

+ (void)getPMData:(CLLocationCoordinate2D)location complete:(PMDataCompleteBlock)complete {
    NSDictionary *params = @{@"longitude": @(location.longitude),
                             @"latitude": @(location.latitude),
                             @"use_station": @(1)};
    [[WHIClient sharedClient] get:@"urban-airs/search" parameters:params complete:^(id  _Nullable result, NSError * _Nullable error) {
        if (error) {
            WHIPMData *pmData = [[WHIPMData alloc] init];
            pmData.AQI = @(0);
            pmData.PM25 = [WHIUserDefaults sharedDefaults].lastPm;
            complete(pmData, nil);
        } else {
            WHIPMData *pmData;
            if ([result[@"data"] isKindOfClass:[NSDictionary class]]) {
                pmData = [MTLJSONAdapter modelOfClass:[WHIPMData class] fromJSONDictionary:result[@"data"] error:&error];
                [WHIUserDefaults sharedDefaults].lastPm = pmData.PM25;
            } else {
                pmData = [[WHIPMData alloc] init];
                pmData.AQI = @(0);
                pmData.PM25 = [WHIUserDefaults sharedDefaults].lastPm;
            }
            complete(pmData, nil);
        }
    }];
}



@end
