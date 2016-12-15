//
//  UIColor+AppColor.m
//  erp
//
//  Created by QiuFeng on 11/2/15.
//  Copyright © 2015 www.whi.me. All rights reserved.
//

#import "UIColor+AppColor.h"

@implementation UIColor (AppColor)

+ (UIColor *)whi_colorWithHex:(NSInteger)hex {
    return [self whi_colorWithHex:hex alpha:1];
}

+ (UIColor *)whi_colorWithHex:(NSInteger)hex alpha:(CGFloat)alpha {
    NSInteger blue = hex & 0xFF;
    NSInteger green = (hex & 0xFF00) >> 8;
    NSInteger red = (hex & 0xFF0000) >> 16;
    return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:alpha];
}

+ (UIColor *)whi_appMainColor {
    return [UIColor whi_colorWithHex:0x007aff];
}

+ (UIColor *)whi_appTextColor {
    return [UIColor whi_colorWithHex:0x666666];
}

+ (UIColor *)whi_appTableViewBottomLineColor {
    return [UIColor whi_colorWithHex:0xecf0f1];
}

+ (UIColor *)whi_appTabBarTintColor {
    return [UIColor whi_colorWithHex:0x111111];
}

#pragma mark - Welcome

+ (UIColor *)whi_welcomePageControlSelectColor {
    return [self whi_colorWithHex:0x17929C];
}

+ (UIColor *)whi_welcomePageControlUnselectColor {
    return [self whiteColor];
}

+ (NSArray <UIColor *> *)whi_welcomePageBackGroundColor {
    NSArray *colorHexs = @[@(0xffffff), @(0xFFE387), @(0xF0EBFF), @(0xF6A590)];
    NSMutableArray *colors = [NSMutableArray array];
    for (NSNumber *colorHex in colorHexs) {
        [colors addObject:[self whi_colorWithHex:colorHex.intValue]];
    }
    return colors;
}

@end
