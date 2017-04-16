//
//  WHIHealthKit.m
//  whisky
//
//  Created by QiuFeng on 5/13/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHIHealthKit.h"
#import "NSDate+Calendar.h"

@interface WHIHealthKit ()

@property (nonatomic) HKHealthStore *healthStore;

@end

@implementation WHIHealthKit

+ (instancetype)sharedHealthKit {
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}
// JC new
-(void)getStepAuthorization{
    if([HKHealthStore isHealthDataAvailable])
    {
        NSSet *readDataTypes = [self dataTypeToRead];
//        NSSet *writeDataTypes = [self dataTypeToWrite];
        
        //创建healthStore实例对象
        self.healthStore = [[HKHealthStore alloc] init];
        
        //从健康应用中获取权限
        [self.healthStore requestAuthorizationToShareTypes:nil readTypes:readDataTypes completion:^(BOOL success, NSError * _Nullable error) {
            if (success)
            {
//                NSLog(@"获取步数权限成功");
            }
            else
            {
//                NSLog(@"获取步数权限失败");
            }
        }];
    }else{
//        NSLog(@"设备不支持healthKit");
    }
}

- (NSSet *) dataTypeToRead{
    HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *distanceType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    
    return [NSSet setWithObjects:stepType,distanceType, nil];
}
- (NSSet *) dataTypeToWrite{
    HKQuantityType *stepType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *distanceType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    return [NSSet setWithObjects:stepType, distanceType, nil];
}

//JC new
-(void)queryStepCount:(NSDate *)startDate endDate:(NSDate *)endDate complete: (void (^)(double stepCount, BOOL succeed))complete {
//    NSLog(@"正在查询");
    [self getStepAuthorization];
    HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:stepType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        if (!results) {
            complete(0, NO);
            return;
        }
        double stepCount = 0;
        for(HKQuantitySample *stepSample in results) {
            HKQuantity *step = [stepSample quantity];
            stepCount += [step doubleValueForUnit:[HKUnit countUnit]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(stepCount, YES);
        });
    }];
    [self.healthStore executeQuery:query];
}

//- (void)requestAuthorization {
//    if ([HKHealthStore isHealthDataAvailable]) {
//        NSSet *readDataTypes =  [self dateTypesToRead];
//        NSSet *writeDataTypes = [self dateTypesToWrite];
//        
//        [self.healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError * _Nullable error) {
//            if (success) {
//                NSLog(@"HealthStore success");
//            }
//        }];
//    }else{
//        NSLog(@"HealthStore not avalible");
//    }
//}

///**
// *  读取Health数据
// *
// *  @return
// */
//- (NSSet *) dateTypesToRead {
//    
//    HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
//    HKQuantityType *walkingDistanceType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
//    HKQuantityType *cyclingDistanceType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling];
//    HKQuantityType *workOut = [HKObjectType quantityTypeForIdentifier:HKWorkoutTypeIdentifier];
//    return [NSSet setWithObjects:stepType, walkingDistanceType, cyclingDistanceType, workOut, nil];
//    
//}
//
///**
// *  写Health数据
// *
// *  @return
// */
//- (NSSet *) dateTypesToWrite {
//    
//    HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
//    HKQuantityType *walkingDistanceType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
//    HKQuantityType *cyclingDistanceType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling];
//    return [NSSet setWithObjects:stepType, walkingDistanceType, cyclingDistanceType, nil];
//}


#pragma mark - Accessors

- (HKHealthStore *)healthStore {
    if (_healthStore == nil) {
        _healthStore = [[HKHealthStore alloc] init];
    }
    return _healthStore;
}

//#pragma mark - Query

