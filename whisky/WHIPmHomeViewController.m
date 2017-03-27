//
//  WHIPmHomeViewController.m
//  whisky
//
//  Created by QiuFeng on 4/25/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHIPmHomeViewController.h"
#import "NSDate+Calendar.h"
#import "WHIClient.h"
#import "WHILocationManager.h"
#import "WHIPMData+Manager.h"
#import "WHIDatabaseManager.h"

#import "UIColor+AppColor.h"

#import "WHIHealthKit.h"
#import "WHIMotionManager.h"

#import "WHIUserDefaults.h"
#import "NSDate+Formatter.h"
#import "UIAlertController+WeightController.h"

#import "WHIUser+Manager.h"

#import "WHIShareManager.h"

#import "WHIData+Manager.h"


@import Charts;
@import HealthKit;

@interface WHIPmHomeViewController ()


/**
 *  chart 0
 */

@property (weak, nonatomic) IBOutlet BarChartView *todayPMBreathBarChart;
@property (weak, nonatomic) IBOutlet UIView *todayPMBreathContainerView;

@property (weak, nonatomic) IBOutlet LineChartView *todayTotalPMBreathLineChartView;
@property (weak, nonatomic) IBOutlet UIView *todayBreathPMContainerView;

@property (weak, nonatomic) IBOutlet BarChartView *hourPMBreathBarChartView;
@property (weak, nonatomic) IBOutlet UIView *hourBreathPMContainerView;

@property (weak, nonatomic) IBOutlet BarChartView *weekPMBreathBarChartView;
@property (weak, nonatomic) IBOutlet UIView *weekBreathPMContainerView;
/**
 *  chart 1
 */
@property (weak, nonatomic) IBOutlet LineChartView *todayPMLineChart;
@property (weak, nonatomic) IBOutlet UIView *todayPMContainerView;

@property (weak, nonatomic) IBOutlet LineChartView *hourPMLineChart;
@property (weak, nonatomic) IBOutlet UIView *hourPMContainerView;

@property (weak, nonatomic) IBOutlet BarChartView *todayBreathBarChartView;
@property (weak, nonatomic) IBOutlet UIView *todayBreathContainerView;


@property (weak, nonatomic) IBOutlet BarChartView *hourBreathBarChartView;
@property (weak, nonatomic) IBOutlet UIView *hourBreathContainerView;

@property (weak, nonatomic) IBOutlet LineChartView *todayTotalBreathLineChart;
@property (weak, nonatomic) IBOutlet UIView *todayTotalBreathContainerView;

@property (weak, nonatomic) IBOutlet BarChartView *weekBreathBarChartView;
@property (weak, nonatomic) IBOutlet UIView *weekBreathContainerView;

@property (nonatomic, strong) NSNumberFormatter *decimalAxisFormatter;
@property (nonatomic, strong) NSNumberFormatter *integerAxisFormatter;

@property (nonatomic, strong) NSArray *chart0Views;
@property (nonatomic, strong) NSArray *chart1Views;
@property (nonatomic) NSInteger chart0Index;
@property (nonatomic) NSInteger chart1Index;

@property (weak, nonatomic) IBOutlet UILabel *weekPMBreathLabel;
@property (weak, nonatomic) IBOutlet UILabel *oneHourPMBreathLabel;
@property (weak, nonatomic) IBOutlet UILabel *todayTotalPMBreathLabel;

@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic, strong) NSTimer *autoUpload;
@property (nonatomic, strong) NSTimer *autoSetNotification;

@property (nonatomic, strong) NSDate *nowDate;
@property (nonatomic, strong) NSArray *towHourBreathData;
@property (nonatomic, strong) NSArray *towHourPMData;

@property (nonatomic, strong) NSArray *dayBreathData;
@property (nonatomic, strong) NSArray *dayPMData;

@property (nonatomic, strong) NSArray *weekPmBreath;
@property (nonatomic, strong) NSArray *weekBreath;

@property (weak, nonatomic) IBOutlet UILabel *healthLabel;
@property (weak, nonatomic) IBOutlet UILabel *airLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBarButton;
@end

