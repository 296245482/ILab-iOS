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
            NSString * sql = @"CREATE TABLE 'PMData' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL , 'user_id' INTERGER, 'database_access_token' VERCHAR(32), 'time_point' DOUBLE, 'longitude' DOUBLE, 'latitude' DOUBLE, 'outdoor' BOOL, 'status' INTEGER, 'steps' INTEGER, 'heart_rate' DOUBLE, 'ventilation_rate' DOUBLE, 'ventilation_vol' DOUBLE, 'pm25_concen' DOUBLE, 'pm25_intake' DOUBLE, 'pm25_datasource' INTEGER, 'pm25_monitor' TEXT, 'APP_version' VERCHAR(30), 'upload' Bool DEFAULT false, 'connection' Bool DEFAULT ture)";
            BOOL res = [db executeUpdate:sql];
            if (!res) {
                DDLogDebug(@"error when creating db table");
            } else {
                DDLogDebug(@"succ to creating db table");
            }
        }
        if (![db tableExists:@"DeviveWifi"]) {
            NSString * sql = @"CREATE TABLE 'DeviceWifi' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL , 'device_id' VERCHAR(32), 'wifi' VERCHAR(64))";
            BOOL res = [db executeUpdate:sql];
            if (!res) {
                DDLogDebug(@"error when creating Device wifi table");
            } else {
                DDLogDebug(@"succ to creating Device Wifi table");
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
            double timePoint = [queryResult doubleForColumn:@"time_point"];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:timePoint];
            float timePointPM =  [queryResult doubleForColumn:@"pm25_concen"];
            double breath = [queryResult doubleForColumn:@"ventilation_rate"];
            DDLogInfo(@"time_point: %@, pm25_concen:%f breath:%lf", [date whi_dateWithFormat:@"yyyy-MM-dd HH:mm:ss"], timePointPM, breath);
        }
    }];
}

- (void)showToDayDBLog:(NSDate *)date {
    NSDate *today = [date dateToday];
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM PMData where %f < date", [today timeIntervalSince1970]];
        FMResultSet *queryResult = [db executeQuery:sql];
        while ([queryResult next]) {
            double timePoint = [queryResult doubleForColumn:@"time_point"];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:timePoint];
            float timePointPM =  [queryResult doubleForColumn:@"pm25_concen"];
            DDLogInfo(@"time_point: %@, pm25_concen:%f", [date whi_dateWithFormat:@"yyyy-MM-dd HH:mm:ss"], timePointPM);
        }
    }];
}

- (void)insertData:(WHIData *)data complete:(void (^)(BOOL))complete {
    if (data == nil) {
        complete(NO);
    }
    if (data.time_point == nil) {
        complete(NO);
    }
  
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = @"insert into PMData (user_id, database_access_token, time_point, longitude, latitude, outdoor, status, steps, heart_rate, ventilation_rate, ventilation_vol, pm25_concen, pm25_intake, pm25_datasource,pm25_monitor,APP_version,  upload, connection) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        BOOL success = [db executeUpdate:sql, (data.user_id),(data.database_access_token), @([data.time_point timeIntervalSince1970]), @(data.longitude), @(data.latitude), @(data.outdoor), @(data.status), @(data.steps), @(data.heart_rate), @(data.ventilation_rate), @(data.ventilation_vol), @(data.pm25_concen), @(data.pm25_intake), @(data.pm25_datasource), (data.pm25_monitor), (data.APP_version), @(NO), @(data.connection)];
        if (!success) {
//            NSLog(@"插入失败");
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

- (void)insertDevice:(DeviceWifi *)deviceWifi complete:(void (^)(BOOL))complete {
    if (deviceWifi == nil) {
        complete(NO);
    }
    if (deviceWifi.deviceId == nil) {
        complete(NO);
    }
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback){
       NSString *sql = @"insert into DeviceWifi (device_id, wifi) values (?, ?)";
        BOOL success = [db executeUpdate:sql, (deviceWifi.deviceId), (deviceWifi.wifiName)];
        if(!success){
//            NSLog(@"插入失败");
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

- (void)deleteDevice:(NSString* )deviceId {
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = [NSString stringWithFormat:@"Delete From DeviceWifi where device_id = ?"];
        BOOL success = [db executeUpdate:sql, (deviceId)];
        if (!success) {
            *rollback = YES;
        }else{
//            NSLog(@"删除成功");
        }
    }];
}

- (NSArray *)queryForAllDevice{
    NSMutableArray *result = [NSMutableArray array];
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM DeviceWifi"];
        FMResultSet *queryResult = [db executeQuery:sql];
        while ([queryResult next]) {
            DeviceWifi *device = [[DeviceWifi alloc]initWithDevice:[queryResult stringForColumn:@"device_id"] initWithWifi:[queryResult stringForColumn:@"wifi"]];
            [result addObject:device];
        }
    }];
    return result;
}

