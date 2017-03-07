//
//  UIAlertController+ShowAlertMessage.m
//  scorpion
//
//  Created by 虎猫儿 on 15/12/25.
//  Copyright © 2015年 www.sui.me. All rights reserved.
//

#import "UIAlertController+ShowAlertMessage.h"

@implementation UIAlertController (ShowAlertMessage)

+ (instancetype)whi_alertControllerWithError:(NSError *)error {
    return [self whi_alertControllerWithAlertMessage:error.localizedDescription ? : NSLocalizedStringFromTable(@"未知错误", @"LocalizedString", nil)];
}

+ (instancetype)whi_alertControllerWithAlertMessage:(NSString *)alertMessage {
    UIAlertController *alertController = [self alertControllerWithTitle:nil message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ensureAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"好", @"LocalizedString", nil) style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ensureAction];
    
    return alertController;
}

@end
