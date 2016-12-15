//
//  UIAlertController+Manager.h
//  erp
//
//  Created by 虎猫儿 on 15/11/11.
//  Copyright © 2015年 www.sui.me. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIAlertController (Manager)

+ (void)whi_showPhotoPickerAlertControllerInController:(UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate> *)viewController;

@end

NS_ASSUME_NONNULL_END