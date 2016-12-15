//
//  NSDate+Formatter.m
//  erp
//
//  Created by QiuFeng on 11/9/15.
//  Copyright © 2015 www.sui.me. All rights reserved.
//

#import "NSDate+Formatter.h"

@implementation NSDate (Formatter)

- (NSString *)whi_dateWithFormat:(NSString *)format {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = format;
    return [formatter stringFromDate:self];
}

- (NSString *)whi_xAxisString {
    if (self.minute == 0) {
        return [NSString stringWithFormat:@"%ld", (long)self.hour];
    } else {
        return [self whi_dateWithFormat:@"HH:mm"];
    }
}

@end
