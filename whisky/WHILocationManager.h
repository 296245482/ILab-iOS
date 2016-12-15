//
//  WHILocationManager.h
//  whisky
//
//  Created by QiuFeng on 4/22/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <BaiduMapAPI_Base/BMKMapManager.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>

NS_ASSUME_NONNULL_BEGIN

@class WHILocationManager;

@protocol WHILocationManagerDelegate <NSObject>

@optional

- (void)locationManager:(WHILocationManager *)manager didUpdateBMKUserLocation:(CLLocation *)userLocation;

@end

typedef void (^WHILocationCallback)(CLLocation * _Nullable location, NSError * _Nullable error);
typedef void (^WHIReverseGeoCodeCallback)(BMKReverseGeoCodeResult *result);

@interface WHILocationManager : NSObject

@property (nonatomic, strong, nullable) CLLocation *location;
@property (nonatomic, weak) id<WHILocationManagerDelegate> delegate;

+ (instancetype)sharedManager;

- (void)getCurrentCityWithBlock:(WHILocationCallback)complete;

@end

NS_ASSUME_NONNULL_END


