//
//  SUIActivityIndicatorButton.h
//  erp
//
//  Created by 虎猫儿 on 15/11/16.
//  Copyright © 2015年 www.sui.me. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WHIActivityIndicatorButton : UIButton

- (void)showIndicator;
- (void)showIndicatorWithStyle:(UIActivityIndicatorViewStyle)style;
- (void)showIndicatorWithStyle:(UIActivityIndicatorViewStyle)style horizontalAligment:(UIControlContentHorizontalAlignment)horizontalAligment verticalAligment:(UIControlContentVerticalAlignment)verticalAligment;
- (void)hideIndicator;

@end

NS_ASSUME_NONNULL_END
