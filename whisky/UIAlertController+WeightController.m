//
//  UIAlertController+WeightController.m
//  whisky
//
//  Created by QiuFeng on 5/24/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "UIAlertController+WeightController.h"
#import "WHIUserDefaults.h"

@implementation UIAlertController (WeightController)

+ (instancetype)whi_showWeightAlertController {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"请输入体重(kg)", @"LocalizedString", nil)  message:NSLocalizedStringFromTable(@"应用需要您的体重计算呼吸情况", @"LocalizedString", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"完成", @"LocalizedString", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [WHIUserDefaults sharedDefaults].weight = [alertController.textFields[0].text floatValue];
    }];
  
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedStringFromTable(@"体重(kg)", @"LocalizedString", nil);
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        
        if ([WHIUserDefaults sharedDefaults].weight == 0) {
            action.enabled = NO;
        } else {
            textField.text = [NSString stringWithFormat:@"%@", @([WHIUserDefaults sharedDefaults].weight)];
            action.enabled = YES;
        }
        [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:textField queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            action.enabled = [textField.text integerValue] != 0;
        }];
    }];
    
    [alertController addAction:action];
    return alertController;
}

@end
