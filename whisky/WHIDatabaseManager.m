//
//  DatabaseManager.m
//  whisky
//
//  Created by QiuFeng on 4/22/16.
//  Copyright © 2016 www.qiufeng.me. All rights reserved.
//

#import "WHIDatabaseManager.h"
#import "NSDate+Calendar.h"
#import "NSDate+Formatter.h"
#import "FMDB.h"

@interface WHIDatabaseManager ()

@property (nonatomic, strong) NSString *databasePath;
@property (atomic, strong) FMDatabaseQueue *databaseQueue;

@end

@implementation WHIDatabaseManager

static dispatch_once_t onceToken;
static WHIDatabaseManager *manager = nil;

+ (instancetype)sharedManager {
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        [manager createTable];
        manager.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:manager.databasePath];
    });
    return manager;
}

- (void)deallocDatabase {
    onceToken = 0;
    manager = nil;
}

#pragma mark - Accessors

- (NSString *)databasePath {
    if (_databasePath == nil) {
        _databasePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        _databasePath = [_databasePath stringByAppendingPathComponent:@"whisky.sqlite"];
        DDLogWarn(@"DataBasePath: %@", _databasePath);
    }
    return _databasePath;
}


- (void)createTable {
    FMDatabase * db = [FMDatabase databaseWithPath:self.databasePath];
    if ([db open]) {
        if ([db tableExists:@"PMData"]) {
            if (![db columnExists:@"upload" inTableWithName:@"PMData"]) {
                [db executeUpdate:@"ALTER TABLE PMData ADD COLUMN upload Bool DEFAULT false"];
            }
        } else {
            NSString * sql = @"CREATE TABLE 'PMData' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL , 'latitude' DOUBLE, 'longitude' DOUBLE, 'date' DOUBLE, 'outdoor' BOOL, 'status' INTEGER, 'steps' INTEGER, 'avg_rate' DOUBLE, 'ventilation_volume' DOUBLE, 'PM' DOUBLE,  'source' INTEGER, 'upload' Bool DEFAULT false)";
            BOOL res = [db executeUpdate:sql];
            if (!res) {
                DDLogDebug(@"error when creating db table");
            } else {
                DDLogDebug(@"succ to creating db table");
            }
        }
        
        
        [db close];
    }
}

- (void)showDBLog {
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = @"SELECT * FROM PMData";
        FMResultSet *queryResult = [db executeQuery:sql];
        while ([queryResult next]) {
            double timePoint = [queryResult doubleForColumn:@"date"];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:timePoint];
            float timePointPM =  [queryResult doubleForColumn:@"PM"];
            double breath = [queryResult doubleForColumn:@"ventilation_volume"];
            DDLogInfo(@"Date: %@, PM:%f breath:%lf", [date whi_dateWithFormat:@"yyyy-MM-dd HH:mm:ss"], timePointPM, breath);
        }
    }];
}

- (void)showToDayDBLog:(NSDate *)date {
    NSDate *today = [date dateToday];
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM PMData where %f < date", [today timeIntervalSince1970]];
        FMResultSet *queryResult = [db executeQuery:sql];
        while ([queryResult next]) {
            double timePoint = [queryResult doubleForColumn:@"date"];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:timePoint];
            float timePointPM =  [queryResult doubleForColumn:@"PM"];
            DDLogInfo(@"Date: %@, PM:%f", [date whi_dateWithFormat:@"yyyy-MM-dd HH:mm:ss"], timePointPM);
        }
    }];
}

- (void)insertData:(WHIData *)data complete:(void (^)(BOOL))complete {
    if (data == nil) {
        complete(NO);
    }
    if (data.date == nil) {
        complete(NO);
    }
  
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = @"insert into PMData (latitude, longitude, date, outdoor, status, steps, avg_rate, ventilation_volume, PM, source, upload) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        BOOL success = [db executeUpdate:sql, @(data.latitude), @(data.longitude), @([data.date timeIntervalSince1970]), @(data.outdoor), @(data.status), @(data.steps), @(data.avg_rate), @(data.ventilation_volume), @(data.pm25), @(data.source), @(NO)];
        if (!success) {
            *rollback = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(NO);
            });
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(YES);
        });
    }];
}

