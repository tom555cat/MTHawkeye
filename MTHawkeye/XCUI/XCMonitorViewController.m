//
// Copyright (c) 2008-present, Meitu, Inc.
// All rights reserved.
//
// This source code is licensed under the license found in the LICENSE file in
// the root directory of this source tree.
//
// Created on: 2019/9/27
// Created by: tongleiming
//


#import "XCMonitorViewController.h"
#import "MTHNetworkHawkeyeUI.h"
#import "MTHNetworkHistoryViewCell.h"
#import "MTHNetworkMonitorFilterViewController.h"
//#import "MTHNetworkMonitorViewModel.h"
#import "XCMonitorViewModel.h"
#import "MTHNetworkRecorder.h"
#import "MTHNetworkRecordsStorage.h"
#import "MTHNetworkTaskAdvice.h"
#import "MTHNetworkTaskInspectResults.h"
#import "MTHNetworkTaskInspector.h"
#import "MTHNetworkTaskInspectorContext.h"
#import "MTHNetworkToolsViewController.h"
#import "MTHNetworkTransaction.h"
#import "MTHNetworkTransactionDetailTableViewController.h"
#import "MTHNetworkTransactionsURLFilter.h"
#import "MTHNetworkWaterfallViewController.h"
#import "MTHPopoverViewController.h"
#import "MTHawkeyeSettingViewController.h"
#import "MTHawkeyeUserDefaults+NetworkMonitor.h"
#import "UITableView+MTHEmptyTips.h"
#import "XCActionEventViewCell.h"
#import "XCActionTraceModel.h"
#import "MJRefresh.h"
#import "XCActionTraceDetailViewController.h"

@interface XCMonitorViewController () <MTHNetworkHistoryViewCellDelegate,
    XCActionEventViewCellDelegate,
    MTHNetworkMonitorFilterDelegate,
    MTHNetworkRecorderDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    UISearchResultsUpdating,
    UISearchControllerDelegate,
    UISearchBarDelegate>

@property (nonatomic, strong) XCMonitorViewModel *viewModel;

@property (nonatomic, strong) MTHNetworkWaterfallViewController *waterfallViewController;

@property (nonatomic, strong) MTHNetworkMonitorFilterViewController *filterVC;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, assign) BOOL searchControllerWasActive;
@property (nonatomic, assign) BOOL searchControllerSearchFieldWasFirstResponder;

@property (nonatomic, strong) UIView *waterfallPlaceView;
@property (nonatomic, strong) UITableView *historyTableView;
@property (nonatomic, strong) UILabel *headerLabel; // historyTableView HeaderView Label

@property (nonatomic, assign) BOOL loadingData;
@property (nonatomic, assign) BOOL rowInsertInProgress;
@property (nonatomic, strong) NSMutableArray<MTHNetworkTransaction *> *incomeTransactionsNew;

@property (nonatomic, strong) MJRefreshHeader *mjHeader;
@property (nonatomic, strong) MJRefreshFooter *mjFooter;

@end

@implementation XCMonitorViewController

- (void)dealloc {
    @autoreleasepool {
        self.viewModel = nil;
        
        [[MTHNetworkTaskInspector shared] releaseNetworkTaskInspectorElement];
        [[MTHNetworkRecorder defaultRecorder] removeDelegate:self];
    }
}

