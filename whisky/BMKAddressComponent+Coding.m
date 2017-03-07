//
//  BMKAddressComponent+Coding.m
//  whisky
//
//  Created by QiuFeng on 4/25/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "BMKAddressComponent+Coding.h"

@interface BMKAddressComponent() <NSCoding>

@end

@implementation BMKAddressComponent (Coding)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.streetNumber = [coder decodeObjectForKey:@"streetNumber"];
        self.streetName = [coder decodeObjectForKey:@"streetName"];
        self.district = [coder decodeObjectForKey:@"district"];
        self.city = [coder decodeObjectForKey:@"city"];
        self.province = [coder decodeObjectForKey:@"province"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.streetNumber forKey:@"streetNumber"];
    [coder encodeObject:self.streetName forKey:@"streetName"];
    [coder encodeObject:self.district forKey:@"district"];
    [coder encodeObject:self.city forKey:@"city"];
    [coder encodeObject:self.province forKey:@"province"];
}

@end

#pragma clang diagnostic pop 