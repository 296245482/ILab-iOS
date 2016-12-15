//
//  SUIActivityIndicatorButton.m
//  erp
//
//  Created by 虎猫儿 on 15/11/16.
//  Copyright © 2015年 www.sui.me. All rights reserved.
//

#import "WHIActivityIndicatorButton.h"

@interface WHIActivityIndicatorButton ()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UIColor *originButtonTitleColor;
@property (nonatomic, assign) UIControlContentHorizontalAlignment horizontalAligment;
@property (nonatomic, assign) UIControlContentVerticalAlignment verticalAligment;

@end

@implementation WHIActivityIndicatorButton

#pragma mark - Accesstors

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indicatorView.userInteractionEnabled = YES;
        [self addSubview:self.indicatorView];
        
        if (self.horizontalAligment == UIControlContentHorizontalAlignmentLeft) {
            [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self);
            }];
        } else if (self.horizontalAligment ==  UIControlContentHorizontalAlignmentRight) {
            [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self);
            }];
        } else {
            [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
            }];
        }
        
        if (self.verticalAligment == UIControlContentVerticalAlignmentBottom) {
            [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self);
            }];
        } else if (self.verticalAligment == UIControlContentVerticalAlignmentTop) {
            [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self);
            }];
        } else {
            [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self);
            }];
        }
    }
    return _indicatorView;
}

#pragma mark - Operations

- (void)showIndicator {
    [self showIndicatorWithStyle:UIActivityIndicatorViewStyleWhite];
}

- (void)showIndicatorWithStyle:(UIActivityIndicatorViewStyle)style {
    self.enabled = NO;
    self.indicatorView.activityIndicatorViewStyle = style;
    [self.indicatorView startAnimating];
    self.originButtonTitleColor = [self titleColorForState:UIControlStateDisabled];
    [self setTitleColor:[UIColor clearColor] forState:UIControlStateDisabled];
}

- (void)hideIndicator {
    self.enabled = YES;
    [self.indicatorView stopAnimating];
    if (self.originButtonTitleColor) {
        [self setTitleColor:self.originButtonTitleColor forState:UIControlStateDisabled];
    }
    self.originButtonTitleColor = nil;
}

- (void)showIndicatorWithStyle:(UIActivityIndicatorViewStyle)style horizontalAligment:(UIControlContentHorizontalAlignment)horizontalAligment verticalAligment:(UIControlContentVerticalAlignment)verticalAligment {
    self.horizontalAligment = horizontalAligment;
    self.verticalAligment = verticalAligment;
    [self showIndicatorWithStyle:style];
}

@end
