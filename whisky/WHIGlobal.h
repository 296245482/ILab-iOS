//
//  WHIGlobal.h
//  whisky
//
//  Created by QiuFeng on 5/23/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WHIData.h"

NS_ASSUME_NONNULL_BEGIN

@interface WHIGlobal : NSObject

+ (instancetype)sharedGlobal;

@property (nonnull, nonatomic, strong) WHIData *pmData;

@end

NS_ASSUME_NONNULL_END