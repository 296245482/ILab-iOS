//
//  SUIClient.m
//  erp
//
//  Created by QiuFeng on 11/2/15.
//  Copyright © 2015 www.sui.me. All rights reserved.
//

#import "WHIClient.h"
#import "AFNetworkActivityLogger.h"
#import "WHIClientConfigure.h"
#import "WHIJSONResponseSerializer.h"

@interface WHIClient ()

@property (nonatomic, strong) AFHTTPSessionManager *httpClient;
@property (nonatomic, strong) AFURLSessionManager *sessionClient;

@end


//服务器地址
static NSString * const WHIBaseUrl = @"http://106.14.63.93/pm25/web/restful/";

@implementation WHIClient

#pragma mark - Init

static WHIClient *_sharedClient;

+ (instancetype)sharedClient {
    static dispatch_once_t oneceToken;
    dispatch_once(&oneceToken, ^() {
        _sharedClient = [[self alloc] init];
    });
    return _sharedClient;
}

- (void)initHttpClient {
    self.httpClient = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:WHIBaseUrl]];
    self.httpClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    self.httpClient.completionQueue = dispatch_queue_create("com.alamofire.response.queue", nil);
    self.httpClient.responseSerializer = [WHIJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    self.httpClient.requestSerializer = [AFJSONRequestSerializer serializer];
    [self addDefaultHttpHeader];
}

- (void)initSessionClient {
    self.sessionClient = [[AFURLSessionManager alloc] init];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.sessionClient = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
}

- (instancetype)init {
    NSAssert(_sharedClient == nil, @"User Shared Client");
    if (self = [super init]) {
        [self initHttpClient];
        [self initSessionClient];
    }
    return self;
}

- (void)addDefaultHttpHeader {
    UIDevice *currentDevice = [UIDevice currentDevice];
    [self.httpClient.requestSerializer setValue:currentDevice.systemVersion forHTTPHeaderField:@"SUI_DeviceSystemVersion"];
    [self.httpClient.requestSerializer setValue:[NSLocale preferredLanguages][0] forHTTPHeaderField:@"SUI_Launguage"];
}

#pragma mark - Http Client

- (void)showHttpLog {
#ifdef DEBUG
    [[AFNetworkActivityLogger sharedLogger] startLogging];
    [[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelDebug];
#endif
}

- (void)get:(NSString *)path parameters:(id)params complete:(CompleteBlock)complete {
    NSParameterAssert(path);
    [self showHttpLog];
    NSMutableDictionary *requestParams = [NSMutableDictionary dictionary];
    [requestParams addEntriesFromDictionary:params];
    if ([self.tokenConfigDelegate clientToken:self]) {
        [self.httpClient.requestSerializer setValue:[self.tokenConfigDelegate clientToken:self] forHTTPHeaderField:@"token"];
    }
    
    [self.httpClient GET:path parameters:requestParams success:^(NSURLSessionTask *task, id response) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            complete(response, nil);
        });
 
    } failure:^(NSURLSessionTask *task, NSError *error) {
        DDLogError(@"%@", error.localizedDescription);
        dispatch_async(dispatch_get_main_queue(), ^() {
            complete(nil, error);
        });
    }];
}

- (void)getPredict:(NSString *)path parameters:(id)params complete:(CompleteBlock)complete {
    NSParameterAssert(path);
    [self showHttpLog];
    NSMutableDictionary *requestParams = [NSMutableDictionary dictionary];
    [requestParams addEntriesFromDictionary:params];
    if ([self.tokenConfigDelegate clientToken:self]) {
        [self.httpClient.requestSerializer setValue:[self.tokenConfigDelegate clientToken:self] forHTTPHeaderField:@"token"];
    }
    
    [self.httpClient GET:@"http://106.14.63.93:8080/predict" parameters:requestParams success:^(NSURLSessionTask *task, id response) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            complete(response, nil);
        });
        
    } failure:^(NSURLSessionTask *task, NSError *error) {
        DDLogError(@"%@", error.localizedDescription);
        dispatch_async(dispatch_get_main_queue(), ^() {
            complete(nil, error);
        });
    }];
}

- (void)postHeart:(NSString *)path parameters:(id)params complete:(CompleteBlock)complete {
    NSParameterAssert(path);
    [self showHttpLog];
    NSMutableDictionary *requestParams = [NSMutableDictionary dictionary];
    [requestParams addEntriesFromDictionary:params];
    if ([self.tokenConfigDelegate clientToken:self]) {
        [self.httpClient.requestSerializer setValue:[self.tokenConfigDelegate clientToken:self] forHTTPHeaderField:@"token"];
    }
    
    [self.httpClient GET:@"http://106.14.63.93:8080/post" parameters:requestParams success:^(NSURLSessionTask *task, id response) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            complete(response, nil);
        });
        
    } failure:^(NSURLSessionTask *task, NSError *error) {
        DDLogError(@"%@", error.localizedDescription);
        dispatch_async(dispatch_get_main_queue(), ^() {
            complete(nil, error);
        });
    }];
}

