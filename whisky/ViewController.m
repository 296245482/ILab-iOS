//
//  ViewController.m
//  whisky
//
//  Created by QiuFeng on 3/21/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "ViewController.h"
#import "WHILocationManager.h"
#import "WHIClient.h"

@interface ViewController () <CLLocationManagerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [[WHILocationManager sharedManager] requestAlwaysAuthorization];
//    [WHILocationManager sharedManager].delegate = self;
//    [[WHILocationManager sharedManager] startUpdatingLocation];
    [[WHILocationManager sharedManager] getCurrentCityWithBlock:^(CLLocation *location, NSError *error) {
        NSDictionary *params = @{@"longitude": @(location.coordinate.longitude),
                                 @"latitude": @(location.coordinate.latitude)};
        [[WHIClient sharedClient] get:@"urban-airs/search" parameters:params complete:^(id  _Nullable result, NSError * _Nullable error) {
            
        }];
    }];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - <CLLocationManagerDelegate>

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = locations[0];
    CLLocationCoordinate2D coordinate=location.coordinate;
    DDLogDebug(@"经度：%f，纬度：%f, time:%@", coordinate.longitude, coordinate.latitude, [NSDate date]);
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if ([error code] == kCLErrorDenied) {
        DDLogDebug(@"访问被拒绝");
    }
    if ([error code] == kCLErrorLocationUnknown) {
        DDLogDebug(@"无法获取位置信息");
    }
}

@end
