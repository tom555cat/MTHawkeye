//
// Copyright (c) 2008-present, Meitu, Inc.
// All rights reserved.
//
// This source code is licensed under the license found in the LICENSE file in
// the root directory of this source tree.
//
// Created on: 2019/9/30
// Created by: tongleiming
//


#import "XCActionTraceDemoViewController.h"
#import "XCActionTrace.h"

@interface XCActionTraceDemoViewController ()

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) NSMutableString *log;

@end

@implementation XCActionTraceDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.textView = [[UITextView alloc] init];
    self.textView.editable = NO;
    self.view = self.textView;
    
    self.log = [NSMutableString string];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addActionTrace)];
}

- (void)addActionTrace {
    static NSInteger index = 0;
    NSString *title = [NSString stringWithFormat:@"actionTitle%ld", (long)index++];
    NSDictionary *params = @{@"params1":@"hello", @"params2":@"world"};
    [[XCActionTrace sharedInstance] addActionWithTitle:title params:params];
    
    [self.log appendFormat:@">> %@ \n", title];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.textView.text = self.log;
    });
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
