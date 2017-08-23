//
//  SUIClient.h
//  erp
//
//  Created by QiuFeng on 11/2/15.
//  Copyright © 2015 www.sui.me. All rights reserved.
//

@import AFNetworking;
#import "WHIClientConfigure.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^CompleteBlock)           (id _Nullable result, NSError * _Nullable error);
typedef void (^ProgressBlock)           (NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite);
typedef void (^BoolCompleteBlock)       (BOOL success, NSError * _Nullable error);
typedef void (^UrlCompleteBlock)        (NSURL * _Nullable url, NSError * _Nullable error);
typedef void (^StringCompleteBlock)     (NSString * _Nullable string, NSError * _Nullable error);
typedef void (^DictionaryCompleteBlock) (NSDictionary * _Nullable dictionary, NSError * _Nullable error);
typedef void (^ArrayCompleteBlock)      (NSArray * _Nullable array, NSError * _Nullable error);
typedef void (^taskUploadStartBlock)    (NSURLSessionUploadTask * _Nullable task, NSError * _Nullable error);

@class WHIClient;

@protocol SUIClientTokenConfig <NSObject>

@required

- (nullable NSString *)clientToken:(WHIClient *)client;

@optional

- (void)client:(WHIClient *)client tokenUnauthorize:(nullable NSString *)token;

@end

@interface WHIClient : NSObject

+ (instancetype)sharedClient;

/**
 *  主线程返回 调用block
 *  默认使用token 如果没有token 就不使用token
 *  不做不带token的检查
 */
- (void)get:(NSString *)path parameters:(nullable id)params complete:(CompleteBlock)complete;
- (void)getPredict:(NSString *)path parameters:(nullable id)params complete:(CompleteBlock)complete;
- (void)postHeart:(NSString *)path parameters:(id)params complete:(CompleteBlock)complete;

/**
 *  带 configure 默认返回不在主线程 调用block 方便可以使用数据库存储
 */
- (void)get:(NSString *)path parameters:(nullable id)params configure:(WHIClientConfigure *)configure complete:(CompleteBlock)complete;

/**
 *  主线程返回 调用block
 *  post 请求 默认带token
 */
- (void)post:(NSString *)path parameters:(nullable id)params complete:(CompleteBlock)complete;
/**
 *  post 不会使用数据库缓存
 *  带 configure 返回不在主线程 调用block 方便可以使用数据库存储
 */
- (void)post:(NSString *)path parameters:(nullable id)params configure:(WHIClientConfigure *)configure complete:(CompleteBlock)complete;


- (void)deleted:(NSString *)path parameters:(nullable id)params complete:(CompleteBlock)complete;
- (void)deleted:(NSString *)path parameters:(nullable id)params configure:(WHIClientConfigure *)configure complete:(CompleteBlock)complete;

@property (nonatomic, weak) id<SUIClientTokenConfig> tokenConfigDelegate;

@end

NS_ASSUME_NONNULL_END

