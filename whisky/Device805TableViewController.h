//
//  Device805TableViewController.h
//  whisky
//
//  Created by luo ye on 17/01/2017.
//  Copyright © 2017 www.qiufeng.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WHIDatabaseManager.h"
#import "DeviceWifi.h"
#import "DeviceTableViewCell.h"

@interface Device805TableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITableView *deviceTableView;
@property(strong, nonatomic)NSMutableArray *devices;
@property(strong, nonnull)NSIndexPath *selectedPath;


@end
