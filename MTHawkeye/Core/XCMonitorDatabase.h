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

@interface XCMonitorDatabase : NSObject

///-----------------------------
/// @name 日志文件数据库增删查
///-----------------------------

- (void)insertMonitorLogs:(NSArray *)logArray
                  success:(void(^)(void))success
                  failure:(void(^)(NSString *errorDesc))failure;

@end

///-----------------------------
/// @name Constants
///-----------------------------


NS_ASSUME_NONNULL_END
