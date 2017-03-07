//
//  AppDelegate.m
//  whisky
//
//  Created by QiuFeng on 3/21/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//



#import "AppDelegate.h"
#import "WHIDatabaseManager.h"
#import "WHILocationManager.h"
#import "WHIPMData+Manager.h"
#import "WHIUserDefaults.h"
#import "WHIMotionManager.h"
#import "WHIData.h"
#import "WHIHealthKit.h"

#import "WHIUdpSocket.h"

#import "WHIData+Manager.h"
#import "WHIUser+Manager.h"
#import "NSDate+Formatter.h"

#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocial.h"
#import "UMSocialSinaSSOHandler.h"
#import <Bugtags/Bugtags.h>
#import <UMMobClick/MobClick.h>

#import<SystemConfiguration/CaptiveNetwork.h>
#import<SystemConfiguration/SystemConfiguration.h>
#import<CoreFoundation/CoreFoundation.h>


@interface AppDelegate ()<WHILocationManagerDelegate>

@property (nonatomic, strong) NSDate *lastDate;

@end

@implementation AppDelegate 

- (void)setupUmengShare {
    [UMSocialData setAppKey:@"566d299367e58e44cb005fe2"];
    [UMSocialWechatHandler setWXAppId:@"wx24d29d8146699834" appSecret:@"2dfbce45b493fde58d7075d7d2aed5fd" url:@"http://www.umeng.com/social"];
    [UMSocialQQHandler setQQWithAppId:@"1105441222" appKey:@"YEpt4ZU3DfiJeNbH" url:@"http://www.umeng.com/social"];
    [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:@"3921700954"
                                              secret:@"04b48b094faeb16683c32669824ebdad"
                                         RedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self setupThirdPart:launchOptions];
    [self setupUmengShare];
    [WHILocationManager sharedManager].delegate = self;
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[WHIDatabaseManager sharedManager] deleteOverDueData:nil];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL result = [UMSocialSnsService handleOpenURL:url];
    return result;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    BOOL result = [UMSocialSnsService handleOpenURL:url];
    return result;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)locationManager:(WHILocationManager *)manager didUpdateBMKUserLocation:(CLLocation *)userLocation {
    
    NSString *app_version = @"iOS.2017.02.21";
    
    
    NSDate *nowDate = [NSDate date];
    
    if (userLocation) {
        [WHIUserDefaults sharedDefaults].lastLocation = userLocation;
    } else {
        userLocation = [WHIUserDefaults sharedDefaults].lastLocation;
    }
    if (userLocation && (self.lastDate == nil || [nowDate timeIntervalSinceDate:_lastDate] > queryTimerDutaion)) {
        
        double timePass = [nowDate timeIntervalSinceDate:_lastDate];
        if(isnan(timePass)){
            timePass = queryTimerDutaion;
        }
        
//        使用udp广播获得数据
//        [[WHIUdpSocket sharedManager] trySend];
//        NSString *deviceId = [WHIUdpSocket sharedManager].deviceId;
        
        NSString *wifiName = [self getWifiName];
        NSString *deviceId = NULL;
        deviceId = [[WHIDatabaseManager sharedManager]queryForDeviceId:wifiName];

        if (deviceId) {
            //查询到有805设备
            [WHIPMData getPMDataByDevice:deviceId date:nowDate complete:^(WHIPMData *result, NSError * _Nullable error) {
                [[WHIHealthKit sharedHealthKit] queryStepCount:_lastDate endDate:nowDate complete:^(double stepCount, BOOL succeed){
                    [WHIPMData getPMData:userLocation.coordinate complete:^(WHIPMData *locationResult, NSError * _Nullable error) {
                        self.lastDate = nowDate;
                        
                        WHIData *data = [[WHIData alloc] init];
                        //处理805最后一条数据的时间
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        NSDate *lastRecordTime = [[NSDate alloc]init];
                        lastRecordTime = [dateFormatter dateFromString:result.lastRecordTime];
                        if((!result.PM25) || ([nowDate timeIntervalSince1970] - [lastRecordTime timeIntervalSince1970]) >  deviceExpireTime){
                            //805设备号无效或者数据过期
                            NSLog(@"805 is not usable");
                            data.outdoor = ![AFNetworkReachabilityManager sharedManager].isReachableViaWiFi;
                            if (locationResult) {
                                data.pm25_concen = [locationResult.PM25 doubleValue];
                                if (!data.outdoor) {
                                    data.pm25_concen = data.pm25_concen / 2;
                                }
                            }
                            data.pm25_datasource = result.source;
                        }else {
                            //805可用
                            data.pm25_monitor = deviceId;
                            data.outdoor = NO;
                            data.pm25_concen = [result.PM25 doubleValue];
                            data.pm25_datasource = 3;
                        }
                        if (succeed){
                            NSLog(@" steps is %f",stepCount);
                            data.steps = stepCount;
                        }else{
                            NSLog(@"获取步数失败");
                        }
                        
                        data.user_id = [WHIUser currentUser].objectId ?: @"";;
                        data.database_access_token = [WHIUserDefaults sharedDefaults].token;
                        data.APP_version = app_version;
                        data.connection = [AFNetworkReachabilityManager sharedManager].isReachable;
                        data.time_point = nowDate;
                        data.longitude = userLocation.coordinate.longitude;
                        data.latitude = userLocation.coordinate.latitude;
                        
                        data.status = [[WHIMotionManager sharedMotionManager] getActivityState];
                        double weight = [WHIUserDefaults sharedDefaults].weight;
                        double baseBreath = 7.8 * weight * 13 / 1000;
                        switch (data.status) {
                            case WHIMotionStateStationary: {
                                break;
                            }
                            case WHIMotionStateWalk: {
                                baseBreath = baseBreath * 2.1;
                                break;
                            }
                            case WHIMotionStateRunning: {
                                baseBreath = baseBreath * 6;
                                break;
                            }
                            case WHIMotionStateBiking: {
                                baseBreath = baseBreath * 2.1;
                                break;
                            }
                        }
                        data.ventilation_rate = baseBreath;
                        data.ventilation_vol = (baseBreath * timePass) / 60;
                        data.pm25_intake = data.pm25_concen * data.ventilation_vol/1000000;
                        
                        NSLog(@"data is %@",data);
                        [WHIGlobal sharedGlobal].pmData = data;
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"WHIPMChangeNotification" object:nil];
                        [[WHIDatabaseManager sharedManager] insertData:data complete:^(BOOL success) {
                            if (success) {
                                NSLog(@"有805设备号分支 insert success");
                            }else{
                                NSLog(@"insert failed");
                            }
                        }];
                    }];
                }];
            }];
        } else {
            [WHIPMData getPMData:userLocation.coordinate complete:^(WHIPMData *result, NSError * _Nullable error) {
                [[WHIHealthKit sharedHealthKit] queryStepCount:_lastDate endDate:nowDate complete:^(double stepCount, BOOL succeed){
                    self.lastDate = nowDate;
                    WHIData *data = [[WHIData alloc] init];
                    if (succeed){
                        NSLog(@" steps is %f",stepCount);
                        data.steps = stepCount;
                    }else{
                        NSLog(@"获取步数失败");
                    }
                    
                    data.user_id = [WHIUser currentUser].objectId ?: @"";;
                    data.database_access_token = [WHIUserDefaults sharedDefaults].token ?: @"";
                    data.pm25_monitor = deviceId;
                    data.APP_version = app_version;
                    data.connection = [AFNetworkReachabilityManager sharedManager].isReachable;
                    
                    data.time_point = nowDate;
                    data.outdoor = ![AFNetworkReachabilityManager sharedManager].isReachableViaWiFi;
                    if (result) {
                        data.pm25_concen = [result.PM25 doubleValue];
                        if (!data.outdoor) {
                            data.pm25_concen = data.pm25_concen / 2;
                        }
                    }
                    
                    data.longitude = userLocation.coordinate.longitude;
                    data.latitude = userLocation.coordinate.latitude;
                    data.pm25_datasource = result.source;
                    data.status = [[WHIMotionManager sharedMotionManager] getActivityState];
                    double weight = [WHIUserDefaults sharedDefaults].weight;
                    double baseBreath = 7.8 * weight * 13 / 1000;
                    switch (data.status) {
                        case WHIMotionStateStationary: {
                            break;
                        }
                        case WHIMotionStateWalk: {
                            baseBreath = baseBreath * 2.1;
                            break;
                        }
                        case WHIMotionStateRunning: {
                            baseBreath = baseBreath * 6;
                            break;
                        }
                        case WHIMotionStateBiking: {
                            baseBreath = baseBreath * 2.1;
                            break;
                        }
                    }
                    data.ventilation_rate = baseBreath;
                    data.ventilation_vol = (baseBreath * timePass) / 60;
                    data.pm25_intake = data.pm25_concen * data.ventilation_vol/1000000;
                    
                    NSLog(@"data is %@",data);
                    [WHIGlobal sharedGlobal].pmData = data;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"WHIPMChangeNotification" object:nil];
                    [[WHIDatabaseManager sharedManager] insertData:data complete:^(BOOL success) {
                        if (success) {
                            NSLog(@"用户定位数据查询分支insert success");
                        }else{
                            NSLog(@"insert failed");
                        }
                    }];
                }];
            }];
        }
        
    }
}

