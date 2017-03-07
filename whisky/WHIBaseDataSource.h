//
//  SUIBaseDataSource.h
//  erp
//
//  Created by QiuFeng on 11/3/15.
//  Copyright © 2015 www.sui.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WHIBaseDataSource : NSObject

- (NSInteger)numberOfSections;

- (NSInteger)numberOfObjectsInSection:(NSInteger)section;

- (nullable id)objectAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
