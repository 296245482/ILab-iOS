//
//  WHIUserDefaults.m
//  whisky
//
//  Created by QiuFeng on 4/22/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHIUserDefaults.h"
#import "WHIUser.h"

@implementation WHIUserDefaults

@synthesize lastLocation = _lastLocation;
@synthesize addressDetail = _addressDetail;
@synthesize weight = _weight;
@synthesize user = _user;
@synthesize token = _token;
@synthesize autoUpload = _autoUpload;
@synthesize lastPm = _lastPm;
@synthesize lastSource = _lastSource;
@synthesize heartRate = _heartRate;

+ (instancetype)sharedDefaults {
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)setLastLocation:(CLLocation *)lastLocation {
    if (_lastLocation != lastLocation) {
        _lastLocation = lastLocation;
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_lastLocation];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"WHILastLocation"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (CLLocation *)lastLocation {
    if (_lastLocation == nil) {
        NSData *data = [[NSUserDefaults standardUserDefaults]  objectForKey:@"WHILastLocation"];
        _lastLocation = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return _lastLocation;
}

- (void)setAddressDetail:(BMKAddressComponent *)addressDetail {
    if (_addressDetail != addressDetail) {
        _addressDetail = addressDetail;
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:addressDetail];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"WHIAddressDetail"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (BMKAddressComponent *)addressDetail {
    if (_addressDetail == nil) {
        NSData *data = [[NSUserDefaults standardUserDefaults]  objectForKey:@"WHIAddressDetail"];
        _addressDetail = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return _addressDetail;
}

- (void)setWeight:(float)weight {
    _weight = weight;
    [[NSUserDefaults standardUserDefaults] setObject:@(_weight) forKey:@"WHIWeight"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (float)weight {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:@"WHIWeight"];
}

- (void)setHeartRate:(double)heartRate {
    _heartRate = heartRate;
    [[NSUserDefaults standardUserDefaults] setObject:@(_heartRate) forKey:@"WHIHeartRate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (double)heartRate {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:@"WHIHeartRate"];
}

- (void)setAgreePrivacy:(BOOL)agreePrivacy {
    [[NSUserDefaults standardUserDefaults] setObject:@(agreePrivacy) forKey:@"WHIAgreePrivacy"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)agreePrivacy {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"WHIAgreePrivacy"];
}

- (WHIUser *)user {
    if (_user == nil) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"WHIUser"];
        _user = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return _user;
}

- (void)setUser:(WHIUser *)user {
    _user = user;
    NSData *personEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:_user];
    [[NSUserDefaults standardUserDefaults] setObject:personEncodedObject forKey:@"WHIUser"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setToken:(NSString *)token {
    _token = token;
    [[NSUserDefaults standardUserDefaults] setObject:_token forKey:@"WHToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)token {
    if (_token == nil) {
        _token = [[NSUserDefaults standardUserDefaults] objectForKey:@"WHToken"];
    }
    return _token;
}

- (void)setAutoUpload:(BOOL)autoUpload {
    _autoUpload = autoUpload;
    [[NSUserDefaults standardUserDefaults] setBool:_autoUpload forKey:@"WHAutoUpload"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)autoUpload {
    if ([self user].objectId == nil) {
        return NO;
    } else {
        _autoUpload = [[NSUserDefaults standardUserDefaults] boolForKey:@"WHAutoUpload"];
        return _autoUpload;
    }
}

- (void)setLastPm:(NSNumber *)lastPm {
    _lastPm = lastPm;
    [[NSUserDefaults standardUserDefaults] setValue:_lastPm forKey:@"WHILastPm"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSNumber *)lastPm {
    if (_lastPm) {
        return _lastPm;
    } else {
        _lastPm = [[NSUserDefaults standardUserDefaults] objectForKey:@"@WHILastPm"];
        return _lastPm;
    }
}

- (void)setLastSource:(NSNumber *)lastSource {
    _lastSource = lastSource;
    [[NSUserDefaults standardUserDefaults] setValue:_lastSource forKey:@"WHILastSource"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSNumber *)lastSource {
    if (_lastSource) {
        return _lastSource;
    } else {
        _lastSource = [[NSUserDefaults standardUserDefaults] objectForKey:@"@WHILastSource"];
        return _lastSource;
    }
}

@end