@implementation WHIPmHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   // [[WHIDatabaseManager sharedManager] showDBLog];
    //定位权限获取
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
        CLLocationManager  *locationManager = [[CLLocationManager alloc] init];
        [locationManager requestAlwaysAuthorization];
        
//        NSLog(@"tried start gps1");
//        [locationManager startUpdatingLocation];
//        NSLog(@"tried start gps");
    }
    //通知权限获取
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        
        // 设置通知的类型可以为弹窗提示,声音提示,应用图标数字提示
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
        // 授权通知
        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    }
    
    [[WHIMotionManager sharedMotionManager] getActivityState];
    
    self.chart0Views = @[self.todayBreathPMContainerView, self.todayPMBreathContainerView,  self.hourBreathPMContainerView, self.weekBreathPMContainerView];
    self.chart1Views = @[self.todayPMContainerView, self.hourPMContainerView, self.todayBreathContainerView,  self.hourBreathContainerView, self.todayTotalBreathContainerView, self.weekBreathContainerView];
    [self startTimer];
 
    [self updateCityLabel];
    
    if ([WHIUserDefaults sharedDefaults].weight == 0) {
        UIAlertController *alert = [UIAlertController whi_showWeightAlertController];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAll) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoUploadPMData) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationEveryday) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateHealthAndAirLabel) name:@"WHIPMChangeNotification" object:nil];
}

- (void)notificationEveryday{
    NSString *city = @"";
    if ([WHIUserDefaults sharedDefaults].addressDetail.city) {
        city = [WHIUserDefaults sharedDefaults].addressDetail.city;
    } else if ([WHIUserDefaults sharedDefaults].addressDetail.province) {
        city = [WHIUserDefaults sharedDefaults].addressDetail.province;
    } else {
        city = @"未知城市";
    }
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [WHIPMData getForecastData:[city substringToIndex:([city length]-1)] complete:^(forecastAirData *result, NSError *_Nullable error){
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        if (nil != notification && ([result.AQI integerValue] > 100))
        {
            // 设置弹出通知的时间
            NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"HH:mm"];
            NSDate *nowDate = [dateFormatter dateFromString:@"19:00"];//[NSDate dateWithTimeIntervalSinceNow:20.0];//
            //设置通知弹出的时间
            notification.fireDate = nowDate;
            //设置重复重复间隔为每天
            notification.repeatInterval = kCFCalendarUnitDay;
            // 设置时区
            notification.timeZone= [NSTimeZone defaultTimeZone];
            //设置提示消息
            if ([UIDevice currentDevice].systemVersion.floatValue >= 8.2) {
                notification.alertTitle = @"明日空气质量提醒";
            }
            notification.alertBody = [NSString stringWithFormat:@"明日AQI为:%@    PM25为:%@",result.AQI, result.PM25];
            // 设置启动通知的声音
            notification.soundName = UILocalNotificationDefaultSoundName;
            // 启动通知
            notification.hasAction = YES;
            notification.alertLaunchImage = @"111";
            notification.applicationIconBadgeNumber = 0;
            notification.alertAction = @"查看";
            [[UIApplication sharedApplication]scheduleLocalNotification:notification];
            NSLog(@"notification 启动成功");
        }
    }];
}

- (void)startTimer {
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:120 target:self selector:@selector(updateAll) userInfo:nil repeats:YES];
    [self.updateTimer fire];
    
    self.autoUpload = [NSTimer scheduledTimerWithTimeInterval:1800 target:self selector:@selector(autoUploadPMData) userInfo:nil repeats:YES];
    self.autoSetNotification = [NSTimer scheduledTimerWithTimeInterval:43200 target:self selector:@selector(notificationEveryday) userInfo:nil repeats:YES];
    [self.autoUpload fire];
    [self.autoSetNotification fire];
}

