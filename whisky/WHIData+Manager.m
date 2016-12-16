//
//  WHIData+Manager.m
//  whisky
//
//  Created by QiuFeng on 5/30/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHIData+Manager.h"
#import "WHIUser+Manager.h"
#import "NSDate+Formatter.h"

@implementation WHIData (Manager)

- (NSDictionary *)toParams {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userid"] = [WHIUser currentUser].objectId ?: @"";
    dic[@"time_point"] = [self.date whi_dateWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    dic[@"longitude"] = [NSString stringWithFormat:@"%lf", self.longitude];
    dic[@"latitude"] = [NSString stringWithFormat:@"%lf", self.latitude];
    if (self.outdoor) {
        dic[@"outdoor"] = @"1";
    } else {
        dic[@"outdoor"] = @"0";
    }
    dic[@"status"] = [NSString stringWithFormat:@"%ld", (long)self.status];
    dic[@"avg_rate"] = [NSString stringWithFormat:@"%lf", self.avg_rate];
    dic[@"ventilation_volume"] = [NSString stringWithFormat:@"%lf", self.ventilation_volume];
    dic[@"pm25"] = [NSString stringWithFormat:@"%lf", self.pm25];
    dic[@"source"] = [NSString stringWithFormat:@"%ld", (long)self.source];
    dic[@"steps"] = [NSString stringWithFormat:@"%ld", (long)self.steps];
    return dic;
}


- (NSDictionary *)remainedToParams:logOutId {
    NSString *uid = logOutId;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userid"] = uid;
    dic[@"time_point"] = [self.date whi_dateWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    dic[@"longitude"] = [NSString stringWithFormat:@"%lf", self.longitude];
    dic[@"latitude"] = [NSString stringWithFormat:@"%lf", self.latitude];
    if (self.outdoor) {
        dic[@"outdoor"] = @"1";
    } else {
        dic[@"outdoor"] = @"0";
    }
    dic[@"status"] = [NSString stringWithFormat:@"%ld", (long)self.status];
    dic[@"avg_rate"] = [NSString stringWithFormat:@"%lf", self.avg_rate];
    dic[@"ventilation_volume"] = [NSString stringWithFormat:@"%lf", self.ventilation_volume];
    dic[@"pm25"] = [NSString stringWithFormat:@"%lf", self.pm25];
    dic[@"source"] = [NSString stringWithFormat:@"%ld", (long)self.source];
    dic[@"steps"] = [NSString stringWithFormat:@"%ld", (long)self.steps];
    return dic;
}

+ (void)upload:(NSArray *)result complete:(ArrayCompleteBlock)complete {
    if (result == nil) {
        complete(nil, nil);
        return;
    }
    
    NSMutableArray *arrayData = [NSMutableArray array];
    for (WHIData *data in result) {
        if (data.upload == NO) {
            [arrayData addObject:[data toParams]];
        }
    }
    NSLog(@"post para is %@",arrayData);
    [[WHIClient sharedClient] post:@"mobile-data/upload" parameters:@{@"data": arrayData} complete:^(id successResult, NSError * _Nullable error) {
        complete(result, error);
    }];

}

+ (void)uploadRemains:(NSArray *)result logOutUserId:(NSString *)uid complete:(ArrayCompleteBlock)complete {
    if (result == nil) {
        complete(nil, nil);
        return;
    }
    NSString *logOutId = uid;
    //    NSLog(@"post error result is %@",result);
    NSMutableArray *arrayData = [NSMutableArray array];
    for (WHIData *data in result) {
        if (data.upload == NO) {
            [arrayData addObject:[data remainedToParams:logOutId]];
        }
    }
    NSLog(@"post para is %@",arrayData);
    [[WHIClient sharedClient] post:@"mobile-data/upload" parameters:@{@"data": arrayData} complete:^(id successResult, NSError * _Nullable error) {
        complete(result, error);
    }];
    
}

@end
