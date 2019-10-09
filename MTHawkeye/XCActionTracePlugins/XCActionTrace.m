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


#import "XCActionTrace.h"
#import "XCActionTraceModel.h"

@interface XCActionTrace ()

@property (nonatomic, strong) NSHashTable<id<XCActionTracingDelegate>> *delegates;

@end

@implementation XCActionTrace

+ (instancetype)sharedInstance {
    static XCActionTrace *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[XCActionTrace alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
#warning 使用weakObjectHashTable有什么好处？
        self.delegates = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)addDelegate:(id<XCActionTracingDelegate>)delegate {
    @synchronized (self.delegates) {
        [self.delegates addObject:delegate];
    }
}

- (void)removeDelegate:(id<XCActionTracingDelegate>)delegate {
    @synchronized (self.delegates) {
        [self.delegates removeObject:delegate];
    }
}

- (void)recordActionWithActionModel:(XCActionTraceModel *)model {
    @synchronized (self.delegates) {
        for (id<XCActionTracingDelegate> delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(recorderWantCacheActionTrace:)]) {
                [delegate recorderWantCacheActionTrace:model];
            }
        }
    }
}

- (void)addActionWithTitle:(NSString *)actionTitle params:(NSDictionary *)params {
    XCActionTraceModel *model = [[XCActionTraceModel alloc] init];
    model.actionTitle = actionTitle;
    model.actionParams = params;
    [self recordActionWithActionModel:model];
}

@end
