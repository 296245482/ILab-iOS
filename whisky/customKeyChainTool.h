//
//  customKeyChainTool.h
//  whisky
//
//  Created by luo ye on 21/02/2017.
//  Copyright © 2017 www.qiufeng.me. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface customKeyChainTool : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)delete:(NSString *)service;

@end
