//
//  WHIUserDefaults.h
//  whisky
//
//  Created by QiuFeng on 4/22/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@class BMKAddressComponent;
@class WHIUser;

@interface WHIUserDefaults : NSObject

+ (instancetype)sharedDefaults;

@property (nonatomic, strong, nullable) CLLocation *lastLocation;
@property (nonatomic, strong, nullable) BMKAddressComponent *addressDetail;
@property (nonatomic, strong, nullable) WHIUser *user;
@property (nonatomic, strong, nullable) NSString *token;

@property (nonatomic, assign) BOOL autoUpload;

@property (nonatomic, assign) float weight;
@property (nonatomic, assign) double heartRate;
@property (nonatomic, strong) NSNumber *lastPm;
@property (nonatomic, strong) NSNumber *lastSource;
@property (nonatomic, assign) BOOL agreePrivacy;

@end

NS_ASSUME_NONNULL_END