- (void)updateHealthAndAirLabel {
    WHIData *data = [WHIGlobal sharedGlobal].pmData;
    if (data) {
        double outDoorPm = data.pm25_concen;
        if (!data.outdoor) {
            outDoorPm = outDoorPm * 2;
        }

        if (outDoorPm < 50) {
            self.airLabel.text = @"空气质量优";
            self.healthLabel.text = @"适合户外活动";
            self.airLabel.textColor = [UIColor greenColor];
            self.healthLabel.textColor = [UIColor greenColor];
        } else if (outDoorPm < 100) {
            self.airLabel.text = @"空气质量良";
            self.healthLabel.text = @"易感人群减少户外活动";
            self.airLabel.textColor = [UIColor yellowColor];
            self.healthLabel.textColor = [UIColor yellowColor];
        } else if (outDoorPm < 150) {
            self.airLabel.text = @"轻度污染";
            self.healthLabel.text = @"适量减少户外活动";
            self.airLabel.textColor = [UIColor orangeColor];
            self.healthLabel.textColor = [UIColor orangeColor];
        } else if (outDoorPm < 200) {
            self.airLabel.text = @"中度污染";
            self.healthLabel.text = @"避免户外活动";
            self.airLabel.textColor = [UIColor redColor];
            self.healthLabel.textColor = [UIColor whi_colorWithHex:0x8B572A];
        } else if (outDoorPm < 250) {
            self.airLabel.text = @"重度污染";
            self.healthLabel.text = @"避免户外活动";
            self.airLabel.textColor = [UIColor whi_colorWithHex:0x8B572A];
            self.healthLabel.textColor = [UIColor whi_colorWithHex:0x8B572A];
        } else {
            self.airLabel.text = @"严重污染";
            self.healthLabel.text = @"避免户外活动";
            self.airLabel.textColor = [UIColor blackColor];
            self.healthLabel.textColor = [UIColor whi_colorWithHex:0x8B572A];
        }
    }
}

- (void)updateCityLabel {
    if ([WHIUserDefaults sharedDefaults].addressDetail.city) {
        self.navigationItem.title = [WHIUserDefaults sharedDefaults].addressDetail.city;
    } else if ([WHIUserDefaults sharedDefaults].addressDetail.province) {
        self.navigationItem.title = [WHIUserDefaults sharedDefaults].addressDetail.province;
    } else {
        self.navigationItem.title = @"未知城市";
    }
}

- (void)updateCity {
    [[WHILocationManager sharedManager] getCurrentCityWithBlock:^(CLLocation *location, NSError *error) {
        [self updateCityLabel];
    }];
}

- (void)updateHourChart {
    [self updateHourBreathData];
    [self updateHourPMData];
}

- (void)updateTodayChart {
    [self updateTodayBreathData];
    [self updateTodayPMData];
    [self updateTodayTotalBreathData];
    [self updateTodayTotalBreathPMData];
}

- (void)updateWeekChart {
    [self updateWeekBreathData];
    [self updateWeekBreathPMData];
}

- (BarChartDataSet *)convertToBarChart:(NSArray *)data {
    NSMutableArray *chartData = [NSMutableArray array];
    for (int i = 0; i < data.count; i++) {
        [chartData addObject:[[BarChartDataEntry alloc] initWithValue:[data[i] doubleValue] xIndex:i]];
    }
    BarChartDataSet *set = [[BarChartDataSet alloc] initWithYVals:chartData label:nil];
    set.drawValuesEnabled = NO;
    set.valueFormatter = self.decimalAxisFormatter;
    return set;
}

- (LineChartDataSet *)convertToLineChart:(NSArray *)data {
    NSMutableArray *chartData = [NSMutableArray array];
    for (int i = 0; i < data.count; i++) {
        [chartData addObject:[[ChartDataEntry alloc] initWithValue:[data[i] doubleValue] xIndex:i]];
    }
    LineChartDataSet *set = [[LineChartDataSet alloc] initWithYVals:chartData label:nil];
    set.drawCirclesEnabled = NO;
    set.drawValuesEnabled = NO;
    set.valueFormatter = self.decimalAxisFormatter;
    return set;
}

- (NSArray *)twoHourAxis {
    NSInteger timerCount = [self.nowDate timeIntervalSinceDate:[self.nowDate dateByAddingHour:-2]] / kHourInterval;
    NSMutableArray *result = [NSMutableArray array];
    for (int i = 0; i < timerCount; i++) {
        [result addObject:[NSString stringWithFormat:@"%d", i * 5]];
    }
    return result;
}

