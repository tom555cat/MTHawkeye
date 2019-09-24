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
#define SQL_CREATE_MONITORLOG      [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (logID integer, logContent text, logType integer, primary key (logID))", TABLE_MONITOR_LOG]

//#define SQL_CREATE_MONITORLOG_INDEX [NSString stringWithFormat:@"CREATE INDEX logIDIndex on %@(logID)", SQL_CREATE_MONITORLOG]

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
        NSLog(@"打开数据库失败!");
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
    return logDirectory;
}

#pragma mark 日志增查

- (void)insertMonitorLogs:(NSArray *)logArray
                  success:(void(^)(void))success
                  failure:(void(^)(NSString *errorDesc))failure {
    __weak typeof(self) weakSelf = self;
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        __strong typeof(weakSelf) self = weakSelf;
        
        [self.database beginTransaction];
        __block BOOL isRollBack = NO;
        @try {
            [logArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                XCMonitorLogModel *logModel = (XCMonitorLogModel *)obj;
                NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ VALUES(?,?,?)", TABLE_MONITOR_LOG];
                
                BOOL result = [self.database executeUpdate:sql, @(logModel.logID), logModel.logContent, @(logModel.logType)];
                
                if (!result) {
                    isRollBack = YES;
                    *stop = YES;
                }
            }];
        } @catch (NSException *exception) {
            [self.database rollback];
            if (failure) {
                failure(@"插入数据失败");
            }
        } @finally {
            if (isRollBack) {
                [self.database rollback];
                NSLog(@"insert to database failure content");
                failure(@"插入数据失败");
            } else {
                [self.database commit];
                success();
            }
        }
        
    }];
    
#warning catch和finally，当catch调用时，finally是否还会调用
}


@end