- (void)setupThirdPart:(NSDictionary *)launchOptions {
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
    [SVProgressHUD setMinimumDismissTimeInterval:1];
    
    setenv("XcodeColors", "YES", 0);
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDTTYLogger sharedInstance].colorsEnabled = YES;
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor whi_appMainColor] backgroundColor:nil forFlag:DDLogFlagDebug];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor whi_colorWithHex:0xCA2BB6] backgroundColor:nil forFlag:DDLogFlagInfo];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor whi_colorWithHex:0x8B572A] backgroundColor:nil forFlag:DDLogFlagVerbose];
    UMConfigInstance.appKey = @"	577b2ca467e58e2274002414";
    UMConfigInstance.channelId = @"App Store";
    [Bugtags startWithAppKey:@"59656cb945c12c0419c217850fc63efe" invocationEvent:BTGInvocationEventNone];
}

- (NSString *)getWifiName{
    NSString *wifiName = NULL;
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict =CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            wifiName = [dict valueForKey:@"SSID"];
        }
//        NSLog(@"wifiName:%@", wifiName);
    }
    return wifiName;
}

- (void)getStepsByStartDate:(NSDate *)startDate andCurrentDate:(NSDate *)currentDate
{
    [[WHIHealthKit sharedHealthKit] queryStepCount:startDate endDate:currentDate complete:^(double stepCount, BOOL succeed){
        if (succeed){
            NSLog(@" steps is %f",stepCount);
        }
    }];
}

@end
