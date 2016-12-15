//
//  WHIMotionManager.h
//  whisky
//
//  Created by QiuFeng on 5/13/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@import CoreMotion;

typedef NS_ENUM(NSInteger, WHIMotionState) {
    WHIMotionStateStationary,
    WHIMotionStateWalk,
    WHIMotionStateRunning,
    WHIMotionStateBiking,
};

@interface WHIMotionManager : NSObject

+ (instancetype)sharedMotionManager;

- (WHIMotionState)getActivityState;

@end

NS_ASSUME_NONNULL_END