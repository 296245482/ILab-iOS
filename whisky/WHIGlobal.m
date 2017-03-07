//
//  WHIGlobal.m
//  whisky
//
//  Created by QiuFeng on 5/23/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHIGlobal.h"

@implementation WHIGlobal

+ (instancetype)sharedGlobal {
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

@end
