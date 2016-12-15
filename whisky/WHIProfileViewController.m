//
//  WHIProfileViewController.m
//  whisky
//
//  Created by QiuFeng on 5/27/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHIProfileViewController.h"
#import "WHILoginProfileTableViewController.h"
#import "WHIUnloginProfileTableViewController.h"
#import "WHIUser+Manager.h"
#import "UIAlertController+WeightController.h"

@interface WHIProfileViewController ()

@property (nonatomic, strong) WHILoginProfileTableViewController *loginViewController;
@property (nonatomic, strong) WHIUnloginProfileTableViewController *unLoginViewController;
@property (nonatomic, strong) WHIUser *user;

@end

@implementation WHIProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self setupLoginOrNot];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userChangeNotification:) name:WHIUserChangeNotification object:nil];
}

- (void)setupView {
    [self addChildViewController:self.loginViewController];
    [self addChildViewController:self.unLoginViewController];
    [self.view addSubview:self.loginViewController.view];
    [self.view addSubview:self.unLoginViewController.view];
    [self.loginViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
    
    [self.unLoginViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
}

- (void)setupLoginOrNot {
    if (self.user) {
        self.unLoginViewController.view.hidden = YES;
        self.loginViewController.view.hidden = NO;
    } else {
        self.loginViewController.view.hidden = YES;
        self.unLoginViewController.view.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Accessors 

- (WHILoginProfileTableViewController *)loginViewController {
    if (_loginViewController == nil) {
        _loginViewController = [WHILoginProfileTableViewController loadFromStroyboard];
    }
    return _loginViewController;
}

- (WHIUnloginProfileTableViewController *)unLoginViewController {
    if (_unLoginViewController == nil) {
        _unLoginViewController = [WHIUnloginProfileTableViewController loadFromStroyboard];
    }
    return _unLoginViewController;
}

- (WHIUser *)user {
    if (_user == nil) {
        _user = [WHIUser currentUser];
    }
    return _user;
}

#pragma mark - Notification

- (void)userChangeNotification:(NSNotification *)notification {
    self.user = notification.object;
    [self setupLoginOrNot];
}

- (IBAction)weightBarButtonTouchUpInside:(UIBarButtonItem *)sender {
    UIAlertController *alert = [UIAlertController whi_showWeightAlertController];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
