//
//  WHIPrivacyViewController.m
//  whisky
//
//  Created by QiuFeng on 12/07/2016.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHIPrivacyViewController.h"
#import "WHIUserDefaults.h"

@interface WHIPrivacyViewController ()

@end

@implementation WHIPrivacyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    if ([WHIUserDefaults sharedDefaults].agreePrivacy) {
        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WHIRootTabbarViewController"];
        [UIApplication sharedApplication].keyWindow.rootViewController = viewController;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)agreeButtonTouchUpInside:(id)sender {
    UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WHIRootTabbarViewController"];
    [UIApplication sharedApplication].keyWindow.rootViewController = viewController;
    [WHIUserDefaults sharedDefaults].agreePrivacy = YES;
}

@end
