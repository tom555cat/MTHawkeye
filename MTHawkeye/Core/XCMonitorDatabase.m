//
// Copyright (c) 2008-present, Meitu, Inc.
// All rights reserved.
//
// This source code is licensed under the license found in the LICENSE file in
// the root directory of this source tree.
//
// Created on: 2019/9/23
// Created by: tongleiming
//


#import "XCMonitorDatabase.h"
#import "FMDB.h"
#import "XCMonitorLogModel.h"



#define TABLE_MONITOR_LOG       @"XCMonitorLog"
#define SQL_CREATE_MONITORLOG      [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (logID integer primary key AUTOINCREMENT, logTitle text, logContent text, logType integer, logTime real)", TABLE_MONITOR_LOG]

// 如果用户没有提供completion group，则使用自定义的completion group
static dispatch_group_t monitor_database_completion_group() {
    static dispatch_group_t xc_monitor_database_completion_group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        xc_monitor_database_completion_group = dispatch_group_create();
    });
    
    return xc_monitor_database_completion_group;
}

@interface XCMonitorDatabase ()

@property (nonatomic, strong) FMDatabase *database;
@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;


@end

@implementation XCMonitorDatabase

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static XCMonitorDatabase *database;
    dispatch_once(&onceToken, ^{
        database = [[XCMonitorDatabase alloc] init];
    });
    return database;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 初始化数据库
        [self openCurrentDB];
    }
    return self;
}

- (void)openCurrentDB {
    if (self.database) {
        [self.database close];
        self.database = nil;
    }
    self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeDBFilePath]];
    self.database = [FMDatabase databaseWithPath:[self makeDBFilePath]];
    if (![self.database open]) {
        NSLog(@"打开数据库失败❌!");
    } else {
        // 清理数据库预留(某种情况下可能需要)
        
        // 创建表
        __weak typeof(self) weakSelf = self;
        [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            __strong typeof(weakSelf) self = weakSelf;
            if (![self.database tableExists:TABLE_MONITOR_LOG]) {
                [self createTable:SQL_CREATE_MONITORLOG];
            }
        }];
    }
    
}

- (BOOL)createTable:(NSString *)sql {
    BOOL result = NO;
    [self.database setShouldCacheStatements:YES];
    NSString *tempSql = [NSString stringWithFormat:@"%@",sql];
    result = [self.database executeUpdate:tempSql];
    
    return result;
}

- (NSString *)makeDBFilePath {
    static NSString *logDirectory;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        logDirectory = [paths[0] stringByAppendingPathComponent:@"XCMonitorLog"];
    });
    if (![[NSFileManager defaultManager] fileExistsAtPath:logDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:logDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    NSString *dbPath = [logDirectory stringByAppendingPathComponent:@"fmdb_file"];
    return dbPath;
}

#pragma mark 日志增查

- (void)insertMonitorLogs:(NSArray *)logArray
         completionHandler:(nullable void(^)(NSError * _Nullable error))completionHandler {
    __weak typeof(self) weakSelf = self;
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        __strong typeof(weakSelf) self = weakSelf;
        
        [self.database beginTransaction];
        __block BOOL isRollBack = NO;
        @try {
            [logArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                XCMonitorLogModel *logModel = (XCMonitorLogModel *)obj;
                //(logID integer, logTitle text, logTime real, logContent text, logType integer
                NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (logTitle, logContent, logType, logTime) VALUES (?,?,?,?)", TABLE_MONITOR_LOG];
#warning 测试字符串为nil是否会闪退
                BOOL result = [self.database executeUpdate:sql, logModel.logTitle, logModel.logContent, @(logModel.logType), @(logModel.logTime)];
                
                if (!result) {
                    isRollBack = YES;
                    *stop = YES;
                }
            }];
        } @catch (NSException *exception) {
            [self.database rollback];
            if (completionHandler) {
#warning 发生异常进行失败回调，测试
                dispatch_group_async(self.completionGroup ?: monitor_database_completion_group(), self.completionQueue ?: dispatch_get_main_queue(), ^{
                    NSError *error = [NSError errorWithDomain:@"插入日志表异常" code:0 userInfo:nil];
                    completionHandler(error);
                });
                
            }
        } @finally {
            if (isRollBack) {
                [self.database rollback];
                NSLog(@"insert to database failure content");
#warning 发生回滚进行失败回调，测试
                if (completionHandler) {
                    dispatch_group_async(self.completionGroup ?: monitor_database_completion_group(), self.completionQueue ?: dispatch_get_main_queue(), ^{
                        NSError *error = [NSError errorWithDomain:@"插入日志表发生回滚" code:0 userInfo:nil];
                        completionHandler(error);
                    });
                }
            } else {
                [self.database commit];
                if (completionHandler) {
                    dispatch_group_async(self.completionGroup ?: monitor_database_completion_group(), self.completionQueue ?: dispatch_get_main_queue(), ^{
                        completionHandler(nil);
                    });
                }
            }
        }
        
    }];
}

- (void)deleteMonitorLog:(XCMonitorLogModel *)log completionHandler:(void (^)(BOOL))completionHandler {
    __weak typeof(self) weakSelf = self;
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        __strong typeof(weakSelf) self = weakSelf;
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE logID = ?", TABLE_MONITOR_LOG];
        BOOL result = [self.database executeUpdate:sql, @(log.logID)];
        if (completionHandler) {
            dispatch_group_async(self.completionGroup ?: monitor_database_completion_group(), self.completionQueue ?: dispatch_get_main_queue(), ^{
                completionHandler(result);
            });
        }
    }];
}

- (void)loadMonitorLogPageCount:(NSInteger)pageCount
                          index:(NSInteger)index
              completionHandler:(void (^)(NSArray<XCMonitorLogModel *> * _Nonnull, NSError * _Nullable))completionHandler {
    __weak typeof(self) weakSelf = self;
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        __strong typeof(weakSelf) self = weakSelf;
        
        NSMutableArray *array = [NSMutableArray array];
        if ([self.database tableExists:TABLE_MONITOR_LOG]) {
#warning 测试
            [self.database setShouldCacheStatements:YES];
            NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY logTime DESC limit ?,?", TABLE_MONITOR_LOG];
            FMResultSet *result = [self.database executeQuery:sqlString, [NSNumber numberWithInteger:index], [NSNumber numberWithInteger:pageCount]];
            while ([result next]) {
                XCMonitorLogModel *logModel = [self logModelFromResult:result];
                [array addObject:logModel];
            }
            if (completionHandler) {
                dispatch_group_async(self.completionGroup ?: monitor_database_completion_group(), self.completionQueue ?: dispatch_get_main_queue(), ^{
                    completionHandler(array, nil);
                });
            }
        }
    }];
}

- (XCMonitorLogModel *)logModelFromResult:(FMResultSet *)resultSet {
    NSUInteger logID = [resultSet intForColumn:@"logID"];
    NSString *logTitle = [resultSet stringForColumn:@"logTitle"];
    NSTimeInterval logTime = [resultSet doubleForColumn:@"logTime"];
    NSString *logContent = [resultSet stringForColumn:@"logContent"];
    NSUInteger logType = [resultSet intForColumn:@"logType"];
    
    XCMonitorLogModel *logModel = [[XCMonitorLogModel alloc] init];
    logModel.logID = logID;
    logModel.logTitle = logTitle;
    logModel.logTime = logTime;
    logModel.logContent = logContent;
    logModel.logType = logType;
    
    return logModel;
}




@end
