//
//  WHIUdpSocket.m
//  whisky
//
//  Created by QiuFeng on 6/20/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHIUdpSocket.h"

@import CocoaAsyncSocket;

@interface WHIUdpSocket ()<AsyncUdpSocketDelegate>

@end

@implementation WHIUdpSocket{
    AsyncUdpSocket *socket;
}

static dispatch_once_t onceToken;
static WHIUdpSocket *manager = nil;

+ (instancetype)sharedManager {
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
       
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        socket = [[AsyncUdpSocket alloc] initWithDelegate:self];
        NSError *bindError;
        if (![socket bindToPort:0 error:&bindError]) {
            self.deviceId = nil;
//            NSLog(@"Error binding: %@", bindError);
        }
    }
    return self;
}

- (void)trySend {
//    NSLog(@"%d", socket.isConnected);
    NSError *error;
    [socket enableBroadcast:YES error:&error];
    NSData *data = [@"?ip" dataUsingEncoding:NSUTF8StringEncoding];
    [socket sendData:data toHost:@"255.255.255.255" port:6666 withTimeout:30 tag:0];
    [socket receiveWithTimeout:30 tag:0];
}

#pragma mark - <AsyncUdpSocketDelegate>

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error{
    DDLogDebug(@"not received");
     self.deviceId = nil;
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    DDLogDebug(@"%@",error);
    DDLogDebug(@"not send");
    self.deviceId = nil;
}

- (void)onUdpSocketDidClose:(AsyncUdpSocket *)sock{
    DDLogDebug(@"closed");
     self.deviceId = nil;
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port {
    NSDictionary *myDictionary = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if ([myDictionary isKindOfClass:[NSDictionary class]]) {
        self.deviceId = myDictionary[@"sn"];
//        NSLog(@"got device id");
    } else {
        self.deviceId = nil;
//        NSLog(@"didn't got device id");
    }
    return YES;
}

@end
