//
//  BlueToothDataViewController.m
//  whisky
//
//  Created by Jackie-iLab on 2017/7/26.
//  Copyright © 2017年 www.qiufeng.me. All rights reserved.
//

#import "BlueToothDataViewController.h"
#import "WHIUserDefaults.h"

@interface BlueToothDataViewController (){
    dispatch_source_t _timer;
}
@property (weak, nonatomic) IBOutlet UILabel *heartRate;

@property (nonatomic, strong) NSTimer *autoRefresh;

@end

@implementation BlueToothDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.autoRefresh = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(refreshHeartRate) userInfo:nil repeats:YES];
    [self.autoRefresh fire];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHeartRate) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshHeartRate{
    _heartRate.text = [NSString stringWithFormat:@"%f", [WHIUserDefaults sharedDefaults].heartRate];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
