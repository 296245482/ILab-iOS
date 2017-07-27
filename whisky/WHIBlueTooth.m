//
//  BlueTooth.m
//  BluetoothDemo
//
//  Created by whatywhaty on 16/4/13.
//  Copyright © 2016年 whatywhaty. All rights reserved.
//

#import "WHIBlueTooth.h"
#import "WHIUserDefaults.h"

@interface WHIBlueTooth ()

@property (nonatomic, assign)  CBCentralManagerState state;

@property (nonatomic, strong) NSMutableArray *DeviceArray;
@property (nonatomic, strong) NSMutableArray *ServiceArray;
@property (nonatomic, strong) NSMutableArray *CharacteristicArray;

@property (nonatomic, strong) CBPeripheral *ConnectionDevice;

@property (nonatomic, copy)  ScanDevicesCompleteBlock scanBlock;
@property (nonatomic, copy)  ConnectionDeviceBlock connectionBlock;
@property (nonatomic, copy)  ServiceAndCharacteristicBlock serviceAndcharBlock;
@end

@implementation WHIBlueTooth

static NSString * const TRUSTED_DATA_SERVICE = @"bfcce9a0-e479-11e3-ac10-0800200c9a66";
static NSString * const TRUSTED_DATA_NOTIFY = @"bfcce9a2-e479-11e3-ac10-0800200c9a66";

#pragma mark - 自定义方法
static id _instance;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
        _ServiceArray = [[NSMutableArray alloc] init];
        _CharacteristicArray = [[NSMutableArray alloc] init];
        _DeviceArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)startScanDevicesWithInterval:(NSUInteger)timeout CompleteBlock:(ScanDevicesCompleteBlock)block {
    DDLogDebug(@"开始扫描设备");
    [self.DeviceArray removeAllObjects];
    [self.ServiceArray removeAllObjects];
    [self.CharacteristicArray removeAllObjects];
    self.scanBlock = block;
    [self.manager scanForPeripheralsWithServices:nil options:nil];
    [self performSelector:@selector(stopScanDevices) withObject:nil afterDelay:timeout];
}

- (void)stopScanDevices {
    DDLogDebug(@"扫描设备结束");
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopScanDevices) object:nil];
    [self.manager stopScan];
    if (self.scanBlock) {
        self.scanBlock(self.DeviceArray);
    }
    self.scanBlock = nil;
}

- (void)connectionWithDeviceUUID:(NSString *)uuid TimeOut:(NSUInteger)timeout CompleteBlock:(ConnectionDeviceBlock)block {
    self.connectionBlock = block;
    [self performSelector:@selector(connectionTimeOut) withObject:nil afterDelay:timeout];
    for (CBPeripheral *device in self.DeviceArray) {
        if ([device.identifier.UUIDString isEqualToString:uuid]) {
            [self.manager connectPeripheral:device options:@{ CBCentralManagerScanOptionAllowDuplicatesKey:@YES }];
            break;
        }
    }
}

- (void)disconnectionDevice {
    DDLogDebug(@"断开设备连接");
    [self.ServiceArray removeAllObjects];
    [self.CharacteristicArray removeAllObjects];
    [self.manager cancelPeripheralConnection:self.ConnectionDevice];
    self.ConnectionDevice = nil;
}

- (void)discoverServiceAndCharacteristicWithInterval:(NSUInteger)time CompleteBlock:(ServiceAndCharacteristicBlock)block {
    [self.ServiceArray removeAllObjects];
    [self.CharacteristicArray removeAllObjects];
    self.serviceAndcharBlock = block;
    self.ConnectionDevice.delegate = self;
    
    [self.ConnectionDevice discoverServices:nil];
    
    [self performSelector:@selector(discoverServiceAndCharacteristicWithTime) withObject:nil afterDelay:time];
}

//单次写数据
- (void)writeCharacteristicWithServiceUUID:(NSString *)sUUID CharacteristicUUID:(NSString *)cUUID data:(NSData *)data {
    for (CBService *service in self.ConnectionDevice.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:sUUID]]) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cUUID]]) {
                    [self.ConnectionDevice writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
                }
            }
        }
    }
}

//订阅charateristic数据，不断的接收设备发送的数据，enable设置成yes，订阅成功回调didUpdateNotificationStateForCharacteristic
- (void)setNotificationForCharacteristicWithServiceUUID:(NSString *)sUUID CharacteristicUUID:(NSString *)cUUID enable:(BOOL)enable {
    for (CBService *service in self.ConnectionDevice.services) {
//        if ([service.UUID isEqual:[CBUUID UUIDWithString:sUUID]]) {
            for (CBCharacteristic *characteristic in service.characteristics) {
//                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cUUID]]) {
                    [self.ConnectionDevice setNotifyValue:enable forCharacteristic:characteristic];
                }
//            }
//        }
    }
}

