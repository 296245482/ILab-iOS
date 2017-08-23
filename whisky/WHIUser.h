//
//  WHIUser.h
//  whisky
//
//  Created by QiuFeng on 5/26/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHIBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WHIUser : WHIBaseModel

@property (nonatomic, copy, nullable) NSString *name;
@property (nonatomic, copy, nullable) NSString *password;
@property (nonatomic, copy, nullable) NSString *firstname;  ////姓
@property (nonatomic, copy, nullable) NSString *lastname;   //名         后台傻逼
@property (nonatomic, copy, nullable) NSString *email;
@property (nonatomic, assign) NSInteger sex;            //1表示男 2表示女
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *code; 


@end

NS_ASSUME_NONNULL_END
