//
// Copyright (c) 2008-present, Meitu, Inc.
// All rights reserved.
//
// This source code is licensed under the license found in the LICENSE file in
// the root directory of this source tree.
//
// Created on: 2019/9/27
// Created by: tongleiming
//


#import "XCNetworkMonitorRecordsDBStorage.h"
#import "MTHNetworkTransaction.h"
#import "MTHawkeyeUtility.h"
#import "XCMonitorLogModel.h"
#import "XCMonitorDatabase.h"

@implementation XCNetworkMonitorRecordsDBStorage

+ (instancetype)shared {
    static XCNetworkMonitorRecordsDBStorage *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (void)storeNetworkTransaction:(MTHNetworkTransaction *)transaction {
    NSDictionary *dict = [transaction dictionaryFromAllProperty];
    if ([dict count] == 0) {
        return;
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict.copy options:0 error:&error];
    if (!jsonData) {
#warning 添加警告信息
        //MTHLogWarn(@"persist network transactions failed: %@", error.localizedDescription);
    }
    NSString *value = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *path = transaction.request.URL.absoluteString;
    
    XCMonitorLogModel *logModel = [[XCMonitorLogModel alloc] init];
    logModel.logTitle = path;
    logModel.logType = XCMonitorLogTypeNetwork;
    logModel.logContent = value;
    logModel.logTime = [transaction.startTime timeIntervalSince1970];
    
    [[XCMonitorDatabase shared] insertMonitorLogs:@[logModel] completionHandler:nil];
}

- (void)readNetworkTransactionsWithCount:(NSInteger)count index:(NSUInteger)index withCompletion:(void(^)(NSArray<XCMonitorLogModel *> *))completion {
    
    __weak typeof(self) weakSelf = self;
    [[XCMonitorDatabase shared] loadMonitorLogPageCount:count
                                                  index:index
                                      completionHandler:^(NSArray * _Nonnull logArray, NSError * _Nullable error) {
          __strong typeof(weakSelf) self = weakSelf;
          if (!self) return;
          
          if (completion) {
              completion([logArray copy]);
          }
      }];
}

@end
