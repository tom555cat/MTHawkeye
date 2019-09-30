//
// Copyright (c) 2008-present, Meitu, Inc.
// All rights reserved.
//
// This source code is licensed under the license found in the LICENSE file in
// the root directory of this source tree.
//
// Created on: 2019/9/24
// Created by: tongleiming
//


#import "XCNetworkMonitorDatabaseAdaptor.h"
#import "MTHNetworkRecorder.h"
#import "MTHawkeyeUserDefaults+NetworkMonitor.h"
#import "XCNetworkMonitorRecordsDBStorage.h"

@interface XCNetworkMonitorDatabaseAdaptor () <MTHNetworkRecorderDelegate>

@end

@implementation XCNetworkMonitorDatabaseAdaptor

// MARK: - MTHawkeyePlugin
+ (NSString *)pluginID {
    return @"xcmonitor-network";
}

- (void)hawkeyeClientDidStart {
#warning 直接开启，后续修改为可以手工设置
    [[MTHNetworkRecorder defaultRecorder] addDelegate:self];
}

- (void)hawkeyeClientDidStop {
    [[MTHNetworkRecorder defaultRecorder] removeDelegate:self];
}

// MARK: - Storage
- (void)recorderWantCacheNewTransaction:(MTHNetworkTransaction *)transaction {
    // do nothing
}

- (void)recorderWantCacheTransactionAsUpdated:(MTHNetworkTransaction *)transaction currentState:(MTHNetworkTransactionState)state {
    if (state != MTHNetworkTransactionStateFailed &&
        state != MTHNetworkTransactionStateFinished)
        return;
    
    if (![MTHawkeyeUserDefaults shared].responseBodyCacheOn) {
        transaction.responseBody = nil;
    }
    
    [[XCNetworkMonitorRecordsDBStorage shared] storeNetworkTransaction:transaction];
}

@end
