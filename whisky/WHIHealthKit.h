//
//  WHIHealthKit.h
//  whisky
//
//  Created by QiuFeng on 5/13/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import <Foundation/Foundation.h>

@import HealthKit;

@interface WHIHealthKit : NSObject

+ (instancetype)sharedHealthKit;

- (void)getTodayBreath:(NSDate *)date complete:(void (^)(NSArray * _Nonnull))complete;

@end
