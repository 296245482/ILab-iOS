//
//  WHIBluetoothTableViewCell.h
//  whisky
//
//  Created by QiuFeng on 5/26/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import <UIKit/UIKit.h>

@import CoreBluetooth;

NS_ASSUME_NONNULL_BEGIN

@interface WHIBluetoothTableViewCell : UITableViewCell

- (void)config:(CBPeripheral *)peripheral;

@end

NS_ASSUME_NONNULL_END;