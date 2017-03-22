//
//  forecastAirData.m
//  whisky
//
//  Created by Jackie-iLab on 2017/3/22.
//  Copyright © 2017年 www.qiufeng.me. All rights reserved.
//

#import "forecastAirData.h"

@implementation forecastAirData

+ (NSValueTransformer *)AQIJSONTransformer {
    return [MTLValueTransformer transformerUsingReversibleBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return @([value doubleValue]);
    }];
}

+ (NSValueTransformer *)PM25JSONTransformer {
    return [MTLValueTransformer transformerUsingReversibleBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return @([value doubleValue]);
    }];
}

@end
