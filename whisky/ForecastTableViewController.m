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
    [self updateCity];
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

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//}

@end
