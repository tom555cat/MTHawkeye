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


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const XCActionEventViewCellIdentifier;

@class XCActionTraceModel;
@protocol XCActionEventViewCellDelegate;

@interface XCActionEventViewCell : UITableViewCell

@property (nonatomic, strong) XCActionTraceModel *actionTraceModel;
@property (nonatomic, weak) id<XCActionEventViewCellDelegate> delegate;

@end

@protocol XCActionEventViewCellDelegate <NSObject>

- (void)xc_actionEventCellDidTappedDetail:(XCActionEventViewCell *)cell;

@end

NS_ASSUME_NONNULL_END
