//
//  WHIRegisterTableViewController.m
//  whisky
//
//  Created by QiuFeng on 5/30/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHIRegisterTableViewController.h"
#import "WHIUser+Manager.h"

@interface WHIRegisterTableViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *inviteTextField;
@property (weak, nonatomic) IBOutlet UITextField *nickNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *mailTextField;

@property (weak, nonatomic) IBOutlet WHIActivityIndicatorButton *confirmButton;

@end

@implementation WHIRegisterTableViewController

- (IBAction)confirmButtonTouchUpInSide:(WHIActivityIndicatorButton *)sender {
    NSString *password = self.passwordTextField.text;
    if (password == nil || [password isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedStringFromTable(@"密码不能为空", @"LocalizedString", nil)];
        return;
    }
    
    NSString *name = self.nickNameTextField.text;
    if (name == nil || [name isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedStringFromTable(@"用户名不能为空", @"LocalizedString", nil)];
        return;
    }
    
    NSString *email = self.mailTextField.text;
    if (email == nil || [email isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedStringFromTable(@"邮箱不能为空", @"LocalizedString", nil)];
        return;
    }
    
    if (![password isEqualToString:self.confirmPasswordTextField.text]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedStringFromTable(@"两次密码不一致", @"LocalizedString", nil)];
        return;
    }
    
    WHIUser *user =[[WHIUser alloc] init];
    user.name = name;
    user.password = password;
    user.email = email;
    user.firstname = self.lastNameTextField.text;
    user.lastname = self.nameTextField.text;
    user.sex = self.genderSegmentedControl.selectedSegmentIndex + 1;
    user.phone = self.phoneTextField.text;
    user.code = self.inviteTextField.text;
    
    [self.confirmButton showIndicator];
    [user registerUser:^(BOOL success, NSError * _Nullable error) {
        [self.confirmButton hideIndicator];
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } else {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedStringFromTable(@"注册成功", @"LocalizedString", nil)];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}


#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField  {
    if (textField == self.inviteTextField) {
        [self.nickNameTextField becomeFirstResponder];
    } else if (textField == self.nickNameTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [self.confirmPasswordTextField becomeFirstResponder];
    } else if (textField ==  self.confirmPasswordTextField) {
        [self.lastNameTextField becomeFirstResponder];
    } else if (textField == self.lastNameTextField) {
        [self.nameTextField becomeFirstResponder];
    } else if (textField == self.nameTextField) {
        [self.phoneTextField becomeFirstResponder];
    } else if (textField == self.phoneTextField) {
        [self.mailTextField becomeFirstResponder];
    } else if (textField == self.mailTextField) {
        [self confirmButtonTouchUpInSide:self.confirmButton];
    }
    return YES;
}

@end

