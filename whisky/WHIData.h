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
@property (nonatomic, assign) BOOL outdoor;
@property (nonatomic, assign) NSInteger steps;
@property (nonatomic, assign) float avg_rate;
@property (nonatomic, assign) float ventilation_volume; //通气量
@property (nonatomic, assign) NSInteger source; //1=station 2=device。。

@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) WHIMotionState status;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) BOOL upload;


@property (nonatomic, assign) double pm25;

@end
