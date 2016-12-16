//
//  WHILocationManager.m
//  whisky
//
//  Created by QiuFeng on 4/22/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHILocationManager.h"
#import "WHIUserDefaults.h"


@interface WHILocationManager () <BMKGeoCodeSearchDelegate, BMKLocationServiceDelegate, BMKGeneralDelegate>

@property (nonatomic, strong) BMKLocationService *locService;
@property (nonatomic, strong) BMKGeoCodeSearch *geocodesearch;

@property (nonatomic, copy) WHIReverseGeoCodeCallback reverseGeoCodeCallBack;
@property (nonatomic, copy) WHILocationCallback coordinateCallBack;

@property (nonatomic, strong) BMKReverseGeoCodeResult *reverseGeoCodeResult;

@property (nonatomic, strong) BMKMapManager *bmkMapManager;

@end

@implementation WHILocationManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static id manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.bmkMapManager = [[BMKMapManager alloc] init];
        BOOL res = [self.bmkMapManager start:@"opVCwcukovz38pMGfxaB1lUwgvOo7mG3" generalDelegate:self];
//        BOOL res = [self.bmkMapManager start:@"RGS0VWvo4GBzr2shrqVwt4caFj69yuQu" generalDelegate:self];
        if (!res) {
            DDLogDebug(@"manager start failed!");
        }else{
            NSLog(@"tried location started");
        }
        self.geocodesearch = [[BMKGeoCodeSearch alloc] init];
        self.geocodesearch.delegate = self;
        self.locService = [[BMKLocationService alloc] init];
        self.locService.delegate = self;
        self.locService.pausesLocationUpdatesAutomatically = NO;
        self.locService.allowsBackgroundLocationUpdates = YES;
        self.locService.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    return self;
}

- (void)startReverseGeoCode:(WHIReverseGeoCodeCallback)reverseGeoCode{
    
    self.reverseGeoCodeCallBack = reverseGeoCode;
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    reverseGeocodeSearchOption.reverseGeoPoint = self.locService.userLocation.location.coordinate;
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if (flag) {
        DDLogDebug(@"反geo检索发送成功");
    }
    else {
        DDLogDebug(@"反geo检索发送失败");
    }
}

- (void)startLocation:(WHILocationCallback)coordinate {
    self.coordinateCallBack = coordinate;
    // start location
    [_locService startUserLocationService];
}

- (void)getCurrentCityWithBlock:(WHILocationCallback)complete {
    [self startLocation:^(CLLocation *location, NSError *error) {
        if (error) {
            complete(nil, error);
        } else{
            [self startReverseGeoCode:^(BMKReverseGeoCodeResult *result) {
                DDLogDebug(@"%@", result);
                [WHIUserDefaults sharedDefaults].addressDetail = result.addressDetail;
                complete(location, error);
            }];
        }
    }];
}

#pragma mark - <BMKGeoCodeSearchDelegate>

- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    
}

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    self.reverseGeoCodeResult = result;
    if (_reverseGeoCodeCallBack) {
        _reverseGeoCodeCallBack(_reverseGeoCodeResult);
    }
}

- (void)willStartLocatingUser {
    DDLogDebug(@"tried %s", __FUNCTION__);
}

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    NSLog(@"tried update");
    if (_coordinateCallBack) {
        _coordinateCallBack(userLocation.location, nil);
        _coordinateCallBack = nil;
    }
    self.location = userLocation.location;
//    DDLogDebug(@"tried update %@", self.location);
    if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateBMKUserLocation:)]) {
//        NSLog(@"tried next");
        [self.delegate locationManager:self didUpdateBMKUserLocation:self.location];
    }
}

- (void)didFailToLocateUserWithError:(NSError *)error {
    DDLogDebug(@"%s %@", __FUNCTION__, error.userInfo);
    if (_coordinateCallBack) {
        _coordinateCallBack(nil, error);
    }
}

#pragma mark - <BMKGeneralDelegate> 

/**
 *返回网络错误
 *@param iError 错误号
 */
- (void)onGetNetworkState:(int)iError {
     DDLogDebug(@"tried %s", __FUNCTION__);
}
- (void)onGetPermissionState:(int)iError {
     DDLogDebug(@"tried %s", __FUNCTION__);
}

@end
