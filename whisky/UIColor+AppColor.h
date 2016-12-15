//
//  UIColor+AppColor.h
//  erp
//
//  Created by QiuFeng on 11/2/15.
//  Copyright © 2015 www.whi.me. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (AppColor)

/**
 *  根据 hex 返回对应的颜色 ff0000 返回红色 默认 alpha 为 255
 *
 *  @param 16进制颜色
 */
+ (UIColor *)whi_colorWithHex:(NSInteger)hex;


/**
 *  根据 hex 返回对应的颜色 ff0000 返回红色
 *
 *  @param 16进制颜色
 *  @param 0~1 的透明度
 */
+ (UIColor *)whi_colorWithHex:(NSInteger)hex alpha:(CGFloat)alpha;

/**
 *  目前直接返回 appGreenColor  日后如果需要修改皮肤神马的就直接改这里
 *  目前用途: navigationbar 的 titleColor 等
 */
+ (UIColor *)whi_appMainColor;

+ (UIColor *)whi_appTextColor;

+ (UIColor *)whi_appTabBarTintColor;

+ (UIColor *)whi_appTableViewBottomLineColor;

@end

NS_ASSUME_NONNULL_END
