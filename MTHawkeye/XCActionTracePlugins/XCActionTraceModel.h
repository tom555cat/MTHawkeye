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


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class XCMonitorLogModel;

@interface XCActionTraceModel : NSObject

@property (nonatomic, copy) NSString *actionTitle;

@property (nonatomic, copy) NSDictionary *actionParams;

// 将ActionTraceModel转化为字典
- (NSDictionary *)dictionaryFromAllProperty;
// 将字段转化为ActionTraceModel
+ (XCActionTraceModel *)actionTraceFromPropertyDictionary:(NSDictionary *)dict;
// 将LogModel转化为ActionTraceModel
+ (XCActionTraceModel *)actionTraceFromXCLogModel:(XCMonitorLogModel *)logModel;

@end

NS_ASSUME_NONNULL_END
