//
//  UIAlertController+ShowAlertMessage.h
//  scorpion
//
//  Created by 虎猫儿 on 15/12/25.
//  Copyright © 2015年 www.sui.me. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (ShowAlertMessage)

+ (instancetype)whi_alertControllerWithError:(NSError *)error;

+ (instancetype)whi_alertControllerWithAlertMessage:(NSString *)alertMessage;

@end
