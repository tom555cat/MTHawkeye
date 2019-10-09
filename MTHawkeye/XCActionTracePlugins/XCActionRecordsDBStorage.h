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

@class XCActionTraceModel;

@interface XCActionRecordsDBStorage : NSObject

+ (instancetype)shared;

- (void)storeActionModel:(XCActionTraceModel *)actionModel;

@end

NS_ASSUME_NONNULL_END