- (instancetype)init {
    if ((self = [super init])) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewModel = [[XCMonitorViewModel alloc] init];
    self.incomeTransactionsNew = @[].mutableCopy;
    
    // 关闭搜索和过滤入口
//    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
//    self.searchController.hidesNavigationBarDuringPresentation = NO;
//    self.searchController.delegate = self;
//    self.searchController.searchResultsUpdater = self;
//    self.searchController.dimsBackgroundDuringPresentation = NO;
//    self.searchController.searchBar.delegate = self;
//    self.searchController.searchBar.placeholder = @"eg:\"d s f \" repeatedly failure request";
//    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
//    self.searchController.searchBar.showsSearchResultsButton = YES;
//    self.searchController.searchBar.backgroundColor = [UIColor colorWithRed:243.0 / 255 green:242.0 / 255 blue:242.0 / 255 alpha:1.0];
//    [self.view addSubview:self.searchController.searchBar];
    self.definesPresentationContext = YES;
    
    // 关闭瀑布图入口
//    CGFloat top = self.searchController.searchBar.bounds.size.height;
//    CGFloat width = [UIScreen mainScreen].bounds.size.width;
//    CGFloat headerHeight = 140;
//    CGRect headerFrame = CGRectMake(0, top, width, headerHeight);
//    self.waterfallPlaceView = [[UIView alloc] initWithFrame:headerFrame];
//    self.waterfallPlaceView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:self.waterfallPlaceView];
//
//    self.waterfallViewController = [[MTHNetworkWaterfallViewController alloc] initWithViewModel:self.viewModel];
//    [self.waterfallViewController willMoveToParentViewController:self];
//    [self addChildViewController:self.waterfallViewController];
//    self.waterfallViewController.view.frame = self.waterfallPlaceView.bounds;
//    [self.waterfallPlaceView addSubview:self.waterfallViewController.view];
//    [self.waterfallViewController didMoveToParentViewController:self];
//
//    top += headerFrame.size.height;
    
//    CGFloat listHeight = self.view.bounds.size.height - top - headerHeight;
    CGRect listFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.historyTableView = [[UITableView alloc] initWithFrame:listFrame style:UITableViewStylePlain];
    self.historyTableView.delegate = self;
    self.historyTableView.dataSource = self;
    
    [self.view addSubview:self.historyTableView];
    
    // 不作为MTHNetworkRecorder的代理
    //[[MTHNetworkRecorder defaultRecorder] addDelegate:self];
    
    [self refreshLogModels];
    
    self.historyTableView.mj_header = [MJRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshLogModels)];
    self.historyTableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreLogModels)];
}

- (void)refreshLogModels {
    __weak typeof(self) weakSelf = self;
    [self.viewModel refreshLogModelsWithCompletion:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        
        [self loadDataComplete];
        [self.historyTableView.mj_header endRefreshing];
    }];
}

- (void)loadMoreLogModels {
    if (self.viewModel.reachEnd) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.viewModel loadMoreLogModelsWithCompletion:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        
        [self loadDataComplete];
        [self.historyTableView.mj_footer endRefreshing];
    }];
}

- (void)loadDataComplete {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.historyTableView reloadData];
        self.loadingData = NO;
        
#warning 等待网络聚焦功能完善之后开始
        self.headerLabel.text = @"";
    });
}

//- (void)loadLogModels {
//    if (!self.headerLabel) {
//        self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 20, 30)];
//    }
//    self.headerLabel.text = @"Loading ...";
//    self.loadingData = YES;
//
//    __weak __typeof(self) weakSelf = self;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
//        [weakSelf.viewModel loadLogsWithCompletion:^{
//            dispatch_async(dispatch_get_main_queue(), ^(void) {
//                [weakSelf.historyTableView reloadData];
//                weakSelf.loadingData = NO;
//
//#warning 等待网络聚焦功能完善之后开始
//                self.headerLabel.text = @"";
//            });
//        }];
//
//        // 侦测网络请求中的可改进项
////        dispatch_async(dispatch_get_main_queue(), ^(void) {
////            [weakSelf focusOnFirstRowIfPossible];
////
////            [weakSelf reloadHistoryTableView];
////
////            NSArray *transactions = self.searchController.isActive ? self.viewModel.filteredNetworkTransactions : self.viewModel.logModels;
////            NSInteger totalRequest = 0;
////            NSInteger totalResponse = 0;
////            for (MTHNetworkTransaction *transaction in transactions) {
////                totalRequest += transaction.requestLength;
////                totalResponse += transaction.responseLength;
////            }
////            NSInteger total = totalRequest + totalResponse;
////
////            self.headerLabel.text = [NSString stringWithFormat:@"⇅ %@, ↑ %@, ↓ %@",
////                                     [NSByteCountFormatter stringFromByteCount:total
////                                                                    countStyle:NSByteCountFormatterCountStyleBinary],
////                                     [NSByteCountFormatter stringFromByteCount:totalRequest
////                                                                    countStyle:NSByteCountFormatterCountStyleBinary],
////                                     [NSByteCountFormatter stringFromByteCount:totalResponse
////                                                                    countStyle:NSByteCountFormatterCountStyleBinary]];
////        });
//    });
//}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.searchController.isActive) {
        [self.view setNeedsLayout];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (!self.view.window && self.searchController.isActive) {
        [self.searchController setActive:NO];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat top = [self p_navigationBarTopLayoutGuide].length;
    
    UISearchBar *searchBar = self.searchController.searchBar;
    if (self.searchController.isActive) {
        CGRect searchBarFrame = CGRectMake(0, 0, self.view.bounds.size.width, 44);
        searchBar.frame = searchBarFrame;
    } else {
        CGRect searchBarFrame = CGRectMake(0, top, self.view.bounds.size.width, 44);
        searchBar.frame = searchBarFrame;
    }
    
    top += searchBar.frame.size.height;
    
    CGRect waterfallFrame = CGRectMake(0, top, self.view.bounds.size.width, self.waterfallPlaceView.bounds.size.height);
    self.waterfallPlaceView.frame = waterfallFrame;
    [self.waterfallViewController updateContentInset];
    
    top += waterfallFrame.size.height;
#warning 暂时将所有记录放大至全屏
    CGRect listFrame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.historyTableView.frame = listFrame;
    
    CGFloat left = 10.f;
    CGFloat maxWidth = CGRectGetWidth(self.view.bounds);
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_10_3
    if (@available(iOS 11, *)) {
        left += self.view.safeAreaInsets.left;
        maxWidth -= (left + self.view.safeAreaInsets.right);
    }
#endif
    self.headerLabel.frame = CGRectMake(left, 0, maxWidth - left, 30);
}

