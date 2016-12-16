//
//  DatabaseManager.h
//  whisky
//
//  Created by QiuFeng on 4/22/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WHIData.h"

NS_ASSUME_NONNULL_BEGIN

@interface WHIDatabaseManager : NSObject

+ (instancetype)sharedManager;

- (void)deallocDatabase;

- (void)showDBLog;
- (void)showToDayDBLog:(NSDate *)date;


- (void)insertData:(WHIData *)data complete:(void (^) (BOOL success))complete;
- (void)getTodayData:(NSDate *)date complete:(void (^)(NSArray *breath, NSArray *pm))complete;
- (void)getTwoHourData:(NSDate *)date complete:(void (^)(NSArray * _Nonnull, NSArray * _Nonnull))complete;
- (void)getHourData:(NSDate *)date complete:(void (^)(NSArray * _Nonnull, NSArray * _Nonnull))complete;

- (void)deleteOverDueData:(nullable NSDate *)nowDate;

- (void)queryForUnUploadData:(int)limit complete:(void (^)(NSArray * _Nonnull))complete;
- (void)queryForRemainData:(int)limit date:(NSData*)date complete:(void (^)(NSArray * _Nonnull))complete;
- (void)updateToUpload:(NSArray *)pmData;

@end

NS_ASSUME_NONNULL_END
