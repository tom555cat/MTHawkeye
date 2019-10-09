//
// Copyright (c) 2008-present, Meitu, Inc.
// All rights reserved.
//
// This source code is licensed under the license found in the LICENSE file in
// the root directory of this source tree.
//
// Created on: 2019/9/29
// Created by: tongleiming
//


#import "XCActionRecordsDBStorage.h"
#import "XCActionTraceModel.h"
#import "XCMonitorLogModel.h"
#import "XCMonitorDatabase.h"

@implementation XCActionRecordsDBStorage

+ (instancetype)shared {
    static XCActionRecordsDBStorage *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (void)storeActionModel:(XCActionTraceModel *)actionModel {    
    NSDictionary *dict = [actionModel dictionaryFromAllProperty];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict.copy options:0 error:&error];
    if (!jsonData) {
        NSLog(@"persist action trace failed: %@", error.localizedDescription);
    }
    NSString *value = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    XCMonitorLogModel *logModel = [[XCMonitorLogModel alloc] init];
    logModel.logTitle = actionModel.actionTitle;
    logModel.logType = XCMonitorLogTypeAction;
    logModel.logContent = value;
    logModel.logTime = [[NSDate date] timeIntervalSince1970];
    
    [[XCMonitorDatabase shared] insertMonitorLogs:@[logModel] completionHandler:nil];
}

- (void)readActionModelWithCount:(NSInteger)count
                      sinceLogID:(NSUInteger)logID
                  withCompletion:(void(^)(NSArray<XCMonitorLogModel *>*))completion {
    
    __weak typeof(self) weakSelf = self;
    [[XCMonitorDatabase shared] loadMonitorLogPageCount:count index:logID completionHandler:^(NSArray<XCMonitorLogModel *> * _Nonnull logArray, NSError * _Nullable error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        
        if (completion) {
            completion([logArray copy]);
        }
    }];
    
}

@end
