//
//  WHIBluetoothTableViewController.m
//  whisky
//
//  Created by QiuFeng on 5/26/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHIBluetoothTableViewController.h"
#import "UIAlertController+Manager.h"
#import "WHIBluetoothTableViewCell.h"
#import "WHIBlueTooth.h"

@import CoreBluetooth;

@interface WHIBluetoothTableViewController ()<CBCentralManagerDelegate>

@property (nonatomic, strong) NSMutableArray *devices;

@property(strong,nonatomic) WHIBlueTooth *bluetooth;

@end

@implementation WHIBluetoothTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bluetooth = [WHIBlueTooth sharedInstance];
}

- (void)startScan {
    [self.devices removeAllObjects];
    [self.tableView reloadData];
    __weak typeof(self) weakSelf=self;
    [self.bluetooth startScanDevicesWithInterval:30 CompleteBlock:^(NSArray *devices) {
        [weakSelf.devices removeAllObjects];
        for (CBPeripheral *per in devices) {
            [weakSelf addToDevice:per];
        }
        [weakSelf.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.bluetooth stopScanDevices];
}

- (void)viewDidAppear:(BOOL)animated {
    [self startScan];
    [super viewDidAppear:animated];
}

#pragma mark - Accessors

- (NSMutableArray *)devices {
    if (_devices == nil) {
        _devices = [NSMutableArray array];
    }
    return _devices;
}

- (void)addToDevice:(CBPeripheral *)peripheral {
    if (peripheral.name == nil) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        for (CBPeripheral *p in self.devices) {
            if ([p.name isEqualToString:peripheral.name]) {
                return;
            }
        }
        [self.devices addObject:peripheral];
        [self.tableView reloadData];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WHIBluetoothTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WHIBluetoothTableViewCell class])];
    [cell config:self.devices[indexPath.row]];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"连接设备中...");
    
    [self.bluetooth connectionWithDeviceUUID:[((CBPeripheral *)self.devices[indexPath.row]).identifier UUIDString] TimeOut:10 CompleteBlock:^(CBPeripheral *device, NSError *err) {
        if (device) {
            NSLog(@"查找设备的服务和特征...");
            [self.bluetooth discoverServiceAndCharacteristicWithInterval:3 CompleteBlock:^(NSArray *serviceArray, NSArray *characteristicArray, NSError *err) {
                
                NSLog(@"查找服务和特征成功 %ld",serviceArray.count);
            }];
        } else{
            NSLog(@"连接设备失败");
        }
        [self.tableView reloadData];
    }];
    [self.tableView reloadData];
}



- (IBAction)refreshBarButtonTouchUpInside:(UIBarButtonItem *)sender {
    [self startScan];
    
    [[WHIBlueTooth sharedInstance] writeCharacteristicWithServiceUUID:@"bfcce9a0-e479-11e3-ac10-0800200c9a66" CharacteristicUUID:@"27C537AE-22B7-E73A-1BDD-C083F656AC13" data:nil];
}

@end
