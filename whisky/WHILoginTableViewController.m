//
//  WHILoginTableViewController.m
//  whisky
//
//  Created by QiuFeng on 5/30/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHILoginTableViewController.h"
#import "WHIUser+Manager.h"
#import "customKeyChainTool.h"

@interface WHILoginTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet WHIActivityIndicatorButton *doneButton;

@end

@implementation WHILoginTableViewController
- (void)viewDidLoad {
    self.nameTextField.text = [(NSMutableDictionary*)[customKeyChainTool load:@"namePasswdPair"] objectForKey:@"name"];
    self.passwordTextField.text = [(NSMutableDictionary*)[customKeyChainTool load:@"namePasswdPair"] objectForKey:@"password"];
}

- (IBAction)doneButtonTouchUpInSide:(WHIActivityIndicatorButton *)sender {
    NSString *name = self.nameTextField.text;
    NSString *password = self.passwordTextField.text;
    [self.doneButton showIndicator];
    [WHIUser login:name password:password complete:^(WHIUser * _Nullable user, NSError * _Nullable error) {
        [self.doneButton hideIndicator];
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } else {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedStringFromTable(@"登录成功", @"LocalizedString", nil)];
            [self.navigationController popViewControllerAnimated:YES];
            NSMutableDictionary *userNamePasswdPair = [NSMutableDictionary dictionary];
            [userNamePasswdPair setObject:self.nameTextField.text forKey:@"name"];
            [userNamePasswdPair setObject:self.passwordTextField.text forKey:@"password"];
            [customKeyChainTool save:@"namePasswdPair" data:userNamePasswdPair];
        }
    }];
}

@end
