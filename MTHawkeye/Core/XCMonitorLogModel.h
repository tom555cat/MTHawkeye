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

// 日志类型
typedef NS_ENUM(NSUInteger, XCMonitorLogType) {
    XCMonitorLogTypeNetwork = 0,
    XCMonitorLogTypeAction = 1,
};

@interface XCMonitorLogModel : NSObject

@property (nonatomic, assign) NSUInteger logID;
@property (nonatomic, copy) NSString *logContent;
@property (nonatomic, assign) XCMonitorLogType logType;

@end

NS_ASSUME_NONNULL_END
