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


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MTHNetworkTransaction;
@class XCMonitorLogModel;

@interface XCNetworkMonitorRecordsDBStorage : NSObject

+ (instancetype)shared;

- (void)storeNetworkTransaction:(MTHNetworkTransaction *)transaction;

- (void)readNetworkTransactionsWithCount:(NSInteger)count sinceLogID:(NSUInteger)logID withCompletion:(void(^)(NSArray<XCMonitorLogModel *> *))completion;

@end

NS_ASSUME_NONNULL_END