- (NSArray *)dayAxis {
    NSInteger timerCount = [self.nowDate timeIntervalSinceDate:[self.nowDate dateToday]] / kToDayInterval;
    NSMutableArray *result = [NSMutableArray array];
    for (int i = 0; i < timerCount; i++) {
        NSDate *date = [NSDate dateWithTimeInterval:i * kToDayInterval sinceDate:[self.nowDate dateToday]];
        [result addObject:[date whi_xAxisString]];
    }
    return result;
}

- (NSArray *)weekAxis {
    NSMutableArray *result = [NSMutableArray array];
    for (int i = 1; i <= 7; i++) {
        NSDate *date = [self.nowDate dateByAddingDays:i-7];
        [result addObject:[date whi_dateWithFormat:@"MM-dd"]];
    }
    return result;
}

- (void)updateAll {
    self.navigationItem.prompt = @"刷新中";
    [self updateCity];
    
    self.nowDate = [NSDate date];
    [[WHIDatabaseManager sharedManager] getTwoHourData:self.nowDate complete:^(NSArray * _Nonnull breath, NSArray * _Nonnull pm) {
        self.towHourPMData = pm;
        self.towHourBreathData = breath;
        [self updateHourPMData];
        [self updateHourBreathData];
        [self updateHourBreathPMData];
    }];
    
    [[WHIDatabaseManager sharedManager] getTodayData:self.nowDate complete:^(NSArray * _Nonnull breath, NSArray * _Nonnull pm) {
        self.dayPMData = pm;
        self.dayBreathData = breath;
        [self updateTodayTotalBreathData];
        [self updateTodayBreathData];
        [self updateTodayPMData];
        [self updateTodayBreathPMData];
        [self updateTodayTotalBreathPMData];
    }];
    
    [self updateOneHourPMBreath];
    
    [self updateWeek:^(NSArray *breath, NSArray *pmBreath) {
        self.weekBreath = breath;
        self.weekPmBreath = pmBreath;
        [self updateWeekChart];
        self.navigationItem.prompt = @"生态 健康 生活";
    }];
}

- (void)updateWeek:(void (^)(NSArray *breath, NSArray *pmBreath))complete {
    dispatch_async(dispatch_queue_create("WeekTotalPMBreath", nil), ^{
        dispatch_group_t group = dispatch_group_create();
        NSMutableArray *breathResult = [NSMutableArray array];
        NSMutableArray *pmBreathResult = [NSMutableArray array];
        
        for (int i = 0; i < 7; i++) {
            [breathResult addObject:@(0)];
            [pmBreathResult addObject:@(0)];
        }
        
        for (int i = 0; i < 7; i++) {
            dispatch_group_enter(group);
            NSDate *date = [self.nowDate dateByAddingDays:-(7 - i - 1)];
            NSDate *endDate = [[[date dateToday] dateByAddingDays:1] dateByAddingSecond:-1];
            if ([endDate timeIntervalSinceDate:self.nowDate] > 0) {
                endDate = self.nowDate;
            }
           
            [[WHIDatabaseManager sharedManager] getTodayData:endDate complete:^(NSArray * _Nonnull breath, NSArray * _Nonnull pm) {
                double value = 0;
                double breahValue = 0;
                for (int j = 0; j < MIN(breath.count, pm.count); j++) {
                    value = value + [breath[j] doubleValue] * [pm[j] doubleValue] / 1000 * kToDayInterval / 60;
                    breahValue = breahValue + [breath[j] doubleValue];
                }
                [pmBreathResult replaceObjectAtIndex:i withObject:@(value)];
                [breathResult replaceObjectAtIndex:i withObject:@(breahValue)];
                dispatch_group_leave(group);
            }];
        }
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(breathResult, pmBreathResult);
        });
    });

}

- (void)updateOneHourPMBreath {
    NSDate *date = [NSDate date];
    [[WHIDatabaseManager sharedManager] getHourData:date complete:^(NSArray *breath, NSArray *pm) {
        double value = 0;
        for (int i = 0; i < MIN(breath.count, pm.count); i++) {
            value = value + [breath[i] doubleValue] * [pm[i] doubleValue] / 1000 * kHourInterval / 60;
        }
        self.oneHourPMBreathLabel.text = [NSString stringWithFormat:@"%.1f 微克", value];
    }];
}

