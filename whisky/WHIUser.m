//
//  WHIUser.m
//  whisky
//
//  Created by QiuFeng on 5/26/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHIUser.h"

@implementation WHIUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *params = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    params[@"objectId"] = @"userid";
    return params;
}

@end