//- (void)getTodayBreath:(NSDate *)date complete:(void (^)(NSArray * _Nonnull))complete {
//    [self requestAuthorization];
//    date = [date dateByAddingDays:-3];
//    NSInteger timerCount = [date timeIntervalSinceDate:[date dateToday]];
//    NSMutableArray *result = [NSMutableArray array];
//    
//
//    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
//    
//    // Create a predicate to set start/end date bounds of the query
//    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:[[NSDate date] dateByAddingTimeInterval:60*60*24*-2] endDate:[NSDate date] options:HKQueryOptionStrictStartDate];
//    
//    HKQuantityType *stepType = [HKObjectType workoutType];
//    NSDate *startDate = [date dateToday];
//    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:date options:HKQueryOptionNone];
//    //NSPredicate *predicate = [HKQuery predicateForWorkoutsWithWorkoutActivityType:HKWorkoutActivityTypeRunning];
//    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:stepType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
//        HKSample *sample = results[0];
//        DDLogDebug(@"%@", sample);
//    }];
//    [self.healthStore executeQuery:query];
//    for (int i = 0; i < timerCount / kToDayInterval; i++) {
//        NSDate *startDate = [NSDate dateWithTimeInterval:i * kToDayInterval sinceDate:[date dateToday]];
//        NSDate *endDate = [NSDate dateWithTimeInterval:(i + 1) * kToDayInterval sinceDate:[date dateToday]];
//        NSString *sql = [NSString stringWithFormat:@"SELECT pm25_concen FROM PMData where %f < date and date <= %f", [startDate timeIntervalSince1970], [endDate timeIntervalSince1970]];
//        FMResultSet *queryResult = [db executeQuery:sql];
//        float sum = 0;
//        NSInteger count = 0;
//        while ([queryResult next]) {
//            float timePointPM =  [queryResult doubleForColumn:@"PM"];
//            if (timePointPM != 0) {
//                sum = sum + timePointPM;
//                count = count + 1;
//            }
//        }
//        if (count != 0) {
//            sum = sum / count;
//        }
//        DDLogDebug(@"Query Today PM, Start: %@ End: %@, pm25_concen: %f", [startDate whi_dateWithFormat:@"HH:mm:ss"], [endDate whi_dateWithFormat:@"HH:mm:ss"], sum);
//        [result addObject:@(sum)];
//    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        complete(result);
//    });
//}

/**
 *  查询步数
 *
 *  @param startDate 开始时间
 *  @param endDate   结束时间
 *  @param complete  回调
 */
//-(void)queryStepCount:(NSDate *)startDate endDate:(NSDate *)endDate complete: (void (^)(double stepCount, NSArray<__kindof HKSample *> * _Nullable results, BOOL succeed))complete {
//    HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
//    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
//    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:stepType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (!results) {
//                complete(0, nil, NO);
//                return;
//            }
//        });
//        
//        double stepCount = 0;
//        
//        for(HKQuantitySample *stepSample in results) {
//            HKQuantity *step = [stepSample quantity];
//            stepCount += [step doubleValueForUnit:[HKUnit countUnit]];
//        }
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            complete(stepCount, results, YES);
//        });
//        
//    }];
//    
//    
//    [self.healthStore executeQuery:query];
//}
//
//-(void)queryStepPerDayCount:(NSDate *)startDate endDate:(NSDate *)endDate complete: (void (^)(NSArray<NSDate *> *time, NSArray<NSNumber *> *results))complete {
//    NSMutableArray *stepResult = [NSMutableArray array];
//    NSMutableArray *timeResult = [NSMutableArray array];
//    HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
//    
//    dispatch_async(dispatch_queue_create("Query For Step", nil), ^{
//        dispatch_group_t group = dispatch_group_create();
//        for (int i = 0; i >= 0; i++) {
//            NSDate *queryStartDate = [startDate dateByAddingDays:i];
//            NSDate *queryEndDate = [startDate dateByAddingDays:i + 1];
//            if ([queryStartDate compare:endDate] != NSOrderedAscending) {
//                break;
//            }
//            [timeResult addObject:queryStartDate];
//            [stepResult addObject:@(0)];
//            dispatch_group_enter(group);
//            NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:queryStartDate endDate:queryEndDate options:HKQueryOptionNone];
//            HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:stepType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
//                if (results) {
//                    double stepCount = 0;
//                    for(HKQuantitySample *stepSample in results) {
//                        HKQuantity *step = [stepSample quantity];
//                        stepCount += [step doubleValueForUnit:[HKUnit countUnit]];
//                    }
//                    [stepResult replaceObjectAtIndex:i withObject:@(stepCount)];
//                } else {
//                    DDLogError(@"Error: %@", error.localizedDescription);
//                }
//                dispatch_group_leave(group);
//            }];
//            [self.healthStore executeQuery:query];
//        }
//        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            complete(timeResult, stepResult);
//        });
//    });
//}


@end
