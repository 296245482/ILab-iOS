//
//  WHIForgetPasswordViewController.m
//  whisky
//
//  Created by QiuFeng on 04/08/2016.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHIForgetPasswordViewController.h"
#import "WHIUser+Manager.h"
#import "UIAlertController+Manager.m"

@interface WHIForgetPasswordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@end

@implementation WHIForgetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)forgetPasswordButtonTouchUpInside:(UIButton *)sender {
    if (self.nameTextField.text == nil || [self.nameTextField.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"user name needed"];
        return;
    }
    
    [WHIUser forgetPassword:self.nameTextField.text complete:^(BOOL success, NSError * _Nullable error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Forget password" message:@"Please check you email"preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

@end