//调用读取连接设备中的service的characteritic中的数据，继续回调didUpdateValueForCharacteristic，readValueForCharateritic非实时，单次接收
-(void)readCharacteristicWithServiceUUID:(NSString *)sUUID CharacteristicUUID:(NSString *)cUUID{
    NSLog(@"即将读取数据1");
    for (CBService *service in self.ConnectionDevice.services) {
        NSLog(@"即将读取数据1.1");
//        if ([service.UUID isEqual:[CBUUID UUIDWithString:sUUID]]) {
            NSLog(@"即将读取数据1.2");
            for (CBCharacteristic *characteristic in service.characteristics) {
                NSLog(@"即将读取数据2.0");
//                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cUUID]]) {
                    NSLog(@"即将读取数据2");
                    [self.ConnectionDevice readValueForCharacteristic:characteristic];
//                }
//            }
        }
    }
}

#pragma mark - 私有方法

- (void)connectionTimeOut {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectionTimeOut) object:nil];
    if (self.connectionBlock) {
        self.connectionBlock(nil, [self wrapperError:@"连接设备超时!" Code:400]);
    }
    self.connectionBlock = nil;
}

- (void)discoverServiceAndCharacteristicWithTime {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectionTimeOut) object:nil];
    if (self.serviceAndcharBlock) {
        self.serviceAndcharBlock(self.ServiceArray, self.CharacteristicArray, [self wrapperError:@"发现服务和特征完成!" Code:400]);
    }
    self.connectionBlock = nil;
}

- (NSError *)wrapperError:(NSString *)msg Code:(NSInteger)code {
    NSError *error = [NSError errorWithDomain:msg code:code userInfo:nil];
    return error;
}

#pragma mark - CBCentralManagerDelegate代理方法

//CBCentralManagerStateUnknown = 0,
//CBCentralManagerStateResetting = 1,
//CBCentralManagerStateUnsupported = 2,
//CBCentralManagerStateUnauthorized = 3,
//CBCentralManagerStatePoweredOff = 4,
//CBCentralManagerStatePoweredOn = 5,
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    DDLogDebug(@"当前的设备状态:%ld", (long)central.state);
    self.state = central.state;
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    DDLogDebug(@"发现设备:%@", peripheral);
    [self.DeviceArray addObject:peripheral];
    if (self.scanBlock) {
        self.scanBlock(self.DeviceArray);
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectionTimeOut) object:nil];
    DDLogDebug(@"连接设备成功:%@", peripheral);
    
    self.ConnectionDevice = peripheral;
    self.ConnectionDevice.delegate = self;
    
    if (self.connectionBlock) {
        self.connectionBlock(peripheral, [self wrapperError:@"连接成功!" Code:401]);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        DDLogDebug(@"搜索服务发生错误,错误信息:%@", error);
    }
    for (CBService *service in peripheral.services) {
        [self.ServiceArray addObject:service];
        [self.ConnectionDevice discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        DDLogDebug(@"搜索特征发生错误,错误信息:%@", error);
    }
    for (CBCharacteristic *characteristic in service.characteristics) {
        [self.CharacteristicArray addObject:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        DDLogDebug(@"didWriteValueForCharacteristic接收数据发生错误,%@", error);
        return;
    }
    DDLogDebug(@"didWriteValueForCharacteristic写入值发生改变,%@", error);
}

//单次设备数据传回
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        DDLogDebug(@"0726 didUpdateValueForCharacteristic接收数据发生错误,%@", error);
        return;
    }
    
//    NSLog(@"0727 %@, type: %d", characteristic.value, [characteristic.value isKindOfClass:[NSData class]]);
    NSData *data = characteristic.value;
    uint8_t *data_byte = (uint8_t *)[data bytes];
    double heartRate = data_byte[13];
    [WHIUserDefaults sharedDefaults].heartRate = heartRate;
    NSLog(@"0727 %f", [WHIUserDefaults sharedDefaults].heartRate);
}

//订阅状态下数据传回
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        DDLogDebug(@"0726 didUpdateNotificationStateForCharacteristic接收数据发生错误,%@", error);
        return;
    }
    NSData *data = characteristic.value;
    uint8_t *data_byte = (uint8_t *)[data bytes];
    double heartRate = data_byte[13];
    [WHIUserDefaults sharedDefaults].heartRate = heartRate;
//    NSString *string=[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
//    DDLogDebug(@"0726 NotificationState收到的数据为%@", string);
}
#pragma mark - getter
- (BOOL)isReady {
    return self.state == CBCentralManagerStatePoweredOn ? YES : NO;
}

- (BOOL)isConnection {
    return self.ConnectionDevice.state == CBPeripheralStateConnected ? YES : NO;
}


@end
