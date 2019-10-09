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
@protocol XCActionTracingDelegate;

@interface XCActionTrace : NSObject

+ (instancetype)sharedInstance;

- (void)addDelegate:(id<XCActionTracingDelegate>)delegate;
- (void)removeDelegate:(id<XCActionTracingDelegate>)delegate;


/**
 添加事件

 @param actionTitle 事件名
 @param params 事件相关参数
 */
- (void)addActionWithTitle:(NSString *)actionTitle
                    params:(nullable NSDictionary *)params;


@end

@protocol XCActionTracingDelegate <NSObject>

- (void)recorderWantCacheActionTrace:(XCActionTraceModel *)actionModel;

@end

NS_ASSUME_NONNULL_END
