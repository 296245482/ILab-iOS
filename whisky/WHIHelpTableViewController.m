//
//  WHIHelpTableViewController.m
//  whisky
//
//  Created by QiuFeng on 6/1/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHIHelpTableViewController.h"
#import "WHIUserDefaults.h"

@interface WHIHelpTableViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *uploadSwitch;

@end



@implementation WHIHelpTableViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadTable];
}

- (void)reloadTable {
    [self.uploadSwitch setOn:[WHIUserDefaults sharedDefaults].autoUpload animated:NO];
}

- (IBAction)uploadSwitchValueChange:(UISwitch *)sender {
    [WHIUserDefaults sharedDefaults].autoUpload = sender.isOn;
}

@end
