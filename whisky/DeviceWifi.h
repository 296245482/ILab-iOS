//
//  DeviceWifi.h
//  whisky
//
//  Created by luo ye on 17/01/2017.
//  Copyright © 2017 www.qiufeng.me. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceWifi : NSObject

@property (strong, nonatomic)NSString *deviceId;
@property (strong, nonatomic)NSString *wifiName;

- (instancetype)initWithDevice :(NSString *)deviceId initWithWifi:(NSString *)wifiName;

@end
