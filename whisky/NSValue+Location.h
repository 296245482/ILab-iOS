//
//  NSValue+Location.h
//  whisky
//
//  Created by QiuFeng on 4/27/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSValue (Location)

+ (instancetype)valueWithLocation:(CLLocationCoordinate2D)location;

@end

NS_ASSUME_NONNULL_END