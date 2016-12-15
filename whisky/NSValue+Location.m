//
//  NSValue+Location.m
//  whisky
//
//  Created by QiuFeng on 4/27/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "NSValue+Location.h"

@implementation NSValue (Location)

+ (instancetype)valueWithLocation:(CLLocationCoordinate2D)location {
    CGPoint point = CGPointMake(location.latitude, location.longitude);
    return [NSValue valueWithCGPoint:point];
}

- (CLLocationCoordinate2D)locationValue {
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [self CGPointValue].x;
    coordinate.longitude = [self CGPointValue].y;
    return coordinate;
}

@end
