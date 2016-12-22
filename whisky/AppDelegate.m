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

#import "WHIUdpSocket.h"

#import "WHIData+Manager.h"
#import "WHIUser+Manager.h"

#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocial.h"
#import "UMSocialSinaSSOHandler.h"
#import <Bugtags/Bugtags.h>
#import <UMMobClick/MobClick.h>

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
    
    NSString *app_version = @"iOS.2016.12.21";
    
    
    NSDate *nowDate = [NSDate date];
    
    if (userLocation) {
        [WHIUserDefaults sharedDefaults].lastLocation = userLocation;
    } else {
        userLocation = [WHIUserDefaults sharedDefaults].lastLocation;
    }
//    NSLog(@"tried ");
    if (userLocation && (self.lastDate == nil || [nowDate timeIntervalSinceDate:_lastDate] > queryTimerDutaion)) {
        
        self.lastDate = nowDate;
        
        [[WHIUdpSocket sharedManager] trySend];
        
        NSString *deviceId = [WHIUdpSocket sharedManager].deviceId;
        NSLog(@"device id is %@", deviceId);
        if (deviceId) {
            [WHIPMData getPMDataByDevice:deviceId date:nowDate complete:^(WHIPMData *result, NSError * _Nullable error) {
                WHIData *data = [[WHIData alloc] init];
                
                data.user_id = [WHIUser currentUser].objectId ?: @"";;
                data.database_access_token = [WHIUserDefaults sharedDefaults].token;
                data.ventilation_vol = 12345;
                data.pm25_intake = 12345;
                data.pm25_monitor = deviceId;
                data.APP_version = app_version;
                data.connection = 1;
                
                data.time_point = nowDate;
                data.outdoor = NO;
                if (result) {
                    data.pm25_concen = [result.PM25 doubleValue];
                    if (!data.outdoor) {
                        data.pm25_concen = data.pm25_concen / 2;
                    }
                }
                
                data.longitude = userLocation.coordinate.longitude;
                data.latitude = userLocation.coordinate.latitude;
                data.pm25_datasource = 2;
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
                [WHIGlobal sharedGlobal].pmData = data;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"WHIPMChangeNotification" object:nil];
                [[WHIDatabaseManager sharedManager] insertData:data complete:^(BOOL success) {
                }];

            }];
        } else {
            [WHIPMData getPMData:userLocation.coordinate complete:^(WHIPMData *result, NSError * _Nullable error) {
                WHIData *data = [[WHIData alloc] init];
                
                data.user_id = [WHIUser currentUser].objectId ?: @"";;
                data.database_access_token = [WHIUserDefaults sharedDefaults].token ?: @"";
                data.ventilation_vol = 12345;
                data.pm25_intake = 12345;
                data.pm25_monitor = deviceId;
                data.APP_version = app_version;
                data.connection = 1;
                
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
                data.pm25_datasource = 1;
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
                [WHIGlobal sharedGlobal].pmData = data;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"WHIPMChangeNotification" object:nil];
                
//                NSLog(@"data insert is %@",data);
                
                [[WHIDatabaseManager sharedManager] insertData:data complete:^(BOOL success) {
                    if (success) {
                        NSLog(@"insert success");
                    }else{
                        NSLog(@"insert failed");
                    }
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

@end
