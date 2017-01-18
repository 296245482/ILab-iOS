//
//  DeviceWifi.m
//  whisky
//
//  Created by luo ye on 17/01/2017.
//  Copyright © 2017 www.qiufeng.me. All rights reserved.
//

#import "DeviceWifi.h"
@implementation DeviceWifi

- (instancetype)initWithDevice :(NSString *)deviceId initWithWifi:(NSString *)wifiName{
    self = [super init];
    if(self){
        self.deviceId = deviceId;
        self.wifiName = wifiName;
    }
    return self;
}

@end