- (id<UILayoutSupport>)p_navigationBarTopLayoutGuide {
    UIViewController *cur = self;
    while (cur.parentViewController && ![cur.parentViewController isKindOfClass:UINavigationController.class]) {
        cur = cur.parentViewController;
    }
    
    return cur.topLayoutGuide;
}

#warning 关闭MTHNetworkRecorder代理，只从数据库中读取
// MARK: - MTHNetworkRecorder


//- (void)recorderWantCacheNewTransaction:(MTHNetworkTransaction *)transaction {
//    dispatch_async(dispatch_get_main_queue(), ^(void) {
//        @synchronized(self.incomeTransactionsNew) {
//            [self.incomeTransactionsNew insertObject:transaction atIndex:0];
//        }
//
//        [self tryUpdateTransactions];
//    });
//}
//
//- (void)tryUpdateTransactions {
//    if (self.loadingData || self.rowInsertInProgress || self.searchController.isActive) {
//        return;
//    }
//
//    NSInteger addedRowCount = 0;
//    @synchronized(self.incomeTransactionsNew) {
//        if (self.incomeTransactionsNew.count == 0)
//            return;
//
//        addedRowCount = [self.incomeTransactionsNew count];
//        [self.viewModel incomeNewTransactions:[self.incomeTransactionsNew copy]
//                            inspectCompletion:^{
//                                // simply ignore to update advices tips.
//                            }];
//        [self.incomeTransactionsNew removeAllObjects];
//    }
//
//    if (addedRowCount != 0 && !self.viewModel.isPresentingSearch) {
//        // 头部插入了新的请求记录，更新焦点
//        NSInteger fixFocusIndex = self.viewModel.requestIndexFocusOnCurrently;
//        [self.viewModel focusOnTransactionWithRequestIndex:fixFocusIndex];
//        [self.waterfallViewController reloadData];
//
//        // insert animation if we're at the top.
//        if (self.historyTableView.contentOffset.y <= 0.f) {
//            [CATransaction begin];
//
//            self.rowInsertInProgress = YES;
//            [CATransaction setCompletionBlock:^{
//                self.rowInsertInProgress = NO;
//                [self tryUpdateTransactions];
//            }];
//
//            NSMutableArray *indexPathsToReload = [NSMutableArray array];
//            for (NSInteger row = 0; row < addedRowCount; row++) {
//                [indexPathsToReload addObject:[NSIndexPath indexPathForRow:row inSection:0]];
//            }
//            [self.historyTableView insertRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationAutomatic];
//
//            [CATransaction commit];
//        } else {
//            // Maintain the user's position if they've scrolled down.
//            CGSize existingContentSize = self.historyTableView.contentSize;
//            [self.historyTableView reloadData];
//            CGFloat contentHeightChange = self.historyTableView.contentSize.height - existingContentSize.height;
//            self.historyTableView.contentOffset = CGPointMake(self.historyTableView.contentOffset.x, self.historyTableView.contentOffset.y + contentHeightChange);
//        }
//    }
//}
//
//- (void)recorderWantCacheTransactionAsUpdated:(MTHNetworkTransaction *)transaction currentState:(MTHNetworkTransactionState)state {
//    dispatch_async(dispatch_get_main_queue(), ^(void) {
//        for (MTHNetworkHistoryViewCell *cell in [self.historyTableView visibleCells]) {
//            if ([cell.transaction isEqual:transaction]) {
//                [cell setNeedsLayout];
//
//                if (transaction.transactionState == MTHNetworkTransactionStateFailed || transaction.transactionState == MTHNetworkTransactionStateFinished) {
//                    [self.viewModel focusOnTransactionWithRequestIndex:self.viewModel.requestIndexFocusOnCurrently];
//                    [self.waterfallViewController reloadData];
//                }
//                break;
//            }
//        }
//    });
//}

