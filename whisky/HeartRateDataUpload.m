//
//  HeartRateDataUpload.m
//  whisky
//
//  Created by Jackie-iLab on 2017/9/13.
//  Copyright © 2017年 www.qiufeng.me. All rights reserved.
//

#import "HeartRateDataUpload.h"
#import "WHIUser+Manager.h"
#import "NSDate+Formatter.h"
#import "WHIUserDefaults.h"

@implementation HeartRateData (Manager)

- (NSDictionary *)heartDataToParams{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"user_id"] = self.user_id ?: @"";
    dic[@"user_name"] = [NSString stringWithFormat:@"%@", self.user_name];
    dic[@"time_point"] = [self.time_point whi_dateWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    dic[@"heart_rate"] = [NSString stringWithFormat:@"%d", (int)self.heart_rate];
    dic[@"longitude"] = [NSString stringWithFormat:@"%lf", self.longitude];
    dic[@"latitude"] = [NSString stringWithFormat:@"%lf", self.latitude];
    return dic;
}

+ (void)uploadHeart:(NSArray *)result complete:(ArrayCompleteBlock)complete {
    if (result == nil) {
        complete(nil, nil);
        return;
    }
    //    NSLog(@"post result is %@",result);
    NSMutableArray *arrayData = [NSMutableArray array];
    for (HeartRateData *data in result) {
        if (data.upload == NO) {
            [arrayData addObject:[data heartDataToParams]];
            
        }
    }
    NSDictionary *paras = @{@"data": arrayData};
    
    
//    NSLog(@"paras is %@", paras);
//    NSLog(@"paras is %d", [NSJSONSerialization isValidJSONObject:paras]);
    
    
//    NSError *err=nil;
//    id jsonData = [NSJSONSerialization dataWithJSONObject:paras options:NSJSONWritingPrettyPrinted error:nil];
//    NSLog(@"json data is %@", jsonData);
//    
//    
//    NSString *myParas = @"";
//    if (! jsonData) {
//        NSLog(@"Got an error: %@", err);
//    } else {
//        myParas = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    }
//    NSLog(@"myParas is %@",myParas);
    

    [[WHIClient sharedClient] postHeart:@"" parameters:paras complete:^(id successResult, NSError * _Nullable error) {
        complete(result, error);
    }];
    
}


@end
