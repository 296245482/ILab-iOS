//
//  SUIJONResponseSerializer.m
//  erp
//
//  Created by QiuFeng on 11/3/15.
//  Copyright © 2015 www.sui.me. All rights reserved.
//

#import "WHIClient.h"
#import "WHIJSONResponseSerializer.h"

@implementation WHIJSONResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing  _Nullable *)error {
    NSError *aError;
    id  responseObject = [super responseObjectForResponse:response data:data error:&aError];
    if (aError) {
        DDLogError(@"%@", aError);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
            id body = responseObject[@"body"];
            if ([body isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary *userInfo = [body mutableCopy];
                NSInteger errorCode = [body[@"errorCode"] integerValue];
                NSString *errorDescription = body[@"errorDescription"];
                userInfo[NSLocalizedDescriptionKey] = errorDescription;
                *error = [NSError errorWithDomain:aError.domain code:errorCode userInfo:userInfo];
                if (errorCode == 101 || errorCode == 103 || errorCode == 2003 || errorCode == 2001 || errorCode == 2002) { //／token 错误验证码
                    NSString *token = [[WHIClient sharedClient].tokenConfigDelegate clientToken:[WHIClient sharedClient]];
                    if ([[WHIClient sharedClient].tokenConfigDelegate respondsToSelector:@selector(client:tokenUnauthorize:)]) {
                        [[WHIClient sharedClient].tokenConfigDelegate client:[WHIClient sharedClient] tokenUnauthorize:token];
                    }
                    DDLogError(@"token error: %@, code: %ld", token ?: @"", (long)errorCode);
     
                } else if (errorCode == 50101) {
#ifdef DEBUG
                    NSAssert(NO, @"sign error");
#endif
                }
            }
        } else {
            *error = aError;
        }
    }
    return responseObject;
}

@end