- (NSString *)queryForDeviceId:(NSString *)wifiName{
    NSString *result = NULL;
    NSString *sql = [NSString stringWithFormat:@"SELECT device_id FROM DeviceWifi WHERE wifi = ?"];
    FMDatabase *db = [FMDatabase databaseWithPath:_databasePath];
    [db open];
    FMResultSet *queryResult = [db executeQuery:sql, (wifiName)];
    while ([queryResult next]){
        result = [queryResult stringForColumn:@"device_id"];
    }
    [db close];
    return result;
}


- (void)getTodayData:(NSDate *)date complete:(void (^)(NSArray * _Nonnull, NSArray * _Nonnull))complete {
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSInteger timerCount = [date timeIntervalSinceDate:[date dateToday]];
        NSMutableArray *pmResult = [NSMutableArray array];
        NSMutableArray *breathResult = [NSMutableArray array];
        for (int i = 0; i < timerCount / kToDayInterval; i++) {
            NSDate *startDate = [NSDate dateWithTimeInterval:i * kToDayInterval sinceDate:[date dateToday]];
            NSDate *endDate = [NSDate dateWithTimeInterval:(i + 1) * kToDayInterval sinceDate:[date dateToday]];
            NSString *sql = [NSString stringWithFormat:@"SELECT pm25_concen, ventilation_rate FROM PMData where %f < time_point and time_point <= %f", [startDate timeIntervalSince1970], [endDate timeIntervalSince1970]];
            FMResultSet *queryResult = [db executeQuery:sql];
            float sum = 0;
            float breathSum = 0;
            NSInteger count = 0;
            while ([queryResult next]) {
                float timePointPM = [queryResult doubleForColumn:@"pm25_concen"];
                float breathSumPoint = [queryResult doubleForColumn:@"ventilation_rate"];
                count = count + 1;
                sum = sum + timePointPM;
                breathSum = breathSum + breathSumPoint;
            }
            if (count != 0) {
                sum = sum / count;
                breathSum = breathSum / count;
            }
//            DDLogDebug(@"Query Today PMStart: %@ End: %@, pm25_concen: %f", [startDate whi_dateWithFormat:@"HH:mm:ss"], [endDate whi_dateWithFormat:@"HH:mm:ss"], sum);
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
            NSString *sql = [NSString stringWithFormat:@"SELECT pm25_concen, ventilation_rate FROM PMData where %f < time_point and time_point <= %f", [startDate timeIntervalSince1970], [endDate timeIntervalSince1970]];
            FMResultSet *queryResult = [db executeQuery:sql];
            float sum = 0;
            float breathSum = 0;
            NSInteger count = 0;
            while ([queryResult next]) {
                float timePointPM = [queryResult doubleForColumn:@"pm25_concen"];
                float breathSumPoint = [queryResult doubleForColumn:@"ventilation_rate"];
                sum = sum + timePointPM;
                breathSum = breathSum + breathSumPoint;
                count = count + 1;
            }
            if (count != 0) {
                sum = sum / count;
                breathSum = breathSum / count;
            }
//            DDLogDebug(@"Query Today PMStart: %@ End: %@, pm25_concen: %f", [startDate whi_dateWithFormat:@"HH:mm:ss"], [endDate whi_dateWithFormat:@"HH:mm:ss"], sum);
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
            NSString *sql = [NSString stringWithFormat:@"SELECT pm25_concen, ventilation_rate FROM PMData where %f < time_point and time_point <= %f", [startDate timeIntervalSince1970], [endDate timeIntervalSince1970]];
            FMResultSet *queryResult = [db executeQuery:sql];
            float sum = 0;
            float breathSum = 0;
            NSInteger count = 0;
            while ([queryResult next]) {
                float timePointPM = [queryResult doubleForColumn:@"pm25_concen"];
                float breathSumPoint = [queryResult doubleForColumn:@"ventilation_rate"];
                count = count + 1;
                sum = sum + timePointPM;
                breathSum = breathSum + breathSumPoint;
            }
            if (count != 0) {
                sum = sum / count;
                breathSum = breathSum / count;
            }
//            DDLogDebug(@"Query Today PMStart: %@ End: %@, pm25_concen: %f", [startDate whi_dateWithFormat:@"HH:mm:ss"], [endDate whi_dateWithFormat:@"HH:mm:ss"], sum);
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
        NSString *sql = [NSString stringWithFormat:@"Delete From PMData where time_point < %f", [weekDate timeIntervalSince1970]];
        BOOL success = [db executeUpdate:sql];
        if (!success) {
            *rollback = YES;
        }
    }];
}


