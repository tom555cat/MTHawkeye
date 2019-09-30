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


#import "XCNetworkAndEventTraceUI.h"
#import "XCMonitorViewController.h"

#import <MTHawkeye/MTHawkeyeSettingTableEntity.h>

@implementation XCNetworkAndEventTraceUI

// MARK: - MTHawkeyeMainPanelPlugin
- (NSString *)groupNameSwitchingOptionUnder {
    return kXCUINetworkAndEvent;
}

- (NSString *)switchingOptionTitle {
    return @"Network & Event";
}

- (NSString *)mainPanelIdentity {
    return @"network-event";
}

- (UIViewController *)mainPanelViewController {
    XCMonitorViewController *vc = [XCMonitorViewController new];
    return vc;
}

//// MARK: - MTHawkeyeSettingUIPlugin
//
//+ (NSString *)sectionNameSettingsUnder {
//    return kXCUINetworkAndEvent;
//}
//
//+ (MTHawkeyeSettingCellEntity *)settings {
//    MTHawkeyeSettingFoldedCellEntity *cell = [[MTHawkeyeSettingFoldedCellEntity alloc] init];
//    cell.title = @"Network & Event";
//    cell.foldedTitle = cell.title;
//    cell.foldedSections = @[
//                            [self networkMonitorSection],
//                            [self networkCurrentSessionSession],
//                            [self networkCleanRecordSection],
//                            [self networkInspecSection],
//                            ];
//    return cell;
//}
//
//// Network Monitor
//+ (MTHawkeyeSettingSectionEntity *)networkMonitorSection {
//    MTHawkeyeSettingSectionEntity *section = [[MTHawkeyeSettingSectionEntity alloc] init];
//    section.tag = @"Network & Event";
//    section.headerText = @"Network Transaction And Event Monitor";
//    section.cells = @[
//                      [self networkMonitorSwitcherCell],
//                      ];
//    return section;
//}
//
//+ (MTHawkeyeSettingSectionEntity *)networkCurrentSessionSession {
//    MTHawkeyeSettingSectionEntity *section = [[MTHawkeyeSettingSectionEntity alloc] init];
//    section.tag = @"network-monitor-current";
//    section.headerText = @"Current Session";
//    section.cells = @[
//                      [self networkCacheTransactionBodySwitcherCell],
//                      [self networkCacheResponseBodySwitcherCell],
//                      [self networkCacheLimitInMBEditCell]
//                      ];
//    return section;
//}
//
//+ (MTHawkeyeSettingSwitcherCellEntity *)networkMonitorSwitcherCell {
//    MTHawkeyeSettingSwitcherCellEntity *entity = [[MTHawkeyeSettingSwitcherCellEntity alloc] init];
////    entity.title = @"Network Monitor";
////    entity.setupValueHandler = ^BOOL {
////        return [MTHawkeyeUserDefaults shared].networkMonitorOn;
////    };
////    entity.valueChangedHandler = ^BOOL(BOOL newValue) {
////        if (newValue != [MTHawkeyeUserDefaults shared].networkMonitorOn) {
////            [MTHawkeyeUserDefaults shared].networkMonitorOn = newValue;
////        }
////        return YES;
////    };
//    return entity;
//}
//
//+ (MTHawkeyeSettingSwitcherCellEntity *)networkCacheTransactionBodySwitcherCell {
//    MTHawkeyeSettingSwitcherCellEntity *entity = [[MTHawkeyeSettingSwitcherCellEntity alloc] init];
////    entity.title = @"Record HTTP Transaction Body";
////    entity.setupValueHandler = ^BOOL {
////        return [MTHawkeyeUserDefaults shared].networkTransactionBodyCacheOn;
////    };
////    entity.valueChangedHandler = ^BOOL(BOOL newValue) {
////        if (newValue != [MTHawkeyeUserDefaults shared].networkTransactionBodyCacheOn) {
////            [MTHawkeyeUserDefaults shared].networkTransactionBodyCacheOn = newValue;
////        }
////        return YES;
////    };
//    return entity;
//}
//
//+ (MTHawkeyeSettingSwitcherCellEntity *)networkCacheResponseBodySwitcherCell {
//    MTHawkeyeSettingSwitcherCellEntity *entity = [[MTHawkeyeSettingSwitcherCellEntity alloc] init];
////    entity.title = @"Record Response Body";
////    entity.setupValueHandler = ^BOOL {
////        return [MTHawkeyeUserDefaults shared].responseBodyCacheOn;
////    };
////    entity.valueChangedHandler = ^BOOL(BOOL newValue) {
////        if (newValue != [MTHawkeyeUserDefaults shared].responseBodyCacheOn) {
////            [MTHawkeyeUserDefaults shared].responseBodyCacheOn = newValue;
////        }
////        return YES;
////    };
//    return entity;
//}
//
//+ (MTHawkeyeSettingEditorCellEntity *)networkCacheLimitInMBEditCell {
//    MTHawkeyeSettingEditorCellEntity *editor = [[MTHawkeyeSettingEditorCellEntity alloc] init];
////    editor.title = @"Record Cache Size Limit";
////    editor.inputTips = @"";
////    editor.editorKeyboardType = UIKeyboardTypeNumberPad;
////    editor.valueUnits = @"MB";
////    editor.setupValueHandler = ^NSString *_Nonnull {
////        float responseLimit = [MTHawkeyeUserDefaults shared].networkCacheLimitInMB;
////        NSString *str = [NSString stringWithFormat:@"%0.2f", responseLimit];
////        return str;
////    };
////    editor.valueChangedHandler = ^BOOL(NSString *_Nonnull newValue) {
////        float value = newValue.floatValue;
////        if (fabsf(value - [MTHawkeyeUserDefaults shared].networkCacheLimitInMB) > FLT_EPSILON)
////            [MTHawkeyeUserDefaults shared].networkCacheLimitInMB = value;
////        return YES;
////    };
//    return editor;
//}
//
//
//+ (MTHawkeyeSettingSectionEntity *)networkCleanRecordSection {
//    MTHawkeyeSettingSectionEntity *section = [[MTHawkeyeSettingSectionEntity alloc] init];
//    section.tag = @"network-monitor";
//    section.headerText = @"Clean Record Cache";
//    section.cells = @[
//                      [self networkCurrentSessionRecordsCleanActionCell],
//                      [self networkHistorySessionRecordsCleanActionCell]
//                      ];
//    return section;
//}
//
//+ (MTHawkeyeSettingActionCellEntity *)networkCurrentSessionRecordsCleanActionCell {
//    MTHawkeyeSettingActionCellEntity *entity = [[MTHawkeyeSettingActionCellEntity alloc] init];
////    __weak typeof(entity) weak_entity = entity;
////    entity.title = [NSString stringWithFormat:@"Current Session Records(%0.2fMB)", [MTHNetworkRecordsStorage getCurrentSessionRecordsFileSize] / 1024.0 / 1024.0];
////    entity.didTappedHandler = ^{
////        [MTHNetworkRecordsStorage removeAllCurrentSessionRecords];
////        weak_entity.title = [NSString stringWithFormat:@"Current Session Records(%0.2fMB)", [MTHNetworkRecordsStorage getCurrentSessionRecordsFileSize] / 1024.0 / 1024.0];
////        if (weak_entity.delegate) {
////            [weak_entity.delegate hawkeyeSettingEntityValueDidChanged:weak_entity];
////        }
////    };
//    return entity;
//}
//
//+ (MTHawkeyeSettingActionCellEntity *)networkHistorySessionRecordsCleanActionCell {
//    MTHawkeyeSettingActionCellEntity *entity = [[MTHawkeyeSettingActionCellEntity alloc] init];
////    __weak typeof(entity) weak_entity = entity;
////    entity.title = [NSString stringWithFormat:@"History Session Records(%0.2fMB)", [MTHNetworkRecordsStorage getHistorySessionRecordsFileSize] / 1024.0 / 1024.0];
////    entity.didTappedHandler = ^{
////        [MTHNetworkRecordsStorage removeAllHistorySessionRecords];
////        weak_entity.title = [NSString stringWithFormat:@"History Session Records(%0.2fMB)", [MTHNetworkRecordsStorage getHistorySessionRecordsFileSize] / 1024.0 / 1024.0];
////        if (weak_entity.delegate) {
////            [weak_entity.delegate hawkeyeSettingEntityValueDidChanged:weak_entity];
////        }
////    };
//    return entity;
//}
//
//// Network Inspect
//+ (MTHawkeyeSettingSectionEntity *)networkInspecSection {
//    MTHawkeyeSettingSectionEntity *section = [[MTHawkeyeSettingSectionEntity alloc] init];
//    section.tag = @"network-inspect";
//    section.headerText = @"Network Transaction Inspect";
//    section.cells = @[
//                      [self networkInspectSwitcherCell],
//                      ];
//    return section;
//}
//
//+ (MTHawkeyeSettingSwitcherCellEntity *)networkInspectSwitcherCell {
//    MTHawkeyeSettingSwitcherCellEntity *entity = [[MTHawkeyeSettingSwitcherCellEntity alloc] init];
////    entity.title = @"Network Inspect";
////    entity.setupValueHandler = ^BOOL {
////        return [MTHawkeyeUserDefaults shared].networkInspectOn;
////    };
////    entity.valueChangedHandler = ^BOOL(BOOL newValue) {
////        if (newValue != [MTHawkeyeUserDefaults shared].networkInspectOn) {
////            [MTHawkeyeUserDefaults shared].networkInspectOn = newValue;
////        }
////        return YES;
////    };
//    return entity;
//}

@end
