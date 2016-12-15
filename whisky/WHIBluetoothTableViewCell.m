//
//  WHIBluetoothTableViewCell.m
//  whisky
//
//  Created by QiuFeng on 5/26/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHIBluetoothTableViewCell.h"

@interface WHIBluetoothTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@end

@implementation WHIBluetoothTableViewCell

- (void)config:(CBPeripheral *)peripheral {
    self.nameLabel.text = peripheral.name;
    switch (peripheral.state) {
        case CBPeripheralStateDisconnected: {
            self.stateLabel.text = @"";
            [self.activityView stopAnimating];
            break;
        }
        case CBPeripheralStateConnecting: {
            self.stateLabel.text = @"";
            [self.activityView startAnimating];
            break;
        }
        case CBPeripheralStateConnected: {
            self.stateLabel.text = @"已连接";
            [self.activityView stopAnimating];
            break;
        }
        case CBPeripheralStateDisconnecting: {
            self.stateLabel.text = @"";
            [self.activityView stopAnimating];
            break;
        }
    }
}

@end
