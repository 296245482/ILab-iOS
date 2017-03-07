//
//  WHIData.h
//  whisky
//
//  Created by QiuFeng on 5/19/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHIBaseModel.h"
#import "WHIPMData.h"
#import "WHIMotionManager.h"

@interface WHIData : WHIBaseModel

@property (nonatomic, assign) NSInteger databaseid;
@property (nonatomic, assign) NSString* user_id;
@property (nonatomic, strong) NSString* database_access_token;
@property (nonatomic, strong) NSDate *time_point;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double latitude;


@property (nonatomic, assign) BOOL outdoor;
@property (nonatomic, assign) WHIMotionState status;
@property (nonatomic, assign) NSInteger steps;
@property (nonatomic, assign) float heart_rate;


@property (nonatomic, assign) float ventilation_rate; //单位时间通气量
@property (nonatomic, assign) float ventilation_vol; //离上次的总通气量
@property (nonatomic, assign) double pm25_concen; //pm浓度
@property (nonatomic, assign) double pm25_intake;  //离上条记录的pm吸入量


@property (nonatomic, assign) NSInteger pm25_datasource; //1=station 2=device。。
@property (nonatomic, strong) NSString* pm25_monitor; //设备号

@property (nonatomic, strong) NSString* APP_version; //app版本号

@property (nonatomic, assign) BOOL upload;

@property (nonatomic, assign) BOOL connection; //此时是否连接网络

@end
