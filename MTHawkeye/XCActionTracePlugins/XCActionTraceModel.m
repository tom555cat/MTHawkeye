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


#import "XCActionTraceModel.h"
#import "XCMonitorLogModel.h"

@implementation XCActionTraceModel

//- (void)storeActionModel:(XCActionTraceModel *)actionModel {
//
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    dict[@"actionTitle"] = actionModel.actionTitle;
//    dict[@"actionParams"] = actionModel.actionParams;
//
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict.copy options:0 error:&error];
//    if (!jsonData) {
//        NSLog(@"persist action trace failed: %@", error.localizedDescription);
//    }
//    NSString *value = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//
//
//    XCMonitorLogModel *logModel = [[XCMonitorLogModel alloc] init];
//    logModel.logTitle = actionModel.actionTitle;
//    logModel.logType = XCMonitorLogTypeAction;
//    logModel.logContent = value;
//    logModel.logTime = [[NSDate date] timeIntervalSince1970];
//
//    [[XCMonitorDatabase shared] insertMonitorLogs:@[logModel] completionHandler:nil];
//}

- (NSDictionary *)dictionaryFromAllProperty {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"actionTitle"] = self.actionTitle ?: @"";
    dict[@"actionParams"] = self.actionParams ?: @{};
    return [dict copy];
}

+ (XCActionTraceModel *)actionTraceFromPropertyDictionary:(NSDictionary *)dict {
    if (!dict || !dict.count) {
        return nil;
    }
    
    XCActionTraceModel *actionTraceModel = [[XCActionTraceModel alloc] init];
    
    NSString *actionTitle = dict[@"actionTitle"];
    actionTraceModel.actionTitle = actionTitle;
    
    NSDictionary *actionParams = dict[@"actionParams"];
    actionTraceModel.actionParams = actionParams;
    
    return actionTraceModel;
}

+ (XCActionTraceModel *)actionTraceFromXCLogModel:(XCMonitorLogModel *)logModel {
    if (!logModel) {
        return nil;
    }
    
    NSData *data = [logModel.logContent dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return nil;
    }
    NSDictionary *actionTraceDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (!actionTraceDict || !actionTraceDict.count) {
        return nil;
    }
    XCActionTraceModel *actionTraceModel = [XCActionTraceModel actionTraceFromPropertyDictionary:actionTraceDict];
    
    return actionTraceModel;
}

@end
