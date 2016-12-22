

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
#import "WHIUser+Manager.h"
#import "WHIDatabaseManager.h"
#import "WHIData+Manager.h"

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
    NSString *access_token = [WHIUserDefaults sharedDefaults].token;
    //    NSString *access_token = @"asdasdasda";
    //NSLog(@"token here is %@",access_token);
    NSString *uid = [WHIUser currentUser].objectId ?:@"";
    
    NSDictionary *params = @{@"longitude": @(location.longitude),
                             @"latitude": @(location.latitude),
                             @"use_station": @(1),
                             @"access_token": access_token ?: @""};
    [[WHIClient sharedClient] get:@"urban-airs/search" parameters:params complete:^(id  _Nullable result, NSError * _Nullable error) {
        if (error) {
            WHIPMData *pmData = [[WHIPMData alloc] init];
            pmData.AQI = @(0);
            pmData.PM25 = [WHIUserDefaults sharedDefaults].lastPm;
            complete(pmData, nil);
        } else {
            WHIPMData *pmData;
            NSInteger token_status = [result[@"token_status"] integerValue];
            //NSLog(@"token_status is %ld", (long)token_status);
            if (token_status == 2){
                NSDate *lastLogin = result[@"last_login"];
                
                [self uploadRemainedData:lastLogin userid:uid];
                
                [WHIUser logOut];
                //                NSLog(@"token here is %@",access_token);
            }else{
                if ([result[@"data"] isKindOfClass:[NSDictionary class]]) {
                    pmData = [MTLJSONAdapter modelOfClass:[WHIPMData class] fromJSONDictionary:result[@"data"] error:&error];
                    [WHIUserDefaults sharedDefaults].lastPm = pmData.PM25;
                    //NSLog(@"right token");
                } else {
                    pmData = [[WHIPMData alloc] init];
                    pmData.AQI = @(0);
                    pmData.PM25 = [WHIUserDefaults sharedDefaults].lastPm;
                }
                complete(pmData, nil);
            }
        }
    }];
}


//TODO
+ (void)uploadRemainedData:(NSDate *)lastDate userid:(NSString *)uid {
    if ([WHIUserDefaults sharedDefaults].autoUpload) {
        [[WHIDatabaseManager sharedManager] queryForRemainData:500 date:lastDate complete:^(NSArray * result) {
            NSString *logOutUser = uid;
//            NSLog(@"user id is %@",uid);
            [WHIData uploadRemains:result logOutUserId:logOutUser complete:^(NSArray * _Nullable array, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"upload failed");
                } else {
                    NSLog(@"upload succeed");
                    for (WHIData *data in array) {
                        data.upload = YES;
                    }
                    [[WHIDatabaseManager sharedManager] updateToUpload:array];
                }
            }];
        }];
    }
}

@end
