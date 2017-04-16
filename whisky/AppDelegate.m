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
    [application setApplicationIconBadgeNumber:0];
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
    if (userLocation) {
        [WHIUserDefaults sharedDefaults].lastLocation = userLocation;
    } else {
        userLocation = [WHIUserDefaults sharedDefaults].lastLocation;
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

- (void)getStepsByStartDate:(NSDate *)startDate andCurrentDate:(NSDate *)currentDate
{
    [[WHIHealthKit sharedHealthKit] queryStepCount:startDate endDate:currentDate complete:^(double stepCount, BOOL succeed){
        if (succeed){
            NSLog(@" steps is %f",stepCount);
        }
    }];
}

@end
