//
//  Device805TableViewController.m
//  whisky
//
//  Created by luo ye on 17/01/2017.
//  Copyright © 2017 www.qiufeng.me. All rights reserved.
//

#import "Device805TableViewController.h"

@interface Device805TableViewController ()

@end

@implementation Device805TableViewController{
    DeviceWifi *deviceWifi;
    DeviceTableViewCell *cell;
    NSString *deviceId;
    NSString *wifiName;
    
    NSString *errorMessage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"进入device table view");
    self.devices = [[NSMutableArray alloc]init];
//    DeviceWifi *object = [[DeviceWifi alloc]initWithDevice:@"ggg" initWithWifi:@"sasa"];
    
        [self.devices addObjectsFromArray:[[WHIDatabaseManager sharedManager]queryForAllDevice]];
    
    
//    [self.devices addObjectsFromArray:@[object]];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return self.devices.count;
}






- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    deviceWifi = self.devices[indexPath.row];
    
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.DeviceId.text = deviceWifi.deviceId;
    cell.WifiName.text = deviceWifi.wifiName;
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //删除
    return UITableViewCellEditingStyleDelete;
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DeviceWifi *deleteDevice = self.devices[self.selectedPath.row];
        [[WHIDatabaseManager sharedManager] deleteDevice:deleteDevice.deviceId];
//        NSLog(@"删除掉的数据为%@,%@,%@,%ld",deleteDevice,indexPath,self.devices, (long)self.selectedPath.row);
        
        // Delete the row from the data source
        [self.devices removeObjectAtIndex:self.selectedPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)addDevice:(id)sender {
    [self clearData];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请输入Wi-Fi名和设备号"
                                                                             message:@""
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = NSLocalizedString(@"Enter Device ID", @"DeviceId");
        textField.text = deviceId;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = NSLocalizedString(@"Enter WiFi Name", @"WifiName");
        textField.text = wifiName;
    }];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        UITextField *empDevice = alertController.textFields[0];
        UITextField *empWifi = alertController.textFields[1];
        deviceId = empDevice.text;
        wifiName = empWifi.text;
        
        if([deviceId isEqualToString:@""]){
            errorMessage = @"请输入设备号";
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"错误"
                                                                           message:errorMessage
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [self addDevice:sender];
                [self.devices removeLastObject];
                [self.deviceTableView reloadData];
            }];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        if ([wifiName isEqualToString:@""]) {
            errorMessage = @"请输入Wi-Fi名";
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"错误"
                                                                           message:errorMessage
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [self addDevice:sender];
                [self.devices removeLastObject];
                [self.deviceTableView reloadData];
            }];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
        DeviceWifi *newObject = [[DeviceWifi alloc]initWithDevice:deviceId initWithWifi:wifiName];
        [self.devices addObjectsFromArray:@[newObject]];
        [self.deviceTableView reloadData];
        
        if(![newObject.deviceId isEqualToString:@""] && ![newObject.wifiName isEqualToString:@""])
        [[WHIDatabaseManager sharedManager] insertDevice:newObject complete:^(BOOL success){
            if(success){
                NSLog(@"成功插入一条device");
            }
        }];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"Cancel action")
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action){
                                                         }];
    [alertController addAction:defaultAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)clearData{
    if(![deviceId isEqual:@""] && ![wifiName isEqual:@""]){
        deviceId = nil;
        wifiName = nil;
    }
}




@end