- (void)getTodayData:(NSDate *)date complete:(void (^)(NSArray * _Nonnull, NSArray * _Nonnull))complete {
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSInteger timerCount = [date timeIntervalSinceDate:[date dateToday]];
        NSMutableArray *pmResult = [NSMutableArray array];
        NSMutableArray *breathResult = [NSMutableArray array];
        for (int i = 0; i < timerCount / kToDayInterval; i++) {
            NSDate *startDate = [NSDate dateWithTimeInterval:i * kToDayInterval sinceDate:[date dateToday]];
            NSDate *endDate = [NSDate dateWithTimeInterval:(i + 1) * kToDayInterval sinceDate:[date dateToday]];
            NSString *sql = [NSString stringWithFormat:@"SELECT PM, ventilation_volume FROM PMData where %f < date and date <= %f", [startDate timeIntervalSince1970], [endDate timeIntervalSince1970]];
            FMResultSet *queryResult = [db executeQuery:sql];
            float sum = 0;
            float breathSum = 0;
            NSInteger count = 0;
            while ([queryResult next]) {
                float timePointPM = [queryResult doubleForColumn:@"PM"];
                float breathSumPoint = [queryResult doubleForColumn:@"ventilation_volume"];
                count = count + 1;
                sum = sum + timePointPM;
                breathSum = breathSum + breathSumPoint;
            }
            if (count != 0) {
                sum = sum / count;
                breathSum = breathSum / count;
            }
//            DDLogDebug(@"Query Today PMStart: %@ End: %@, pm: %f", [startDate whi_dateWithFormat:@"HH:mm:ss"], [endDate whi_dateWithFormat:@"HH:mm:ss"], sum);
            [pmResult addObject:@(sum)];
            [breathResult addObject:@(breathSum)];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(breathResult, pmResult);
        });

    }];
}

- (void)getTwoHourData:(NSDate *)date complete:(void (^)(NSArray * _Nonnull, NSArray * _Nonnull))complete {
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSInteger timerCount = [date timeIntervalSinceDate:[date dateByAddingHour:-2]];
        NSMutableArray *pmResult = [NSMutableArray array];
        NSMutableArray *breathResult = [NSMutableArray array];
        for (int i = 0; i < timerCount / kHourInterval; i++) {
            NSDate *startDate = [NSDate dateWithTimeInterval:i * kHourInterval sinceDate:[date dateByAddingHour:-2]];
            NSDate *endDate = [NSDate dateWithTimeInterval:(i + 1) * kHourInterval sinceDate:[date dateByAddingHour:-2]];
            NSString *sql = [NSString stringWithFormat:@"SELECT PM, ventilation_volume FROM PMData where %f < date and date <= %f", [startDate timeIntervalSince1970], [endDate timeIntervalSince1970]];
            FMResultSet *queryResult = [db executeQuery:sql];
            float sum = 0;
            float breathSum = 0;
            NSInteger count = 0;
            while ([queryResult next]) {
                float timePointPM = [queryResult doubleForColumn:@"PM"];
                float breathSumPoint = [queryResult doubleForColumn:@"ventilation_volume"];
                sum = sum + timePointPM;
                breathSum = breathSum + breathSumPoint;
                count = count + 1;
            }
            if (count != 0) {
                sum = sum / count;
                breathSum = breathSum / count;
            }
//            DDLogDebug(@"Query Today PMStart: %@ End: %@, pm: %f", [startDate whi_dateWithFormat:@"HH:mm:ss"], [endDate whi_dateWithFormat:@"HH:mm:ss"], sum);
            [pmResult addObject:@(sum)];
            [breathResult addObject:@(breathSum)];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(breathResult, pmResult);
        });
        
    }];
}

- (void)getHourData:(NSDate *)date complete:(void (^)(NSArray * _Nonnull, NSArray * _Nonnull))complete {
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSInteger timerCount = [date timeIntervalSinceDate:[date dateByAddingHour:-1]];
        NSMutableArray *pmResult = [NSMutableArray array];
        NSMutableArray *breathResult = [NSMutableArray array];
        for (int i = 0; i < timerCount / kHourInterval; i++) {
            NSDate *startDate = [NSDate dateWithTimeInterval:i * kHourInterval sinceDate:[date dateByAddingHour:-1]];
            NSDate *endDate = [NSDate dateWithTimeInterval:(i + 1) * kHourInterval sinceDate:[date dateByAddingHour:-1]];
            NSString *sql = [NSString stringWithFormat:@"SELECT PM, ventilation_volume FROM PMData where %f < date and date <= %f", [startDate timeIntervalSince1970], [endDate timeIntervalSince1970]];
            FMResultSet *queryResult = [db executeQuery:sql];
            float sum = 0;
            float breathSum = 0;
            NSInteger count = 0;
            while ([queryResult next]) {
                float timePointPM = [queryResult doubleForColumn:@"PM"];
                float breathSumPoint = [queryResult doubleForColumn:@"ventilation_volume"];
                count = count + 1;
                sum = sum + timePointPM;
                breathSum = breathSum + breathSumPoint;
            }
            if (count != 0) {
                sum = sum / count;
                breathSum = breathSum / count;
            }
//            DDLogDebug(@"Query Today PMStart: %@ End: %@, pm: %f", [startDate whi_dateWithFormat:@"HH:mm:ss"], [endDate whi_dateWithFormat:@"HH:mm:ss"], sum);
            [pmResult addObject:@(sum)];
            [breathResult addObject:@(breathSum)];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(breathResult, pmResult);
        });
        
    }];
}

