//
//  WHIMotionManager.m
//  whisky
//
//  Created by QiuFeng on 5/13/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHIMotionManager.h"
#import "NSDate+Calendar.h"

@interface WHIMotionManager ()

@property (nonatomic, strong) CMMotionActivityManager *motionActivityManager;
@property (nonatomic, strong) CMMotionActivity *activity;
@property (nonatomic, strong) CMPedometer *pedometer;
@property (nonatomic, strong) CMMotionActivity *acitityResult;

@end

@implementation WHIMotionManager {
    NSOperationQueue *queryQueue;
}

+ (instancetype)sharedMotionManager {
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        queryQueue = [[NSOperationQueue alloc] init];
        [self motionActivityManager];
    }
    return self;
}

//- (WHIMotionState)getState:(double)stationary walking:(double)walking running:(double)running cycling:(double)cycling {
//    double maxDuration = stationary;
//    WHIMotionState state = WHIMotionStateStationary;
//    if (walking > maxDuration) {
//        state = WHIMotionStateWalk;
//        maxDuration = walking;
//    }
//    
//    if (running > maxDuration) {
//        state = WHIMotionStateRunning,
//        maxDuration = running;
//    }
//    
//    if (cycling > maxDuration) {
//        state = WHIMotionStateBiking;
//        maxDuration = cycling;
//    }
//    return state;
//}

- (WHIMotionState)getActivityState {
    if (self.activity.running) {
        return WHIMotionStateRunning;
    } else if (self.activity.walking) {
        return WHIMotionStateWalk;
    } else if (self.activity.cycling) {
        return WHIMotionStateBiking;
    }
    return WHIMotionStateStationary;
}

- (CMMotionActivityManager *)motionActivityManager {
    if (_motionActivityManager == nil) {
        _motionActivityManager = [[CMMotionActivityManager alloc] init];
        if ([CMMotionActivityManager isActivityAvailable]) {
            [_motionActivityManager startActivityUpdatesToQueue:queryQueue withHandler:^(CMMotionActivity * _Nullable activity) {
                self.activity = activity;
                DDLogDebug(@"%@", activity);
            }];
        }
    }
    return _motionActivityManager;
}

- (CMPedometer *)pedometer {
    if (_pedometer == nil) {
        _pedometer = [[CMPedometer alloc] init];
        if ([CMPedometer isPaceAvailable]) {
          //  [_pedometer startPedometerUpdatesFromDate:<#(nonnull NSDate *)#> withHandler:<#^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error)handler#>]
        }
    }
    return _pedometer;
}

@end
