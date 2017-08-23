//
//  DatabaseManager.h
//  whisky/Users/luoye/Desktop/ILab-iOS/whisky/AppDelegate.m
//
//  Created by QiuFeng on 4/22/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WHIData.h"
#import "DeviceWifi.h"
#import "HeartRateData.h"

NS_ASSUME_NONNULL_BEGIN

@interface WHIDatabaseManager : NSObject

+ (instancetype)sharedManager;

- (void)deallocDatabase;

- (void)showDBLog;
- (void)showToDayDBLog:(NSDate *)date;


- (void)insertData:(WHIData *)data complete:(void (^) (BOOL success))complete;
- (void)getTodayData:(NSDate *)date complete:(void (^)(NSArray *breath, NSArray *pm25_concen))complete;
- (void)getTodayAccuData:(NSDate *)date complete:(void (^)(NSArray * _Nonnull, NSArray * _Nonnull))complete;
- (void)getTwoHourData:(NSDate *)date complete:(void (^)(NSArray * _Nonnull, NSArray * _Nonnull))complete;
- (void)getHourData:(NSDate *)date complete:(void (^)(NSArray * _Nonnull, NSArray * _Nonnull))complete;

- (void)deleteOverDueData:(nullable NSDate *)nowDate;

- (void)queryForUnUploadData:(int)limit complete:(void (^)(NSArray * _Nonnull))complete;
- (void)queryForRemainData:(int)limit date:(NSData*)date complete:(void (^)(NSArray * _Nonnull))complete;
- (void)updateToUpload:(NSArray *)pmData;

- (void)insertDevice:(DeviceWifi *)deviceWifi complete:(void (^)(BOOL))complete;
- (void)deleteDevice:(NSString* )deviceId;
- (NSArray *)queryForAllDevice;
- (NSString *)queryForDeviceId:(NSString *)wifiName;

- (void)searchLastWeekData:(NSDate *)nowDate complete:(void (^)(NSArray * _Nonnull))complete;

- (void)insertHeartData:(HeartRateData *)data complete:(void (^) (BOOL success))complete;
- (void)queryForUnUploadHeartRateData:(int)limit complete:(void (^)(NSArray * _Nonnull))complete;
- (void)updateHeartDataToUpload:(NSArray *)heartData;

- (void)getTodayHeartRateData:(NSDate *)date complete:(void (^)(NSArray * _Nonnull))complete;

@end

NS_ASSUME_NONNULL_END
