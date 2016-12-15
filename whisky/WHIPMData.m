//
//  WHIPMData.m
//  whisky
//
//  Created by QiuFeng on 4/27/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHIPMData.h"

@implementation WHIPMData



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
