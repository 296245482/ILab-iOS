//
//  WHIUser+Manager.m
//  whisky
//
//  Created by QiuFeng on 5/27/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHIUser+Manager.h"
#import "WHIUserDefaults.h"

@implementation WHIUser (Manager)

static WHIUser *__user;
static NSString *__token;

+ (NSString *)token {
    if (__token == nil) {
        __token = [WHIUserDefaults sharedDefaults].token;
    }
    return __token;
}

+ (void)setToken:(NSString *)token {
    [WHIUserDefaults sharedDefaults].token = token;
}

+ (void)setUser:(WHIUser *)user {
    __user = user;
    [WHIUserDefaults sharedDefaults].user = __user;
    [[NSNotificationCenter defaultCenter] postNotificationName:WHIUserChangeNotification object:__user];
}

+ (WHIUser *)currentUser {
    if (__user) {
        return __user;
    } else {
        __user = [WHIUserDefaults sharedDefaults].user;
        return __user;
    }
}

- (NSDictionary *)toParams {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"name"] = self.name ?: @"";
    dic[@"password"] = self.password ?: @"";
    dic[@"email"] = self.email ?: @"";
    dic[@"firstname"] = self.firstname ?: @"";
    dic[@"lastname"] = self.lastname;
    dic[@"sex"] = @(self.sex);
    dic[@"phone"] = self.phone;
    dic[@"code"] = self.code ?: @"";
    return dic;
}

- (void)registerUser:(BoolCompleteBlock)complete {

    [[WHIClient sharedClient] post:@"users/logon" parameters:[self toParams] complete:^(id _Nullable result, NSError * _Nullable error) {
        if (result) {
            if ([result[@"status"] integerValue] != 1) {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: result[@"message"]?:@""};
                NSError *aError = [NSError errorWithDomain:@"ilab.tongji.edu.cn.pm" code:[result[@"status"] integerValue] userInfo:userInfo];
                complete(NO, aError);
            } else {
                self.objectId = result[@"userid"];
                [WHIUser setToken:result[@"access_token"]];
                [WHIUser setUser:self];
                complete(YES, nil);
            }
        } else {
            complete(NO, error);
        }
    }];
}

+ (void)login:(NSString *)name password:(NSString *)password complete:(UserCompleteBlock)complete {
    NSDictionary *params = @{@"name": name ?: @"",
                             @"password": password ?: @""};
    [[WHIClient sharedClient] post:@"users/login" parameters:params complete:^(id  _Nullable result, NSError * _Nullable error) {
        if (result) {
            if ([result[@"status"] integerValue] != 1) {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: result[@"message"]?:@""};
                NSError *aError = [NSError errorWithDomain:@"ilab.tongji.edu.cn.pm" code:[result[@"status"] integerValue] userInfo:userInfo];
                complete(nil, aError);
            } else {
                WHIUser *user = [MTLJSONAdapter modelOfClass:[WHIUser class] fromJSONDictionary:result error:&error];
                [WHIUser setToken:result[@"access_token"]];
                if (user) {
                    [WHIUser setUser:user];
                    complete(user, error);
                } else {
                    complete(nil, error);
                }
            }
        } else {
            complete(nil, error);
        }
    }];
}

+ (void)forgetPassword:(NSString *)name complete:(BoolCompleteBlock)complete {
    NSDictionary *params = @{@"name": name};
    [[WHIClient sharedClient] get:@"users/resetpassword" parameters:params complete:^(id  _Nullable result, NSError * _Nullable error) {
        if (error) {
            complete(NO, error);
        } else {
            if ([result[@"status"] integerValue] == 0) {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: result[@"message"]?:@"用户不存在"};
                NSError *aError = [NSError errorWithDomain:@"ilab.tongji.edu.cn.pm" code:[result[@"status"] integerValue] userInfo:userInfo];
                complete(nil, aError);

            } else {
                complete(YES, nil);
            }
        }
    }];
}

- (void)updatePassword:(NSString *)password complete:(BoolCompleteBlock)complete {
    NSDictionary *params = @{@"name": self.name ?: @"",
                             @"access_token": [WHIUserDefaults sharedDefaults].token ?: @"",
                             @"password": password};
    [[WHIClient sharedClient] post:@"users/updatepassword" parameters:params complete:^(id  _Nullable result, NSError * _Nullable error) {
        if (result) {
            if ([result[@"status"] integerValue] != 1) {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: result[@"message"]?:@""};
                NSError *aError = [NSError errorWithDomain:@"ilab.tongji.edu.cn.pm" code:[result[@"status"] integerValue] userInfo:userInfo];
                complete(NO, aError);
            } else {
                complete(YES, nil);
            }
        } else {
            complete(NO, error);
        }
    }];
}

+ (void)logOut {
    [self setUser:nil];
    [self setToken:nil];
}

@end
