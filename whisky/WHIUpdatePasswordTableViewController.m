//
//  WHIUpdatePasswordTableViewController.m
//  whisky
//
//  Created by QiuFeng on 5/26/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHIUpdatePasswordTableViewController.h"
#import "UIAlertController+ShowAlertMessage.h"
#import "WHIClient.h"
#import "WHIUser+Manager.h"

@interface WHIUpdatePasswordTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *oldTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (nonatomic, strong) WHIUser *user;

@end

@implementation WHIUpdatePasswordTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)confirmButtonTouchUpInside:(id)sender {
    NSString *old = self.oldTextField.text ?: @"";
    NSString *password = self.passwordTextField.text ?: @"";
    
    if ([old isEqualToString:@""]) {
        UIAlertController *alert = [UIAlertController whi_alertControllerWithAlertMessage: NSLocalizedStringFromTable(@"Old one needed", @"LocalizedString", nil)];
        [self presentViewController:alert animated:YES completion:nil];
        return;
       
    }
    
    if ([password isEqualToString:@""]) {
        UIAlertController *alert = [UIAlertController whi_alertControllerWithAlertMessage: NSLocalizedStringFromTable(@"plz enter new password", @"LocalizedString", nil)];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    self.user = [WHIUser currentUser];
    [self.user updatePassword:password complete:^(BOOL success, NSError * _Nullable error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } else {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedStringFromTable(@"changed succeed", @"LocalizedString", nil)];
            [self.navigationController popViewControllerAnimated:YES];
            //[WHIUser logOut];
        }
    }];
}

- (WHIUser *)user {
    if (_user == nil) {
        _user = [WHIUser currentUser];
    }
    return _user;
}

@end