- (void)updateTodayTotalBreathData {
    NSMutableArray *totalBreath = [NSMutableArray array];
    for (int i = 0; i < self.dayBreathData.count; i++) {
        double value = [self.dayBreathData[i] doubleValue];
        if (i > 0) {
            value = value + [totalBreath[i - 1] doubleValue];
            [totalBreath addObject:@(value)];
        } else {
            [totalBreath addObject:@(value)];
        }
    }
    LineChartDataSet *set = [self convertToLineChart:totalBreath];
    self.todayTotalBreathLineChart.data = [[LineChartData alloc] initWithXVals:[self dayAxis] dataSets:@[set]];
}

- (void)updateTodayBreathData {
    BarChartDataSet *set = [self convertToBarChart:self.dayBreathData];
    self.todayBreathBarChartView.data = [[BarChartData alloc] initWithXVals:[self dayAxis] dataSets:@[set]];
}

- (void)updateTodayPMData {
    LineChartDataSet *set = [self convertToLineChart:self.dayPMData];
    self.todayPMLineChart.data = [[LineChartData alloc] initWithXVals:[self dayAxis] dataSets:@[set]];
}

- (void)updateHourPMData {
    LineChartDataSet *set = [self convertToLineChart:self.towHourPMData];
    self.hourPMLineChart.data = [[LineChartData alloc] initWithXVals:[self twoHourAxis] dataSets:@[set]];
}

- (void)updateHourBreathData {
    BarChartDataSet *set = [self convertToBarChart:self.towHourBreathData];
    self.hourBreathBarChartView.data = [[BarChartData alloc] initWithXVals:[self twoHourAxis] dataSets:@[set]];
}

- (void)updateHourBreathPMData {
    NSMutableArray *pmBreath = [NSMutableArray array];
    for (int i = 0; i < MIN(self.towHourBreathData.count, self.towHourPMData.count); i++) {
        double value = [self.towHourPMData[i] doubleValue] * [self.towHourPMData[i] doubleValue] / 1000 * kHourInterval / 60;
        [pmBreath addObject:@(value)];
    }
    
    BarChartDataSet *set = [self convertToBarChart:pmBreath];
    self.hourPMBreathBarChartView.data = [[BarChartData alloc] initWithXVals:[self twoHourAxis] dataSets:@[set]];
}

- (void)updateTodayBreathPMData {
    NSMutableArray *pmBreath = [NSMutableArray array];
    for (int i = 0; i < MIN(self.dayBreathData.count, self.dayPMData.count); i++) {
        double value = [self.dayBreathData[i] doubleValue] * [self.dayPMData[i] doubleValue] / 1000 * kToDayInterval / 60;
        [pmBreath addObject:@(value)];
    }
    
    BarChartDataSet *set = [self convertToBarChart:pmBreath];
    self.todayPMBreathBarChart.data = [[BarChartData alloc] initWithXVals:[self dayAxis] dataSets:@[set]];
}

- (void)updateTodayTotalBreathPMData {
    NSMutableArray *pmBreath = [NSMutableArray array];
    for (int i = 0; i < MIN(self.dayBreathData.count, self.dayPMData.count) ; i++) {
        double value =[self.dayBreathData[i] doubleValue] * [self.dayPMData[i] doubleValue] / 1000 * kToDayInterval / 60;
        if (i > 0) {
            value = value + [pmBreath[i - 1] doubleValue];
            [pmBreath addObject:@(value)];
        } else {
            [pmBreath addObject:@(value)];
        }
    }
    LineChartDataSet *set = [self convertToLineChart:pmBreath];
    self.todayTotalPMBreathLineChartView.data = [[LineChartData alloc] initWithXVals:[self dayAxis] dataSets:@[set]];
    if (pmBreath.lastObject) {
        self.todayTotalPMBreathLabel.text = [NSString stringWithFormat:@"%.1f 微克", [[pmBreath lastObject] doubleValue]];
    }
}