// MARK: -
- (void)focusOnFirstRowIfPossible {
    if (self.viewModel.logModels.count > 0) {
        [self focusOnTransactionAtRowIndex:0];
    }
}

- (void)focusOnTransactionAtRowIndex:(NSInteger)index {
    XCMonitorLogModel *logModel = self.viewModel.logModels[index];
    if (logModel.logType == XCMonitorLogTypeNetwork) {
        MTHNetworkTransaction *focusedTrans = nil;
        if (self.searchController.isActive) {
            if (self.viewModel.filteredNetworkTransactions.count <= index)
                return;
            
            focusedTrans = self.viewModel.filteredNetworkTransactions[index];
        } else {
            if (self.viewModel.logModels.count <= index)
                return;
            
            focusedTrans = [MTHNetworkTransaction transactionFromXCLogModel:logModel];
        }
        
        [self.viewModel focusOnTransactionWithRequestIndex:focusedTrans.requestIndex];
        [self.waterfallViewController reloadData];
        [self.historyTableView reloadData];
    }
}

// MARK: - UITableViewDataSource

- (void)reloadHistoryTableView {
    if (![MTHawkeyeUserDefaults shared].networkMonitorOn) {
        [self.historyTableView mthawkeye_setFooterViewWithEmptyTips:@"Network tracing is off"
                                                            tipsTop:80.f
                                                             button:@"Go to Setting"
                                                          btnTarget:self
                                                          btnAction:@selector(gotoSetting)];
    } else {
        BOOL isRecordEmpty = NO;
        if (self.searchController.isActive)
            isRecordEmpty = [self.viewModel.filteredNetworkTransactions count] == 0;
        else
            isRecordEmpty = [self.viewModel.logModels count] == 0;
        
        if (isRecordEmpty) {
            // show filter if
            NSString *filterDesc = [self.viewModel.filter filterDescription];
            if (filterDesc.length > 0) {
                NSString *tips = [NSString stringWithFormat:@"Empty Records\n\n%@", filterDesc];
                [self.historyTableView mthawkeye_setFooterViewWithEmptyTips:tips tipsTop:60.f];
            } else {
                [self.historyTableView mthawkeye_setFooterViewWithEmptyTips:@"Empty Records" tipsTop:80.f];
            }
        } else {
            self.historyTableView.tableFooterView = [UIView new];
        }
    }
    
    [self.historyTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.isActive) {
        return [self.viewModel.filteredNetworkTransactions count];
    } else {
        //return [self.viewModel.networkTransactions count];
        return [self.viewModel.logModels count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    XCMonitorLogModel *logModel = self.viewModel.logModels[indexPath.item];
    if (logModel.logType == XCMonitorLogTypeNetwork) {
        return [MTHNetworkHistoryViewCell preferredCellHeight];
    } else {
        return 30;
    }
}

/// 返回网络记录的cell
- (UITableViewCell *)network_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
                              logModel:(XCMonitorLogModel *)logModel {
    MTHNetworkHistoryViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MTNetworkHistoryViewCellIdentifier];
    if (cell == nil) {
        cell = [[MTHNetworkHistoryViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MTNetworkHistoryViewCellIdentifier];
        cell.delegate = self;
    }
    
    /// 将LogModel转换为transaction
    MTHNetworkTransaction *transaction = [MTHNetworkTransaction transactionFromXCLogModel:logModel];
    if (!transaction) {
        return cell;
    }
    
    NSArray *transactions = nil;
    if (self.searchController.isActive) {
#warning 筛选状态后续调整
        transactions = self.viewModel.filteredNetworkTransactions;
        cell.warningAdviceTypeIDs = self.viewModel.warningAdviceTypeIDs;
    } else {
        transactions = self.viewModel.logModels;
        cell.warningAdviceTypeIDs = nil;
    }

    // 只设置为最普通的状态
    cell.transaction = transaction;
    cell.advices = [self.viewModel advicesForTransaction:cell.transaction];
    cell.status = MTHNetworkHistoryViewCellStatusDefault;
    
//    if (indexPath.row < transactions.count) {
//        cell.transaction = transactions[indexPath.row];
//        cell.advices = [self.viewModel advicesForTransaction:cell.transaction];
//        if (cell.transaction.requestIndex == self.viewModel.requestIndexFocusOnCurrently) {
//            cell.status = MTHNetworkHistoryViewCellStatusOnFocus;
//        } else if ([self.viewModel.currentOnViewIndexArray containsObject:@(cell.transaction.requestIndex)]) {
//            cell.status = MTHNetworkHistoryViewCellStatusOnWaterfall;
//        } else {
//            cell.status = MTHNetworkHistoryViewCellStatusDefault;
//        }
//    }
    
    return cell;
}

/// 返回手动埋点的cell
- (UITableViewCell *)actionTrace_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
                                  logModel:(XCMonitorLogModel *)logModel {
    XCActionEventViewCell *cell = [tableView dequeueReusableCellWithIdentifier:XCActionEventViewCellIdentifier];
    if (cell == nil) {
        cell = [[XCActionEventViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:XCActionEventViewCellIdentifier];
        cell.delegate = self;
    }
    
    // 将LogModel转化为ActionTraceModel
    XCActionTraceModel *actionTraceModel = [XCActionTraceModel actionTraceFromXCLogModel:logModel];
    if (!actionTraceModel) {
        return cell;
    }
    
    cell.actionTraceModel = actionTraceModel;
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XCMonitorLogModel *logModel = [self.viewModel.logModels objectAtIndex:indexPath.item];
    UITableViewCell *cell = nil;
    if (logModel.logType == XCMonitorLogTypeNetwork) {
        cell = [self network_tableView:tableView cellForRowAtIndexPath:indexPath logModel:logModel];
    } else {
        cell = [self actionTrace_tableView:tableView cellForRowAtIndexPath:indexPath logModel:logModel];
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!self.headerLabel) {
        self.headerLabel = [[UILabel alloc] init];
    }
    self.headerLabel.textColor = [UIColor colorWithWhite:0.0667 alpha:1];
    self.headerLabel.font = [UIFont systemFontOfSize:12.0];
    self.headerLabel.textAlignment = NSTextAlignmentLeft;
    self.headerLabel.numberOfLines = 1;
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:self.headerLabel];
    headerView.backgroundColor = [UIColor colorWithRed:243.0 / 255 green:242.0 / 255 blue:242.0 / 255 alpha:1.0];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0;
}

// MARK: - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
#pragma mark 关闭聚焦功能，以后调试解决
    //[self focusOnTransactionAtRowIndex:indexPath.row];
}

// MARK: MTHNetworkHistoryViewCellDelegate
- (void)mt_networkHistoryViewCellDidTappedDetail:(MTHNetworkHistoryViewCell *)cell {
    MTHNetworkTransactionDetailTableViewController *detailViewController = [[MTHNetworkTransactionDetailTableViewController alloc] init];
    detailViewController.transaction = cell.transaction;
    detailViewController.advices = [self.viewModel advicesForTransaction:cell.transaction];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

// MARK: XCActionEventViewCellDelegate

- (void)xc_actionEventCellDidTappedDetail:(XCActionEventViewCell *)cell {
    XCActionTraceDetailViewController *detailViewController = [[XCActionTraceDetailViewController alloc] init];
    detailViewController.actionTraceModel = cell.actionTraceModel;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

// MARK: - Menu Actions

#warning 先关闭菜单功能

//- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}
//
//- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
//    return action == @selector(copy:);
//}
//
//- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
//    if (action == @selector(copy:)) {
//        MTHNetworkTransaction *transaction = [self transactionAtIndexPath:indexPath inTableView:tableView];
//        NSString *requestURLString = transaction.request.URL.absoluteString ?: @"";
//        [[UIPasteboard generalPasteboard] setString:requestURLString];
//    }
//}
//
//- (MTHNetworkTransaction *)transactionAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
//    return self.searchController.isActive ? self.viewModel.filteredNetworkTransactions[indexPath.row] : self.viewModel.logModels[indexPath.row];
//}

// MARK: - Action
- (void)toolsBtnTapped {
    MTHNetworkToolsViewController *vc = [[MTHNetworkToolsViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

// MARK: - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 0) {
        searchBar.text = [searchText lowercaseString];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar {
    [self.searchController setActive:YES];
    // 弹出过滤选项
    if (!self.filterVC) {
        MTHNetworkMonitorFilterViewController *filterVC = [[MTHNetworkMonitorFilterViewController alloc] init];
        filterVC.filterDelegate = self;
        self.filterVC = filterVC;
    }
    MTHPopoverViewController *popoverVC = [[MTHPopoverViewController alloc] initWithContentViewController:self.filterVC fromSourceView:self.view];
    
    // 设为系统默认样式
    [popoverVC.navigationBar setBarTintColor:nil];
    [popoverVC.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [popoverVC.navigationBar setShadowImage:nil];
    [popoverVC.navigationBar setTitleTextAttributes:nil];
    
    [self presentViewController:popoverVC
                       animated:YES
                     completion:^{
                         [searchBar resignFirstResponder];
                     }];
}

// MARK: - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self updateSearchResults];
}

- (void)updateSearchResults {
    NSString *searchString = self.searchController.searchBar.text;
    __weak typeof(self) weak_self = self;
    [self.viewModel updateSearchResultsWithText:searchString
                                     completion:^{
                                         [weak_self reloadHistoryTableView];
                                     }];
}

// MARK: - UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)searchController {
    self.viewModel.isPresentingSearch = YES;
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    self.viewModel.isPresentingSearch = NO;
    
    UIView *searchBarContainer = searchController.searchBar.superview;
    UIView *searchBar = searchController.searchBar;
    //
    if (!CGPointEqualToPoint(searchBarContainer.frame.origin, CGPointZero)) {
        CGFloat top = [self p_navigationBarTopLayoutGuide].length;
        CGRect frame = CGRectMake(0, top, searchBarContainer.bounds.size.width, searchBarContainer.bounds.size.height);
        searchBarContainer.frame = frame;
    }
    if (!CGPointEqualToPoint(searchBar.frame.origin, CGPointZero)) {
        CGRect frame = CGRectMake(0, 0, searchBar.bounds.size.width, searchBar.bounds.size.height);
        searchBar.frame = frame;
    }
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    [self.historyTableView reloadData];
}

// MARK: - MTHNetworkMonitorFilterDelegate

- (void)filterUpdatedWithStatusCodes:(MTHNetworkTransactionStatusCode)statusCodes
                         inspections:(NSArray<MTHNetworkTaskInspectionWithResult *> *)inspections
                               hosts:(NSArray<NSString *> *)hosts {
    self.viewModel.filter.statusFilter = statusCodes;
    self.viewModel.filter.hostFilter = hosts;
    self.viewModel.warningAdviceTypeIDs = [self adviceTypeIDsInInspections:inspections];
    [self updateSearchResults];
}

- (NSSet<NSString *> *)adviceTypeIDsInInspections:(NSArray<MTHNetworkTaskInspectionWithResult *> *)inspections {
    NSMutableSet<NSString *> *adviceTypeIDs = [NSMutableSet set];
    for (MTHNetworkTaskInspectionWithResult *inspection in inspections) {
        for (MTHNetworkTaskAdvice *advice in inspection.advices) {
            [adviceTypeIDs addObject:advice.typeId];
        }
    }
    return adviceTypeIDs;
}

// MARK: - Utils

- (void)gotoSetting {
    MTHawkeyeSettingTableEntity *entity = [[MTHawkeyeSettingTableEntity alloc] init];
    entity.sections = [(MTHawkeyeSettingFoldedCellEntity *)[MTHNetworkHawkeyeSettingUI settings] foldedSections];
    MTHawkeyeSettingViewController *vc = [[MTHawkeyeSettingViewController alloc] initWithTitle:@"Network Settings" viewModelEntity:entity];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
