//
//  WHIShareManager.h
//  whisky
//
//  Created by QiuFeng on 5/31/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WHIShareManager : NSObject

//+ (void)shareImage:(UIImage *)image onStateChange:(SSDKShareStateChangedHandler)stateChangedHandler;

+ (instancetype)sharedManager;

- (void)setupImage:(UIImage *)image view:(UIViewController *)viewController;

@end
