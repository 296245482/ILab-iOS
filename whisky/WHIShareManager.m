
//
//  WHIShareManager.m
//  whisky
//
//  Created by QiuFeng on 5/31/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHIShareManager.h"
#import "UMSocial.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>

@interface WHIShareManager ()<UMSocialUIDelegate>

@end

@implementation WHIShareManager


static dispatch_once_t onceToken;
static WHIShareManager *manager = nil;

+ (instancetype)sharedManager {
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}


//+ (void)setupShareItemParams:(NSMutableDictionary *)shareParams view:(UIView *)view onStateChange:(SSDKShareStateChangedHandler)stateChangedHandler {
//    NSMutableArray *items = [NSMutableArray array];
//    
//    SSUIShareActionSheetItem *weibo = [SSUIShareActionSheetItem itemWithIcon:[UIImage imageNamed:@"SUIShareWeibo"] label:NSLocalizedStringFromTable(@"微博", @"ShareManager", nil) onClick:^{
//        [ShareSDK share:SSDKPlatformTypeSinaWeibo parameters:shareParams onStateChanged:stateChangedHandler];
//    }];
//    [items addObject:weibo];
//    
//    if ([WXApi isWXAppInstalled]) {
//        SSUIShareActionSheetItem *wechat = [SSUIShareActionSheetItem itemWithIcon:[UIImage imageNamed:@"SUIShareWechat"] label:NSLocalizedStringFromTable(@"微信好友", @"ShareManager", nil) onClick:^{
//            [ShareSDK share:SSDKPlatformSubTypeWechatSession parameters:shareParams onStateChanged:stateChangedHandler];
//        }];
//        [items addObject:wechat];
//        
//        SSUIShareActionSheetItem *moment = [SSUIShareActionSheetItem itemWithIcon:[UIImage imageNamed:@"SUIShareMoment"] label:NSLocalizedStringFromTable(@"朋友圈", @"ShareManager", nil) onClick:^{
//            [ShareSDK share:SSDKPlatformSubTypeWechatTimeline parameters:shareParams onStateChanged:stateChangedHandler];
//        }];
//        [items addObject:moment];
//    }
//    
//    if ([TencentOAuth iphoneQQInstalled]) {
//        SSUIShareActionSheetItem *qq = [SSUIShareActionSheetItem itemWithIcon:[UIImage imageNamed:@"SUIShareQQ"] label:@"QQ" onClick:^{
//            [ShareSDK share:SSDKPlatformTypeQQ parameters:shareParams onStateChanged:stateChangedHandler];
//        }];
//        [items addObject:qq];
//    }
//    
//    [ShareSDK showShareActionSheet:view items:items shareParams:shareParams onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
//    }];
//}
//
//+ (void)shareImage:(UIImage *)image onStateChange:(SSDKShareStateChangedHandler)stateChangedHandler {
//    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
//    [shareParams SSDKSetupShareParamsByText:@"分享内容" images:image url:nil title:@"Bio³Air" type:SSDKContentTypeImage];
//    [self setupShareItemParams:shareParams view:nil onStateChange:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
//        if (state == SSDKResponseStateSuccess) {
//            [SVProgressHUD showSuccessWithStatus:];
//        } else if (state == SSDKResponseStateFail) {
//            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
//        }
//        stateChangedHandler(state, userData, contentEntity, error);
//    }];
//
//}

- (void)setupImage:(UIImage *)image view:(UIViewController *)viewController {
    NSMutableArray *array = [NSMutableArray array];
    if ([WXApi isWXAppInstalled]) {
        [array addObject:UMShareToWechatSession];
        [array addObject:UMShareToWechatTimeline];
    }
    
    if ([TencentOAuth iphoneQQInstalled]) {
        [array addObject:UMShareToQQ];
    }
    
    [array addObject:UMShareToSina];
    
//    [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:nil];
    [UMSocialData defaultData].extConfig.wechatSessionData.wxMessageType = UMSocialWXMessageTypeImage;
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage;
    [UMSocialData defaultData].extConfig.title = @"我所处环境的 PM";
    [UMSocialData defaultData].shareImage = image;
    [UMSocialSnsService presentSnsIconSheetView:viewController
                                         appKey:@"566d299367e58e44cb005fe2"
                                      shareText:@"我所处环境的 PM"
                                     shareImage:image
                                shareToSnsNames:array
                                       delegate:self];
}

-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的平台名
        [SVProgressHUD showSuccessWithStatus:NSLocalizedStringFromTable(@"分享成功", @"ShareManager", nil)];
    }
}


@end