- (void)updateWeekBreathData {
    BarChartDataSet *set = [self convertToBarChart:self.weekBreath];
    self.weekBreathBarChartView.data = [[BarChartData alloc] initWithXVals:[self weekAxis] dataSets:@[set]];
}

- (void)updateWeekBreathPMData {
    double average = 0;
    int count = 0;
    for (NSNumber *pmBreath in self.weekPmBreath) {
        if ([pmBreath doubleValue] > 0) {
            average += [pmBreath doubleValue];
            count = count + 1;
        }
    }
    if (count > 0) {
        average = average / count;
    }
    
    self.weekPMBreathLabel.text = [NSString stringWithFormat:@"%.1f 微克", average];
    BarChartDataSet *set = [self convertToBarChart:self.weekPmBreath];
    self.weekPMBreathBarChartView.data = [[BarChartData alloc] initWithXVals:[self weekAxis] dataSets:@[set]];
}

#pragma mark - Accessors

- (void)configLineChart:(LineChartView *)chart {
    chart.descriptionText = @"";
    chart.leftAxis.axisMinValue = 0;
    chart.rightAxis.enabled = NO;
    chart.xAxis.labelPosition = XAxisLabelPositionBottom;
    chart.leftAxis.forceLabelsEnabled = YES;
    chart.noDataText = @"";
    chart.drawMarkers = YES;
    chart.legend.enabled = NO;
}

- (void)configBarChart:(BarChartView *)chart {
    chart.descriptionText = @"";
    chart.leftAxis.axisMinValue = 0;
    chart.rightAxis.enabled = NO;
    chart.xAxis.labelPosition = XAxisLabelPositionBottom;
    chart.leftAxis.forceLabelsEnabled = YES;
    chart.noDataText = @"";
    chart.legend.enabled = NO;
}

- (NSNumberFormatter *)decimalAxisFormatter {
    if (_decimalAxisFormatter == nil) {
        _decimalAxisFormatter = [[NSNumberFormatter alloc] init];
        _decimalAxisFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        _decimalAxisFormatter.maximumFractionDigits = 1;
    }
    return _decimalAxisFormatter;
}

- (NSNumberFormatter *)integerAxisFormatter {
    if (_integerAxisFormatter == nil) {
        _integerAxisFormatter = [[NSNumberFormatter alloc] init];
        _integerAxisFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        _integerAxisFormatter.maximumFractionDigits = 0;
    }
    return _integerAxisFormatter;
}

- (void)setTodayPMLineChart:(LineChartView *)todayPMLineChart {
    if (_todayPMLineChart != todayPMLineChart) {
        _todayPMLineChart = todayPMLineChart;
        [self configLineChart:_todayPMLineChart];
        _todayPMLineChart.leftAxis.valueFormatter = self.integerAxisFormatter;
    }
}

- (void)setTodayPMBreathBarChart:(BarChartView *)todayPMBreathBarChart {
    if (_todayPMBreathBarChart != todayPMBreathBarChart) {
        _todayPMBreathBarChart = todayPMBreathBarChart;
        [self configBarChart:_todayPMBreathBarChart];
        _todayPMBreathBarChart.leftAxis.valueFormatter = self.decimalAxisFormatter;
    }
}

- (void)setTodayTotalPMBreathLineChartView:(LineChartView *)todayTotalPMBreathLineChartView {
    if (_todayTotalPMBreathLineChartView != todayTotalPMBreathLineChartView) {
        _todayTotalPMBreathLineChartView = todayTotalPMBreathLineChartView;
        [self configLineChart:_todayTotalPMBreathLineChartView];
        _todayTotalPMBreathLineChartView.leftAxis.valueFormatter = self.integerAxisFormatter;
    }
}

- (void)setHourPMBreathBarChartView:(BarChartView *)hourPMBreathBarChartView {
    if (_hourPMBreathBarChartView != hourPMBreathBarChartView) {
        _hourPMBreathBarChartView = hourPMBreathBarChartView;
        [self configBarChart:_hourPMBreathBarChartView];
        _hourPMBreathBarChartView.leftAxis.valueFormatter = self.decimalAxisFormatter;
    }
}

