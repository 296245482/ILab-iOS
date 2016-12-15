//
//  WHIUdpSocket.h
//  whisky
//
//  Created by QiuFeng on 6/20/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WHIUdpSocket : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, strong, nullable) NSString *deviceId;

- (void)trySend;

@end

NS_ASSUME_NONNULL_END