- (void)searchLastWeekData:(NSDate *)nowDate complete:(void (^)(NSArray * _Nonnull))complete {
    NSDate *date = nowDate ?: [NSDate date];
    NSDate *weekDate = [date dateByAddingWeek:-1];
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSMutableArray *result = [NSMutableArray array];
        NSString *sql = [NSString stringWithFormat:@"SELECT time_point, ventilation_vol, outdoor From PMData where time_point > %f", [weekDate timeIntervalSince1970]];
        FMResultSet *queryResult = [db executeQuery:sql, @(NO)];        while ([queryResult next]) {
            WHIData *data = [[WHIData alloc] init];
            double timePoint = [queryResult doubleForColumn:@"time_point"];
            data.time_point = [NSDate dateWithTimeIntervalSince1970:timePoint];
            data.ventilation_vol = [queryResult doubleForColumn:@"ventilation_vol"];
            data.outdoor = [queryResult boolForColumn:@"outdoor"];
            [result addObject:data];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(result);
        });
    }];
}

- (void)queryForUnUploadData:(int)limit complete:(void (^)(NSArray * _Nonnull))complete {
    if (limit == 0) {
        limit = 10;
    }
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSMutableArray *result = [NSMutableArray array];
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM PMData where upload = ? or upload is null ORDER BY time_point DESC LIMIT %d", limit];
        FMResultSet *queryResult = [db executeQuery:sql, @(NO)];
//        NSLog(@"query for unupload");
        while ([queryResult next]) {
            WHIData *data = [[WHIData alloc] init];
            double timePoint = [queryResult doubleForColumn:@"time_point"];
            data.time_point = [NSDate dateWithTimeIntervalSince1970:timePoint];
            
            data.user_id = [queryResult stringForColumn:@"user_id"];

            

//            NSString *token = [queryResult stringForColumn:@"database_access_token"]?:@"";
//            NSLog(@"access_token is  %@",token);
//            NSLog(@"app version is  %@",[queryResult stringForColumn:@"APP_version"]);
            
            data.database_access_token = [queryResult stringForColumn:@"database_access_token"] ?:@"";
            data.APP_version = [queryResult stringForColumn:@"APP_version"];
            
            
            data.pm25_monitor = [queryResult stringForColumn:@"pm25_monitor"];
            
            data.ventilation_vol = [queryResult doubleForColumn:@"ventilation_vol"];
            data.pm25_intake = [queryResult doubleForColumn:@"pm25_intake"];
            data.connection = [queryResult boolForColumn:@"connection"];
            data.pm25_concen =  [queryResult doubleForColumn:@"pm25_concen"];
            data.ventilation_rate = [queryResult doubleForColumn:@"ventilation_rate"];
            data.outdoor = [queryResult boolForColumn:@"outdoor"];
            data.steps = [queryResult intForColumn:@"steps"];
            data.heart_rate = [queryResult doubleForColumn:@"heart_rate"];
            data.pm25_datasource = [queryResult intForColumn:@"pm25_datasource"];
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
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM PMData where (upload = ? or upload is null) and time_point < '%@' ORDER BY time_point DESC LIMIT %d", date, limit];
        FMResultSet *queryResult = [db executeQuery:sql, @(NO)];
        while ([queryResult next]) {
            WHIData *data = [[WHIData alloc] init];
            double timePoint = [queryResult doubleForColumn:@"time_point"];
            data.time_point = [NSDate dateWithTimeIntervalSince1970:timePoint];
            
            data.user_id = [queryResult stringForColumn:@"user_id"];
            data.database_access_token = [queryResult stringForColumn:@"database_access_token"] ?:@"";
            data.ventilation_vol = [queryResult doubleForColumn:@"ventilation_vol"];
            data.pm25_intake = [queryResult doubleForColumn:@"pm25_intake"];
            data.pm25_monitor = [queryResult stringForColumn:@"pm25_monitor"];
            data.APP_version = [queryResult stringForColumn:@"APP_version"];
            data.connection = [queryResult boolForColumn:@"connection"];
            
            data.pm25_concen =  [queryResult doubleForColumn:@"pm25_concen"];
            data.ventilation_rate = [queryResult doubleForColumn:@"ventilation_rate"];
            data.outdoor = [queryResult boolForColumn:@"outdoor"];
            data.steps = [queryResult intForColumn:@"steps"];
            data.heart_rate = [queryResult doubleForColumn:@"heart_rate"];
            data.pm25_datasource = [queryResult intForColumn:@"pm25_datasource"];
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