- (void)setWeekPMBreathBarChartView:(BarChartView *)weekPMBreathBarChartView {
    if (_weekPMBreathBarChartView != weekPMBreathBarChartView) {
        _weekPMBreathBarChartView = weekPMBreathBarChartView;
        [self configBarChart:_weekPMBreathBarChartView];
        _weekPMBreathBarChartView.leftAxis.valueFormatter = self.integerAxisFormatter;
    }
}

- (void)setHourPMLineChart:(LineChartView *)hourPMLineChart {
    if (_hourPMLineChart != hourPMLineChart) {
        _hourPMLineChart = hourPMLineChart;
        [self configLineChart:_hourPMLineChart];
        _hourPMLineChart.leftAxis.valueFormatter = self.integerAxisFormatter;
    }
}

- (void)setTodayBreathBarChartView:(BarChartView *)todayBreathBarChartView {
    if (_todayBreathBarChartView != todayBreathBarChartView) {
        _todayBreathBarChartView = todayBreathBarChartView;
        [self configBarChart:_todayBreathBarChartView];
        _todayBreathBarChartView.leftAxis.valueFormatter = self.integerAxisFormatter;
    }
}

- (void)setHourBreathBarChartView:(BarChartView *)hourBreathBarChartView {
    if (_hourBreathBarChartView != hourBreathBarChartView) {
        _hourBreathBarChartView = hourBreathBarChartView;
        [self configBarChart:_hourBreathBarChartView];
        _hourBreathBarChartView.leftAxis.valueFormatter = self.integerAxisFormatter;
    }
}

- (void)setTodayTotalBreathLineChart:(LineChartView *)todayTotalBreathLineChart {
    if (_todayTotalBreathLineChart != todayTotalBreathLineChart) {
        _todayTotalBreathLineChart = todayTotalBreathLineChart;
        [self configLineChart:_todayTotalBreathLineChart];
        _todayTotalBreathLineChart.leftAxis.valueFormatter = self.integerAxisFormatter;
    }
}

- (void)setWeekBreathBarChartView:(BarChartView *)weekBreathBarChartView {
    if (_weekBreathBarChartView != weekBreathBarChartView) {
        _weekBreathBarChartView = weekBreathBarChartView;
        [self configBarChart:_weekBreathBarChartView];
        _weekBreathBarChartView.leftAxis.valueFormatter = self.integerAxisFormatter;
    }
}

#pragma mark - Action

- (IBAction)refreshBarButtonTouchUpInSide:(UIBarButtonItem *)sender {
    [self updateAll];
}

- (IBAction)change0ButtonTouchUpInSide:(UIButton *)sender {
    for (UIView *view in self.chart0Views) {
        view.hidden = YES;
    }
    self.chart0Index = (self.chart0Index + 1) % self.chart0Views.count;
    [(UIView *)self.chart0Views[self.chart0Index] setHidden:NO];
}

- (IBAction)change1ButtonTouchUpInSide:(UIButton *)sender {
    for (UIView *view in self.chart1Views) {
        view.hidden = YES;
    }
    self.chart1Index = (self.chart1Index + 1) % self.chart1Views.count;
    [(UIView *)self.chart1Views[self.chart1Index] setHidden:NO];
}

- (IBAction)shareBarButtonTouchUpInside:(UIBarButtonItem *)sender {
    UIImage *image = [self viewSnapshot:self.view withInRect:self.view.bounds];
    WHIShareManager *manager = [WHIShareManager sharedManager];
    [manager setupImage:image view:self];
//    [WHIShareManager shareImage:image onStateChange:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
//        
//    }];
}

- (UIImage *)viewSnapshot:(UIView *)view withInRect:(CGRect)rect;
{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    image = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(image.CGImage,rect)];
    return image;
}

- (void)autoUploadPMData {
    if ([WHIUserDefaults sharedDefaults].autoUpload) {
        [[WHIDatabaseManager sharedManager] queryForUnUploadData:500 complete:^(NSArray * result) {
//            NSLog(@"result is %@", result);
            [WHIData upload:result complete:^(NSArray * _Nullable array, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"upload error");
                } else {
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
