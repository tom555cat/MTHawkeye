//
// Copyright (c) 2008-present, Meitu, Inc.
// All rights reserved.
//
// This source code is licensed under the license found in the LICENSE file in
// the root directory of this source tree.
//
// Created on: 2019/10/11
// Created by: tongleiming
//


#import "XCActionTraceDetailViewController.h"
#import "XCActionTraceModel.h"

@interface XCActionTraceDetailViewController ()

@property (nonatomic, strong) UITextView *textView;

@end

@implementation XCActionTraceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.textView = [[UITextView alloc] init];
    self.textView.editable = NO;
    self.view = self.textView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSString *desc = [NSString stringWithFormat:@"%@", self.actionTraceModel.actionParams];
    
    self.textView.text = desc;
    self.title = self.actionTraceModel.actionTitle;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
