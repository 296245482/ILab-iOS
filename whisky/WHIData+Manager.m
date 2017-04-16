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
#import "WHIUserDefaults.h"

@implementation WHIData (Manager)

- (NSDictionary *)toParams {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userid"] = [WHIUser currentUser].objectId ?: @"";
    dic[@"time_point"] = [self.time_point whi_dateWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    dic[@"longitude"] = [NSString stringWithFormat:@"%lf", self.longitude];
    dic[@"latitude"] = [NSString stringWithFormat:@"%lf", self.latitude];
    if (self.outdoor) {
        dic[@"outdoor"] = @"1";
    } else {
        dic[@"outdoor"] = @"0";
    }
    dic[@"status"] = [NSString stringWithFormat:@"%ld", (long)self.status];
    dic[@"heart_rate"] = [NSString stringWithFormat:@"%lf", self.heart_rate];
    dic[@"ventilation_rate"] = [NSString stringWithFormat:@"%lf", self.ventilation_rate];
    dic[@"pm25_concen"] = [NSString stringWithFormat:@"%lf", self.pm25_concen];
    dic[@"pm25_datasource"] = [NSString stringWithFormat:@"%ld", (long)self.pm25_datasource];
    dic[@"steps"] = [NSString stringWithFormat:@"%ld", (long)self.steps];
    
    dic[@"database_access_token"] = self.database_access_token ?:@"";
    dic[@"ventilation_vol"] = [NSString stringWithFormat:@"%lf", self.ventilation_vol];
    dic[@"pm25_intake"] = [NSString stringWithFormat:@"%lf", self.pm25_intake];
    dic[@"pm25_monitor"] = self.pm25_monitor?:@"";
    dic[@"APP_version"] = self.APP_version?:@"error";
    
    return dic;
}


- (NSDictionary *)remainedToParams:logOutId {
    NSString *uid = logOutId;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userid"] = uid;
    dic[@"time_point"] = [self.time_point whi_dateWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    dic[@"longitude"] = [NSString stringWithFormat:@"%lf", self.longitude];
    dic[@"latitude"] = [NSString stringWithFormat:@"%lf", self.latitude];
    if (self.outdoor) {
        dic[@"outdoor"] = @"1";
    } else {
        dic[@"outdoor"] = @"0";
    }
    dic[@"status"] = [NSString stringWithFormat:@"%ld", (long)self.status];
    dic[@"heart_rate"] = [NSString stringWithFormat:@"%lf", self.heart_rate];
    dic[@"ventilation_rate"] = [NSString stringWithFormat:@"%lf", self.ventilation_rate];
    dic[@"pm25_concen"] = [NSString stringWithFormat:@"%lf", self.pm25_concen];
    dic[@"pm25_datasource"] = [NSString stringWithFormat:@"%ld", (long)self.pm25_datasource];
    dic[@"steps"] = [NSString stringWithFormat:@"%ld", (long)self.steps];
    
    dic[@"database_access_token"] = self.database_access_token?:@"";
    dic[@"ventilation_vol"] = [NSString stringWithFormat:@"%lf", self.ventilation_vol];
    dic[@"pm25_intake"] = [NSString stringWithFormat:@"%lf", self.pm25_intake];
    dic[@"pm25_monitor"] = self.pm25_monitor?:@"";
    dic[@"APP_version"] = self.APP_version?:@"error";
    
    return dic;
}

+ (void)upload:(NSArray *)result complete:(ArrayCompleteBlock)complete {
    if (result == nil) {
        complete(nil, nil);
        return;
    }
//    NSLog(@"post result is %@",result);
    NSMutableArray *arrayData = [NSMutableArray array];
    for (WHIData *data in result) {
        if (data.upload == NO) {
            [arrayData addObject:[data toParams]];
        }
    }
    
    NSString *access_token = [WHIUserDefaults sharedDefaults].token;
    NSDictionary *paras = @{@"access_token": access_token ?: @"",
                            @"data": arrayData};
//    NSLog(@"token is %@",paras);
    [[WHIClient sharedClient] post:@"new-mobile-data/upload" parameters:paras complete:^(id successResult, NSError * _Nullable error) {
        complete(result, error);
    }];

}

+ (void)uploadRemains:(NSArray *)result logOutUserId:(NSString *)uid token:(NSString *)oldToken complete:(ArrayCompleteBlock)complete {
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
    
    
    
    NSString *access_token = oldToken;
    NSDictionary *paras = @{@"access_token": access_token ?: @"",
                            @"data": arrayData};
//    NSLog(@"token is %@",paras);
    [[WHIClient sharedClient] post:@"new-mobile-data/upload" parameters:paras complete:^(id successResult, NSError * _Nullable error) {
        complete(result, error);
    }];
    
}

@end
