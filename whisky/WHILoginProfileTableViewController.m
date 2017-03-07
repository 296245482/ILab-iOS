//
//  WHILoginProfileTableViewController.m
//  whisky
//
//  Created by QiuFeng on 5/26/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHILoginProfileTableViewController.h"
#import "WHIUser+Manager.h"

@interface WHILoginProfileTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nikeNameLabel;
@property (nonatomic, strong) WHIUser *user;

@end

@implementation WHILoginProfileTableViewController

+ (instancetype)loadFromStroyboard {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    return [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (WHIUser *)user {
    if (_user == nil) {
        _user = [WHIUser currentUser];
    }
    return _user;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _user = [WHIUser currentUser];
    self.nikeNameLabel.text = self.user.name;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//登陆后点任意均退出
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 1){
        [WHIUser logOut];
    }
    
}


@end
