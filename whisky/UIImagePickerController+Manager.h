//
//  UIImagePickerController+Manager.h
//  erp
//
//  Created by 虎猫儿 on 15/11/11.
//  Copyright © 2015年 www.sui.me. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImagePickerController (Manager)

+ (nullable instancetype)whi_imagePickerFromAlbum;

+ (nullable instancetype)whi_imagePickerFromCamera;

@end

NS_ASSUME_NONNULL_END
