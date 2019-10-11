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


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSTimeInterval kXCMonitorLogExpiredTime;

@class XCMonitorLogModel;

@interface XCMonitorDatabase : NSObject

+ (instancetype)shared;

///-----------------------------
/// @name 处理回调的队列
///-----------------------------

@property (nonatomic, strong, nullable) dispatch_queue_t completionQueue;

@property (nonatomic, strong, nullable) dispatch_group_t completionGroup;

///-----------------------------
/// @name 日志文件数据库增删查
///-----------------------------

- (void)insertMonitorLogs:(NSArray *)logArray
         completionHandler:(nullable void(^)(NSError * _Nullable error))completionHandler;

- (void)deleteMonitorLog:(XCMonitorLogModel *)log
        completionHandler:(nullable void(^)(BOOL result))completionHandler;

- (void)loadMonitorLogPageCount:(NSInteger)pageCount
                          index:(NSInteger)index
              completionHandler:(nullable void(^)(NSArray<XCMonitorLogModel *> *logArray, NSError * _Nullable error))completionHandler;
@end

///-----------------------------
/// @name Constants
///-----------------------------


NS_ASSUME_NONNULL_END
