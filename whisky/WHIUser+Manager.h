//
//  WHIUser+Manager.h
//  whisky
//
//  Created by QiuFeng on 5/27/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHIUser.h"
#import "WHIClient.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^UserCompleteBlock) (WHIUser * _Nullable user, NSError * _Nullable error);

static NSString *const WHIUserChangeNotification = @"WHIUserChanageNotification";

@interface WHIUser (Manager)

+ (nullable WHIUser *)currentUser;

+ (void)setUser:(nullable WHIUser *)user;

- (void)registerUser:(BoolCompleteBlock)complete;

+ (void)login:(NSString *)name password:(NSString *)password complete:(UserCompleteBlock)complete;
+ (void)logOut;

- (void)updatePassword:(NSString *)password complete:(BoolCompleteBlock)complete;

+ (void)forgetPassword:(NSString *)name complete:(BoolCompleteBlock)complete;

@end

NS_ASSUME_NONNULL_END
