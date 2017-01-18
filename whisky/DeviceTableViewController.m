//
//  DeviceTableViewController.m
//  whisky
//
//  Created by Cheng Long on 17/01/2017.
//  Copyright © 2017 www.qiufeng.me. All rights reserved.
//

#import "DeviceTableViewController.h"

@interface DeviceTableViewController()

@end

@implementation DeviceTableViewController{
    DeviceWifi *deviceWifi;
    DeviceTableViewCell *cell;
    NSString *deviceId;
    NSString *wifiName;
    
    NSString *errorMessage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //NSLog(@"aaaa进入此view");
    self.devices = [[NSMutableArray alloc]init];
    DeviceWifi *object = [[DeviceWifi alloc]initWithDevice:@"ggg" initWithWifi:@"sasa"];
    
//    [self.devices addObjectsFromArray:[[WHIDatabaseManager sharedManager]queryForAllDevice]];
    
    
    [self.devices addObjectsFromArray:@[object]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return  self.devices.count;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    deviceWifi = self.devices[indexPath.row];
    
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.DeviceId.text = deviceWifi.deviceId;
    cell.WifiName.text = deviceWifi.wifiName;
    
    return cell;
    
}


//- (IBAction)addDevice:(id)sender {
//    [self clearData];
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请输入Wi-Fi名和设备号"
//                                                                             message:@""
//                                                                      preferredStyle:UIAlertControllerStyleAlert];
//    
//    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
//        textField.placeholder = NSLocalizedString(@"Enter Device ID", @"DeviceId");
//        textField.text = deviceId;
//    }];
//    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
//        textField.placeholder = NSLocalizedString(@"Enter WiFi Name", @"WifiName");
//        textField.text = wifiName;
//    }];
//    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
//        UITextField *empDevice = alertController.textFields[0];
//        UITextField *empWifi = alertController.textFields[1];
//        deviceId = empDevice.text;
//        wifiName = empWifi.text;
//        
//        if([deviceId isEqualToString:@""]){
//            errorMessage = @"请输入设备号";
//            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"错误"
//                                                                           message:errorMessage
//                                                                    preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
//                [self addDevice:sender];
//                [self.devices removeLastObject];
//                [self.deviceTableView reloadData];
//            }];
//            [alert addAction:defaultAction];
//            [self presentViewController:alert animated:YES completion:nil];
//        }
//        if ([wifiName isEqualToString:@""]) {
//            errorMessage = @"请输入Wi-Fi名";
//            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Eorror"
//                                                                           message:errorMessage
//                                                                    preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
//                [self addDevice:sender];
//                [self.devices removeLastObject];
//                [self.deviceTableView reloadData];
//            }];
//            [alert addAction:defaultAction];
//            [self presentViewController:alert animated:YES completion:nil];
//        }
//        
//        DeviceWifi *newObject = [[DeviceWifi alloc]initWithDevice:deviceId initWithWifi:wifiName];
//        [self.devices addObjectsFromArray:@[newObject]];
//        [self.deviceTableView reloadData];
//        
//        [[WHIDatabaseManager sharedManager] insertDevice:newObject complete:^(BOOL success){
//            if(success){
//                NSLog(@"aaa成功插入一条");
//            }
//        }];
//    }];
//    
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
//                                                           style:UIAlertActionStyleCancel
//                                                         handler:^(UIAlertAction *action){
//                                                         }];
//    [alertController addAction:defaultAction];
//    [alertController addAction:cancelAction];
//    [self presentViewController:alertController animated:YES completion:nil];
//}
//
//- (void)clearData{
//    if(![deviceId isEqual:@""] && ![wifiName isEqual:@""]){
//        deviceId = nil;
//        wifiName = nil;
//    }
//}

@end
