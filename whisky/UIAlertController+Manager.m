//
//  UIAlertController+Manager.m
//  erp
//
//  Created by 虎猫儿 on 15/11/11.
//  Copyright © 2015年 www.sui.me. All rights reserved.
//

#import "UIAlertController+Manager.h"
#import "UIImagePickerController+Manager.h"
#import <MobileCoreServices/UTCoreTypes.h>

@implementation UIAlertController (Manager)

+ (void)showAlertControllerWithTitle:(NSString *)title  viewcontroller:(UIViewController *)viewController {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"好", @"LocalizedString", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [viewController presentViewController:controller animated:YES completion:nil];
}

+ (void)whi_showPhotoPickerAlertControllerInController:(UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate> *)viewController {
    if (!viewController) return;
    UIAlertController *photoPickAlertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *pickPhotoFromAlbumAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"从相册选择", @"LocalizedString", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *imagePickerController = [UIImagePickerController whi_imagePickerFromAlbum];
        imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
        imagePickerController.delegate = viewController;
        if (imagePickerController) {
            [viewController presentViewController:imagePickerController animated:YES completion:nil];
        } else {
            [self showAlertControllerWithTitle:NSLocalizedStringFromTable(@"无法访问相册", @"LocalizedString", nil) viewcontroller:viewController];
        }
    }];
    
    UIAlertAction *pickPhotoFromCameraAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"拍照", @"LocalizedString", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIImagePickerController *imagePickerController = [UIImagePickerController whi_imagePickerFromCamera];
        imagePickerController.delegate = viewController;
        imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
        imagePickerController.allowsEditing = YES;
        if (imagePickerController) {
            [viewController presentViewController:imagePickerController animated:YES completion:nil];
        } else {
            [self showAlertControllerWithTitle:NSLocalizedStringFromTable(@"无法访问相机", @"LocalizedString", nil)  viewcontroller:viewController];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"取消", @"LocalizedString", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [photoPickAlertController addAction:pickPhotoFromAlbumAction];
    [photoPickAlertController addAction:pickPhotoFromCameraAction];
    [photoPickAlertController addAction:cancelAction];
    
    [viewController presentViewController:photoPickAlertController animated:YES completion:nil];
}

@end
