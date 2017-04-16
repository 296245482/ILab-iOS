//
//  ForecastTableViewController.m
//  whisky
//
//  Created by Jackie-iLab on 2017/3/19.
//  Copyright © 2017年 www.qiufeng.me. All rights reserved.
//

#import "ForecastTableViewController.h"
#import "WHIUserDefaults.h"
#import "WHILocationManager.h"
#import "WHIDatabaseManager.h"
#import "WHIData+Manager.h"
#import "WHIUser+Manager.h"
#import "NSDate+Formatter.m"
#import "WHIPMData+Manager.h"
#import "forecastAirData.h"

@interface ForecastTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *currentCity;
@property (weak, nonatomic) IBOutlet UILabel *tomorrowWheather;
@property (weak, nonatomic) IBOutlet UILabel *tomorrowAirQuaility;
@property (weak, nonatomic) IBOutlet UILabel *outsideTime;
@property (weak, nonatomic) IBOutlet UILabel *insideTime;
@property (weak, nonatomic) IBOutlet UILabel *outsideVol;
@property (weak, nonatomic) IBOutlet UILabel *insideVol;
@property (weak, nonatomic) IBOutlet UILabel *forecastIntake;

@end

@implementation ForecastTableViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    //[self updateCity];
    [self getAQI];
    [self getLastWeekDetail];
    self.outsideTime.text = @"小时";
}

- (void)updateCity{
    NSString *city = @"";
    if ([WHIUserDefaults sharedDefaults].addressDetail.city) {
        city = [WHIUserDefaults sharedDefaults].addressDetail.city;
    } else if ([WHIUserDefaults sharedDefaults].addressDetail.province) {
        city = [WHIUserDefaults sharedDefaults].addressDetail.province;
    } else {
        city = @"未知城市";
    }
    self.currentCity.text = [city substringToIndex:([city length]-1)];
}

//TODO
- (void)getLastWeekDetail{
    [[WHIDatabaseManager sharedManager] searchLastWeekData:[NSDate date] complete:^(NSArray *result){
        float outdoorVenVol=0.0,indoorVenVol=0.0;
        float indoorTime=0.0, outdoorTime=0.0, lastRecordtime = 0.0;
        if([result count] < 1100){
            indoorTime = 3;
            outdoorTime = 21;
            for (WHIData *data in result){
                if(data.outdoor == 1){
                    outdoorVenVol += data.ventilation_vol;
                }else{
                    indoorVenVol += data.ventilation_vol;
                }
            }
//            NSLog(@"result size is %lu", (unsigned long)[result count]);
        }else{
            for (WHIData *data in result){
//              NSLog(@"result is %f %f %d",[data.time_point timeIntervalSince1970], data.ventilation_vol,data.outdoor);
                float nowTime = [data.time_point timeIntervalSince1970];
            
                //ventilation_vol
                if(data.outdoor == 1){
                    outdoorVenVol += data.ventilation_vol;
                }else{
                    indoorVenVol += data.ventilation_vol;
                }
            
                //indoor/outdoor time
                if(data.outdoor == 0){
                    if((nowTime - lastRecordtime) < 1800){
                        indoorTime += (nowTime - lastRecordtime);
                    }
                    lastRecordtime = nowTime;
                }else{
                    if((nowTime - lastRecordtime) < 1800){
                        outdoorTime += (nowTime - lastRecordtime);
                    }
                    lastRecordtime = nowTime;
                }
            }
        }
        
        //ventilation_vol
        self.outsideVol.text = [NSString stringWithFormat:@"%.2f升", (86.4*outdoorVenVol/(outdoorTime+indoorTime))];
        self.insideVol.text = [NSString stringWithFormat:@"%.2f升", (86.4*indoorVenVol/(outdoorTime+indoorTime))];
        
        //in/out door time
        self.outsideTime.text = [NSString stringWithFormat:@"%.2f%%", 100*outdoorTime/(outdoorTime+indoorTime)];
        self.insideTime.text = [NSString stringWithFormat:@"%.2f%%", 100*indoorTime/(outdoorTime+indoorTime)];
        
        
        NSString *city = @"";
        if ([WHIUserDefaults sharedDefaults].addressDetail.city) {
            city = [WHIUserDefaults sharedDefaults].addressDetail.city;
        } else if ([WHIUserDefaults sharedDefaults].addressDetail.province) {
            city = [WHIUserDefaults sharedDefaults].addressDetail.province;
        } else {
            city = @"未知城市";
        }
        self.currentCity.text = [city substringToIndex:([city length]-1)];
        
        [WHIPMData getForecastData:[city substringToIndex:([city length]-1)] complete:^(forecastAirData *result, NSError *_Nullable error){
            if(result){
                self.tomorrowWheather.text = [NSString stringWithFormat:@"%@ - %@度",result.LTEMP,result.HTEMP];
                self.tomorrowAirQuaility.text = [NSString stringWithFormat:@"%@",result.AQI];
                self.forecastIntake.text = [NSString stringWithFormat:@"%.2f微克", [result.PM25 doubleValue] * (86.4*(outdoorVenVol+(indoorVenVol/2))/(outdoorTime+indoorTime))];
            }
        }];
    }];
}

- (void)getAQI{
    
}
//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//}

@end