- (void)get:(NSString *)path parameters:(id)params configure:(WHIClientConfigure *)configure complete:(CompleteBlock)complete {
    
    NSParameterAssert(path);
    [self showHttpLog];
   
    NSMutableDictionary *requestParams = [NSMutableDictionary dictionary];
    [requestParams addEntriesFromDictionary:params];
    if (configure) {
        if (configure.requiredToken) {
            if ([self.tokenConfigDelegate clientToken:self]) {
                // throw an error
            }
        }
    }
    
    if ([self.tokenConfigDelegate clientToken:self]) {
        [self.httpClient.requestSerializer setValue:[self.tokenConfigDelegate clientToken:self] forHTTPHeaderField:@"token"];
    }

    [self.httpClient GET:path parameters:requestParams success:^(NSURLSessionTask *task, id response) {
        if (configure.onCompletionQueue) {
            complete(response, nil);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(response, nil);
            });
        }
    } failure:^(NSURLSessionTask *task, NSError *error) {
        DDLogError(@"%@", error.localizedDescription);
        if (configure.onCompletionQueue) {
            complete(nil, error);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, error);
            });
        }
    }];
}

- (void)post:(NSString *)path parameters:(id)params complete:(CompleteBlock)complete {
    NSParameterAssert(path);
    [self showHttpLog];
    
    if ([self.tokenConfigDelegate clientToken:self]) {
        [self.httpClient.requestSerializer setValue:[self.tokenConfigDelegate clientToken:self] forHTTPHeaderField:@"token"];
    }
    [self.httpClient POST:path parameters:params success:^(NSURLSessionTask *task, id response) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            complete(response, nil);
        });
    } failure:^(NSURLSessionTask *task, NSError *error) {
        DDLogError(@"%@", error.localizedDescription);
        dispatch_async(dispatch_get_main_queue(), ^() {
            complete(nil, error);
        });
    }];
}

- (void)post:(NSString *)path parameters:(id)params configure:(WHIClientConfigure *)configure complete:(CompleteBlock)complete {
    NSParameterAssert(path);
    [self showHttpLog];
    
    if ([self.tokenConfigDelegate clientToken:self]) {
        [self.httpClient.requestSerializer setValue:[self.tokenConfigDelegate clientToken:self] forHTTPHeaderField:@"token"];
    }

    [self.httpClient POST:path parameters:params success:^(NSURLSessionTask *task, id response) {
        if (configure.onCompletionQueue) {
            complete(response, nil);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(response, nil);
            });
        }
    } failure:^(NSURLSessionTask *task, NSError *error) {
        DDLogError(@"%@", error.localizedDescription);
        if (configure.onCompletionQueue) {
            complete(nil, error);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, error);
            });
        }
    }];
}

- (void)deleted:(NSString *)path parameters:(id)params complete:(CompleteBlock)complete {
    NSParameterAssert(path);
    [self showHttpLog];
    
    if ([self.tokenConfigDelegate clientToken:self]) {
        [self.httpClient.requestSerializer setValue:[self.tokenConfigDelegate clientToken:self] forHTTPHeaderField:@"token"];
    }
    [self.httpClient DELETE:path parameters:params success:^(NSURLSessionTask *task, id response) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            complete(response, nil);
        });
    } failure:^(NSURLSessionTask *task, NSError *error) {
        DDLogError(@"%@", error.localizedDescription);
        dispatch_async(dispatch_get_main_queue(), ^() {
            complete(nil, error);
        });
    }];
}

- (void)deleted:(NSString *)path parameters:(id)params configure:(WHIClientConfigure *)configure complete:(CompleteBlock)complete {
    NSParameterAssert(path);
    [self showHttpLog];
    
    if ([self.tokenConfigDelegate clientToken:self]) {
        [self.httpClient.requestSerializer setValue:[self.tokenConfigDelegate clientToken:self] forHTTPHeaderField:@"token"];
    }
    
    [self.httpClient DELETE:path parameters:params success:^(NSURLSessionTask *task, id response) {
        if (configure.onCompletionQueue) {
            complete(response, nil);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(response, nil);
            });
        }
    } failure:^(NSURLSessionTask *task, NSError *error) {
        DDLogError(@"%@", error.localizedDescription);
        if (configure.onCompletionQueue) {
            complete(nil, error);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, error);
            });
        }
    }];
}

@end

