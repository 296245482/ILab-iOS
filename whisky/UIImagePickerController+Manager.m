//
//  UIImagePickerController+Manager.m
//  erp
//
//  Created by 虎猫儿 on 15/11/11.
//  Copyright © 2015年 www.sui.me. All rights reserved.
//

#import "UIImagePickerController+Manager.h"

@implementation UIImagePickerController (Manager)

+ (nullable instancetype)whi_imagePickerFromAlbum {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    if ( [UIImagePickerController isSourceTypeAvailable:sourceType] && mediaTypes.count > 0 ) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.mediaTypes = mediaTypes;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = sourceType;
        return imagePicker;
    }
    return nil;
}

+ (nullable instancetype)whi_imagePickerFromCamera {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    if ( [UIImagePickerController isSourceTypeAvailable:sourceType] && mediaTypes.count > 0 ) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.mediaTypes = mediaTypes;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = sourceType;
        return imagePicker;
    }
    return nil;
}

@end
