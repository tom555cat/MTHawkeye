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


#import "XCActionTraceDatabaseAdaptor.h"
#import "XCActionTrace.h"
#import "XCActionRecordsDBStorage.h"

@interface XCActionTraceDatabaseAdaptor () <XCActionTracingDelegate>

@end

@implementation XCActionTraceDatabaseAdaptor

// MARK: - MTHawkeyePlugin
+ (NSString *)pluginID {
    return @"xcmonitor-action";
}

- (void)hawkeyeClientDidStart {
    [[XCActionTrace sharedInstance] addDelegate:self];
}

- (void)hawkeyeClientDidStop {
    [[XCActionTrace sharedInstance] removeDelegate:self];
}

// MARK: - Storage
- (void)recorderWantCacheActionTrace:(XCActionTraceModel *)actionModel {
    [[XCActionRecordsDBStorage shared] storeActionModel:actionModel];
}

@end
