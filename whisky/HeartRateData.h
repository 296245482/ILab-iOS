//
//  HeartRateData.h
//  whisky
//
//  Created by Jackie on 2017/8/21.
//  Copyright © 2017年 www.qiufeng.me. All rights reserved.
//

#import "WHIBaseModel.h"
#import "WHIPMData.h"

@interface HeartRateData : WHIBaseModel

@property (nonatomic, assign) NSInteger databaseid; //ID
@property (nonatomic, assign) NSString* user_id;    //用户ID
@property (nonatomic, assign) NSString* user_name;  //用户名
@property (nonatomic, strong) NSDate *time_point;   //时间
@property (nonatomic, assign) double heart_rate;    //心率
@property (nonatomic, assign) double longitude;     //纬度
@property (nonatomic, assign) double latitude;      //经度
@property (nonatomic, assign) BOOL upload;          //是否上传

@end
