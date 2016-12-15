//
//  SUIBaseModel.h
//  erp
//
//  Created by QiuFeng on 11/2/15.
//  Copyright © 2015 www.sui.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mantle.h"

NS_ASSUME_NONNULL_BEGIN

@interface WHIBaseModel : MTLModel<MTLJSONSerializing>

/**
 *  主键 用作数据库保存的唯一识别
 */
@property (nonatomic, copy) NSString *objectId;

@end

NS_ASSUME_NONNULL_END