- (void)deleteOverDueData:(NSDate *)nowDate {
    NSDate *date = nowDate ?: [NSDate date];
    NSDate *weekDate = [date dateByAddingWeek:-1];
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = [NSString stringWithFormat:@"Delete From PMData where date < %f", [weekDate timeIntervalSince1970]];
        BOOL success = [db executeUpdate:sql];
        if (!success) {
            *rollback = YES;
        }
    }];
}

- (void)queryForUnUploadData:(int)limit complete:(void (^)(NSArray * _Nonnull))complete {
    if (limit == 0) {
        limit = 10;
    }
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSMutableArray *result = [NSMutableArray array];
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM PMData where upload = ? or upload is null ORDER BY date DESC LIMIT %d", limit];
        FMResultSet *queryResult = [db executeQuery:sql, @(NO)];
        while ([queryResult next]) {
            WHIData *data = [[WHIData alloc] init];
            double timePoint = [queryResult doubleForColumn:@"date"];
            data.date = [NSDate dateWithTimeIntervalSince1970:timePoint];
            data.pm25 =  [queryResult doubleForColumn:@"PM"];
            data.ventilation_volume = [queryResult doubleForColumn:@"ventilation_volume"];
            data.outdoor = [queryResult boolForColumn:@"outdoor"];
            data.steps = [queryResult intForColumn:@"steps"];
            data.avg_rate = [queryResult doubleForColumn:@"avg_rate"];
            data.source = [queryResult intForColumn:@"source"];
            data.longitude = [queryResult doubleForColumn:@"longitude"];
            data.latitude = [queryResult doubleForColumn:@"latitude"];
            data.status = [queryResult intForColumn:@"status"];
            data.databaseid = [queryResult intForColumn:@"id"];
            data.upload = [queryResult boolForColumn:@"upload"];
            [result addObject:data];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(result);
        });
    }];
}


- (void)queryForRemainData:(int)limit date:(NSDate *)date complete:(void (^)(NSArray * _Nonnull))complete{
    if (limit == 0) {
        limit = 10;
    }
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSMutableArray *result = [NSMutableArray array];
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM PMData where (upload = ? or upload is null) and date < '%@' ORDER BY date DESC LIMIT %d", date, limit];
        FMResultSet *queryResult = [db executeQuery:sql, @(NO)];
        while ([queryResult next]) {
            WHIData *data = [[WHIData alloc] init];
            double timePoint = [queryResult doubleForColumn:@"date"];
            data.date = [NSDate dateWithTimeIntervalSince1970:timePoint];
            data.pm25 =  [queryResult doubleForColumn:@"PM"];
            data.ventilation_volume = [queryResult doubleForColumn:@"ventilation_volume"];
            data.outdoor = [queryResult boolForColumn:@"outdoor"];
            data.steps = [queryResult intForColumn:@"steps"];
            data.avg_rate = [queryResult doubleForColumn:@"avg_rate"];
            data.source = [queryResult intForColumn:@"source"];
            data.longitude = [queryResult doubleForColumn:@"longitude"];
            data.latitude = [queryResult doubleForColumn:@"latitude"];
            data.status = [queryResult intForColumn:@"status"];
            data.databaseid = [queryResult intForColumn:@"id"];
            data.upload = [queryResult boolForColumn:@"upload"];
            [result addObject:data];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(result);
        });
    }];
}

- (void)updateToUpload:(NSArray *)pmData {
    if (pmData == nil || pmData.count == 0) {
        return;
    }
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (WHIData *data in pmData) {
            NSString *sql = [NSString stringWithFormat:@"UPDATE PMData SET upload = ? WHERE id = ?"];
            [db executeUpdate:sql, @(data.upload), @(data.databaseid)];
        }
    }];
}

@end
