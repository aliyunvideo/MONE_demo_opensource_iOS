//
//  AUIVideoFunctionListView.m
//  AUIVideoList
//
//  Created by ISS013602000846 on 2022/11/9.
//

#import "AUIVideoFunctionListView.h"
#import "AUIVideoFunctionPlayCell.h"
#import "AUIVideoListDataManager.h"
#import "AUIVideoPreloadTool.h"
#import "AUIVideoListPlayStateImageView.h"
#import "AUIVideoListProgressView.h"
#import "AUIVideoListTitleContentView.h"
#import "AUIVideoListSlideIndicationView.h"

#define SCREEN [UIScreen mainScreen].bounds.size

@interface AUIVideoFunctionListView ()<UITableViewDataSource, UITableViewDelegate, AUIVideoFunctionPlayCellDelegate, AliMediaLoaderStatusDelegate>

@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) AUIVideoListProgressView *progressView;
@property (nonatomic, strong) AUIVideoListTitleContentView *titleContentView;
@property (nonatomic, strong) AUIVideoListPlayStateImageView *playStateImageView;
@property (nonatomic, strong) AUIVideoListSlideIndicationView *slideIndicationView;
@property (nonatomic, strong) AUIVideoListDataManager *dataManager;
@property (nonatomic, strong) NSMutableArray<AUIVideoInfo *> *sources;
@property (nonatomic, assign) NSInteger currentPlayIndex;
@property (nonatomic, strong) NSMutableArray<AliPlayer *> *playerSaver;

// 避免频繁调用willDisplayCell方法
@property (nonatomic, assign) BOOL willDisplayCellExecPrepare;
@property (nonatomic, assign) BOOL isViewDidLoad;
@property (nonatomic, assign) BOOL isLoadSources;
@property (nonatomic, assign) BOOL isMoveToPlayAtIndex;
@property (nonatomic, assign) BOOL isShowPlayProgressBar;
@property (nonatomic, assign) BOOL isShowPlayTitleContent;
@property (nonatomic, assign) BOOL isShowPlayStatusTapChange;
@property (nonatomic, assign) BOOL isOpenLoopPlay;
@property (nonatomic, assign) BOOL isAutoPlayNext;

@end

@implementation AUIVideoFunctionListView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isViewDidLoad = YES;
    self.hiddenMenuButton = YES;
    self.willDisplayCellExecPrepare = YES;
    
    [self loadSubviews];
    [self setupSourceData];
    [self loadCachePreload];
    [self loadUI];
    [self loadSlideIndication];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self popGestureClose];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self destroyPlay];
    [self popGestureOpen];
}

- (void)loadSubviews {
    [self.view addSubview:self.table];
    [self.view bringSubviewToFront:self.headerView];
    
    if (self.isShowPlayProgressBar) {
        [self.view addSubview:self.progressView];
    }
    
    if (self.isShowPlayTitleContent) {
        [self.view addSubview:self.titleContentView];
    }
    
    if (self.isShowPlayStatusTapChange) {
        [self.playStateImageView show:NO];
    }
}

- (void)loadUI {
    if (self.isMoveToPlayAtIndex) {
        self.table.hidden = YES;
        [self moveToPlayAtIndex:(int)self.currentPlayIndex];
    }
    
    __weak typeof(self) weakSelf = self;
    self.progressView.onSliderValueChanged = ^(float progress) {
        __strong typeof(self) strongSelf = weakSelf;
        AUIVideoFunctionPlayCell *curCell = [strongSelf.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:strongSelf.currentPlayIndex inSection:0]];
        [curCell.player seekToTime:progress * curCell.player.duration seekMode:AVP_SEEKMODE_ACCURATE];
    };
    
    if (self.isShowPlayTitleContent) {
        [self updateTitleContent];
    }
    
    [self setupRefreshHeader];
    [self setupLoadMoreFooter];
}

- (void)loadSlideIndication {
    if ([AUIVideoListDataManager isSlideIndicationShow:NSStringFromClass([self class])]) {
        [self.slideIndicationView updateShowStatus:YES];
        [AUIVideoListDataManager updateSlideIndicationShow:NO pageName:NSStringFromClass([self class])];
    }
}

- (void)setupRefreshHeader
{
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshSources)];
    header.accessibilityIdentifier = AUIVideoListAccessibilityStr(@"headerRefresh");
    self.table.mj_header = header;
    [header stateLabel].hidden = YES;
    if ([self isReloadData]) {
        [header loadingView].activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        header.stateLabel.textColor = AUIFoundationColor(@"text_weak");
    }
}

- (void)setupLoadMoreFooter
{
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreSources)];
    footer.accessibilityIdentifier = AUIVideoListAccessibilityStr(@"footerRefresh");
    self.table.mj_footer = footer;
    [footer setRefreshingTitleHidden:YES];
    if ([self isLoadMoreData]) {
        [footer setTitle:AUIVideoListString(@"—— 我是有底线的 ——") forState:MJRefreshStateNoMoreData];
        [footer setTitle:@"" forState:MJRefreshStateIdle];
        footer.stateLabel.font = [UIFont systemFontOfSize:14.0f];
        footer.stateLabel.textColor = AUIFoundationColor(@"text_weak");
        [footer loadingView].activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    }
}

- (BOOL)isReloadData {
    return self.dataManager.requestUrl && self.dataManager.requestUrl.length > 0;
}

- (BOOL)isLoadMoreData {
    return self.dataManager.requestUrl && self.dataManager.requestUrl.length > 0 && self.dataManager.nextIndex;
}

- (void)setupSourceData {
    if (!self.isLoadSources) {
        [self loadSources:[self.dataManager convertSourceData:[AUIVideoListDataManager getDefaultJsonSourceData]]];
    }
}

- (void)loadCachePreload {
    [AUIVideoPreloadTool setPreloadConfig:self];
    [AUIVideoPreloadTool preloadUrl:self.sources.firstObject.url];
}

- (void)refreshSources {
    if ([self.table.mj_footer isRefreshing]) {
        [self.table.mj_header endRefreshing];
        return;
    }
    
    if ([self isReloadData]) {
        [self reloadData:self.dataManager.requestUrl completion:nil];
    } else {
        [self.table.mj_header endRefreshing];
        [self loadSources:[self.dataManager convertSourceData:[AUIVideoListDataManager getDefaultJsonSourceData]]];
        [self loadSourcesToPlay];
    }
}

- (void)loadMoreSources {
    if ([self.table.mj_header isRefreshing]) {
        [self.table.mj_footer endRefreshing];
        return;
    }
    
    if ([self isLoadMoreData]) {
        [self loadMoreData:self.dataManager.requestUrl nextIndex:self.dataManager.nextIndex completion:nil];
    } else {
        if (self.currentPlayIndex == self.sources.count - 1) {
            [self.table.mj_footer endRefreshing];
            [AVToastView show:AUIVideoListString(@"敬请期待～") view:self.view position:AVToastViewPositionMid];
        }
    }
}

- (void)loadSources:(NSArray *)sources {
    self.sources = sources.mutableCopy;
    self.isLoadSources = YES;
}

- (void)loadSourcesToPlay {
    self.willDisplayCellExecPrepare = YES;
    for (AliPlayer *player in self.playerSaver) {
        [player stop];
    }
    [self.table reloadData];
}

- (void)addSources:(NSArray *)sources {
    [self.sources addObjectsFromArray:sources];
    [self addSourcesToPlay];
}

- (void)addSourcesToPlay {
    self.willDisplayCellExecPrepare = YES;
    [self.table reloadData];
    [self moveToPlayAtIndex:(int)self.currentPlayIndex + 1 duration:0.01];
}

- (void)moveToPlayAtIndex:(int)index {
    self.currentPlayIndex = index;
    [self moveToPlayAtIndex:index duration:0.5];
}

- (void)moveToPlayAtIndex:(int)index duration:(float)duration {
    self.isMoveToPlayAtIndex = YES;
    if (!self.isViewDidLoad) {
        return;
    }
    
    if (self.sources.count <= index) {
        return;
    }
    
    for (AliPlayer *player in self.playerSaver) {
        [player stop];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.willDisplayCellExecPrepare = YES;
        [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.table.hidden) {
            self.table.hidden = NO;
        }
        self.currentPlayIndex = index;
        [self scrollViewDidEndDecelerating:self.table];
        self.isMoveToPlayAtIndex = NO;
    });
}

- (void)showPlayProgressBar:(BOOL)open {
    if (self.isShowPlayProgressBar != open) {
        if (open) {
            if (!self.progressView.superview) {
                [self.view addSubview:self.progressView];
            }
        } else {
            if (self.progressView.superview) {
                [self.progressView removeFromSuperview];
            }
        }
        
        self.isShowPlayProgressBar = open;
    }
}

- (void)showPlayTitleContent:(BOOL)open {
    if (self.isShowPlayTitleContent != open) {
        if (open) {
            if (!self.titleContentView.superview) {
                [self.view addSubview:self.titleContentView];
            }
        } else {
            if (self.titleContentView.superview) {
                [self.titleContentView removeFromSuperview];
            }
        }
        
        self.isShowPlayTitleContent = open;
    }
}

- (void)updateTitleContent {
    if (self.isShowPlayTitleContent) {
        if (self.sources.count > self.currentPlayIndex) {
            AUIVideoInfo *currentVideoInfo = self.sources[self.currentPlayIndex];
            [self.titleContentView updateTitle:currentVideoInfo.author content:currentVideoInfo.title];
        }
    }
}

- (void)showPlayStatusTapChange:(BOOL)open {
    self.isShowPlayStatusTapChange = open;
}

- (void)openLoopPlay:(BOOL)open {
    self.isOpenLoopPlay = open;
}

- (void)autoPlayNext:(BOOL)open {
    if (self.isOpenLoopPlay) {
        self.isAutoPlayNext = NO;
    } else {
        self.isAutoPlayNext = open;
    }
}

- (void)autoMoveToPlayNext {
    if (self.sources.count <= self.currentPlayIndex + 1) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentPlayIndex + 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [self updateTitleContent];
    });
}

- (void)reloadData:(NSString *)url completion:(nullable void(^)(BOOL success, NSArray<AUIVideoInfo *> *sources, NSError *error))completion {
    self.dataManager.requestUrl = url;
    self.dataManager.nextIndex = nil;
    AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:self.view animated:YES];
    loading.labelText = AUIVideoListString(@"加载中...");
    __weak typeof(self) weakSelf = self;
    [self.dataManager requestVideoInfos:NO completion:^(BOOL success, NSArray *sources, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        if ([strongSelf.table.mj_header isRefreshing]) {
            [strongSelf.table.mj_header endRefreshing];
        }
        [loading hideAnimated:YES];
        if (success) {
            if (completion) {
                completion(YES, sources, nil);
            } else {
                [strongSelf loadSources:sources];
                [strongSelf loadSourcesToPlay];
            }
        } else {
            if (completion) {
                completion(NO, nil, error);
            } else {
                [AVToastView show:error.debugDescription view:strongSelf.view position:AVToastViewPositionMid];
            }
        }
    }];
}

- (void)loadMoreData:(NSString *)url nextIndex:(id)nextIndex completion:(nullable void(^)(BOOL success, NSArray<AUIVideoInfo *> *sources, id nextIndex, NSError *error))completion {
    self.dataManager.requestUrl = url;
    self.dataManager.nextIndex = nextIndex;
    AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:self.view animated:YES];
    loading.labelText = AUIVideoListString(@"加载中...");
    __weak typeof(self) weakSelf = self;
    [self.dataManager requestVideoInfos:YES completion:^(BOOL success, NSArray *sources, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        if ([strongSelf.table.mj_footer isRefreshing]) {
            [strongSelf.table.mj_footer endRefreshing];
        }
        [loading hideAnimated:YES];
        if (success) {
            if (completion) {
                completion(YES, sources, strongSelf.dataManager.nextIndex, nil);
            } else {
                [strongSelf addSources:sources];
                [strongSelf addSourcesToPlay];
            }
        } else {
            if (completion) {
                completion(NO, nil, nil, error);
            } else {
                [AVToastView show:error.debugDescription view:strongSelf.view position:AVToastViewPositionMid];
            }
        }
    }];
}

#pragma mark -- UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.willDisplayCellExecPrepare = YES;
    
    if (self.isShowPlayStatusTapChange) {
        [self.playStateImageView show:NO];
    }
    
    [self.slideIndicationView updateShowStatus:NO];
    [AUIVideoListDataManager updateSlideIndicationShow:NO pageName:NSStringFromClass([self class])];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isMoveToPlayAtIndex) {
        return;
    }
    
    CGFloat offsetY = scrollView.contentOffset.y;
    if ((self.currentPlayIndex >= 0 && self.currentPlayIndex < self.sources.count - 1) &&
        offsetY < 0) {
        return;
    }

    NSInteger nextPlayIndex = lroundf(offsetY / SCREEN.height);
    if (nextPlayIndex == self.currentPlayIndex) {
        AUIVideoFunctionPlayCell *nextCell = [self getCellAtIndex:nextPlayIndex + 1];
        if (nextCell) {
            if (nextCell.playStatus != AVPStatusPaused) {
                [nextCell.player pause];
            }
        }

        AUIVideoFunctionPlayCell *lastCell = [self getCellAtIndex:nextPlayIndex - 1];
        if (lastCell) {
            if (lastCell.playStatus != AVPStatusPaused) {
                [lastCell.player pause];
            }
        }
    } else {
        AUIVideoFunctionPlayCell *currentCell = [self getCellAtIndex:self.currentPlayIndex];
        [currentCell.player pause];

        AUIVideoFunctionPlayCell *nextCell = [self getCellAtIndex:nextPlayIndex];
        if (nextCell) {
            [nextCell.player start];
        }

        self.currentPlayIndex = nextPlayIndex;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.isShowPlayProgressBar) {
        [self.progressView forceSliderSetOrigin];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    AUIVideoFunctionPlayCell *currentCell = [self getCellAtIndex:self.currentPlayIndex];
    for (AliPlayer *player in self.playerSaver) {
        if (currentCell.player != player) {
            [player stop];
        }
    }
    
    [self updateTitleContent];
}

#pragma mark -- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUIVideoFunctionPlayCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AliPlayTableViewCell"];
    if (cell == nil) {
        cell = [[AUIVideoFunctionPlayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AliPlayTableViewCell"];
        cell.player.loop = self.isOpenLoopPlay;
        cell.delegate = self;
        if (![self.playerSaver containsObject:cell.player]) {
            [self.playerSaver addObject:cell.player];
        }
    }
    
    return cell;
}

#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (self.isMoveToPlayAtIndex || self.willDisplayCellExecPrepare) {
        AUIVideoFunctionPlayCell *currentCell = (AUIVideoFunctionPlayCell *)cell;
        [currentCell setSource:self.sources[indexPath.row].url];
        [currentCell.player prepare];
        self.willDisplayCellExecPrepare = NO;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return SCREEN.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isShowPlayStatusTapChange) {
        AUIVideoFunctionPlayCell *cell = [self getCellAtIndex:indexPath.row];
        if (cell.playStatus == AVPStatusPaused) {
            [cell.player start];
            [self.playStateImageView show:NO];
        } else {
            [cell.player pause];
            [self.playStateImageView show:YES];
        }
    }
}

- (AUIVideoFunctionPlayCell *)getCellAtIndex:(NSInteger)index {
    AUIVideoFunctionPlayCell *currentCell = [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    return currentCell;
}

#pragma mark -- AUIVideoFunctionPlayCellDelegate
- (void)startPreloadNextPlayAtPlayer:(AliPlayer *)player {
    // 对下一个进行预加载
    if (self.currentPlayIndex + 1 < self.sources.count) {
        [AUIVideoPreloadTool cancelPreloadUrl:self.sources[self.currentPlayIndex].url];
        if (![self.sources[self.currentPlayIndex + 1].url isEqualToString:self.sources[self.currentPlayIndex].url]) {
            [AUIVideoPreloadTool cancelPreloadUrl:self.sources[self.currentPlayIndex + 1].url];
            [AUIVideoPreloadTool preloadUrl:self.sources[self.currentPlayIndex + 1].url];
        }
    }
}

- (void)updateCurrentPosition:(int64_t)position atPlayer:(AliPlayer *)player {
    if (self.isShowPlayProgressBar) {
        [self.progressView updateSliderValue:position duration:player.duration];
    }
    
    if (self.isAutoPlayNext) {
        if (position == player.duration) {
            self.willDisplayCellExecPrepare = YES;
            [self autoMoveToPlayNext];
        }
    }
}

#pragma mark -- AliMediaLoaderStatusDelegate
- (void)onCompleted:(NSString *)url {
    dispatch_async(dispatch_get_main_queue(), ^{
        [AUIVideoPreloadTool cancelPreloadUrl:url];
        [self preloadNextAtCurrentUrl:url];
    });
}

- (void)onError:(NSString *)url code:(int64_t)code msg:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [AUIVideoPreloadTool cancelPreloadUrl:url];
        [self preloadNextAtCurrentUrl:url];
    });
}

- (void)preloadNextAtCurrentUrl:(NSString *)url {
    AUIVideoInfo *curModel = [self getModelAtUrl:url];
    if (curModel) {
        NSInteger index = self.currentPlayIndex;
        if (index + 1 < self.sources.count) {
            if (![self.sources[index + 1].url isEqualToString:url]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [AUIVideoPreloadTool cancelPreloadUrl:self.sources[index + 1].url];
                    AUIVideoFunctionPlayCell *currCell = [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentPlayIndex inSection:0]];
                    if (currCell.player.bufferedPosition > 5 * 1000) {
                        [AUIVideoPreloadTool preloadUrl:self.sources[index + 1].url];
                    }
                });
            }
        }
    }
}

- (AUIVideoInfo *)getModelAtUrl:(NSString *)url {
    for (int i = 0; i < self.sources.count; i++) {
        AUIVideoInfo *model = self.sources[i];
        if ([model.url isEqualToString:url]) {
            return model;
        }
    }
    return nil;
}

- (void)destroyPlay {
    // 退出播放页面时需要销毁播放器，停止全部预加载
    [AUIVideoPreloadTool cancelPreloadUrl:nil];
    for (AliPlayer *player in self.playerSaver) {
        [player stop];
        [player destroy];
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    if (!parent) {
        [self destroyPlay];
    }
}

- (void)popGestureClose {
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        for (UIGestureRecognizer *popGesture in self.navigationController.interactivePopGestureRecognizer.view.gestureRecognizers) {
            popGesture.enabled = NO;
        }
    }
}

- (void)popGestureOpen {
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        for (UIGestureRecognizer *popGesture in self.navigationController.interactivePopGestureRecognizer.view.gestureRecognizers) {
            popGesture.enabled = YES;
        }
    }
}

#pragma mark -- lazy load
- (UITableView *)table {
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _table.backgroundColor = [UIColor blackColor];
        _table.delegate = self;
        _table.dataSource = self;
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        _table.pagingEnabled = YES;
        
        if (@available(iOS 11.0, *)) {
            _table.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        if (@available(iOS 13.0, *)) {
            _table.automaticallyAdjustsScrollIndicatorInsets = NO;
        }
    }
    return _table;
}

- (AUIVideoListProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[AUIVideoListProgressView alloc] initWithFrame:CGRectMake(0, self.view.av_height - 81, self.view.av_width, 25)];
        _progressView.accessibilityIdentifier = AUIVideoListAccessibilityStr(@"progressView");
    }
    return _progressView;
}

- (AUIVideoListTitleContentView *)titleContentView {
    if (!_titleContentView) {
        _titleContentView = [[AUIVideoListTitleContentView alloc] initWithFrame:CGRectMake(20, self.view.av_height - 81 - 26 - 64, self.view.av_width - 20 - 75, 64)];
        _titleContentView.accessibilityIdentifier = AUIVideoListAccessibilityStr(@"titleContentView");
    }
    return _titleContentView;
}

- (AUIVideoListPlayStateImageView *)playStateImageView {
    if (!_playStateImageView) {
        _playStateImageView = [[AUIVideoListPlayStateImageView alloc] initOnView:self.view image:nil];
    }
    return _playStateImageView;
}

- (AUIVideoListSlideIndicationView *)slideIndicationView {
    if (!_slideIndicationView) {
        _slideIndicationView = [[AUIVideoListSlideIndicationView alloc] initOnView:self.view];
    }
    return _slideIndicationView;
}

- (AUIVideoListDataManager *)dataManager {
    if (!_dataManager) {
        _dataManager = [[AUIVideoListDataManager alloc] init];
    }
    return _dataManager;
}

- (NSMutableArray<AUIVideoInfo *> *)sources {
    if (!_sources) {
        _sources = [NSMutableArray array];
    }
    return _sources;
}

- (NSMutableArray<AliPlayer *> *)playerSaver {
    if (!_playerSaver) {
        _playerSaver = [NSMutableArray array];
    }
    return _playerSaver;
}

- (BOOL)isShowPlayProgressBar {
    if (!_isShowPlayProgressBar) {
        _isShowPlayProgressBar = YES;
    }
    return _isShowPlayProgressBar;
}

- (BOOL)isShowPlayTitleContent {
    if (!_isShowPlayTitleContent) {
        _isShowPlayTitleContent = YES;
    }
    return _isShowPlayTitleContent;
}

- (BOOL)isShowPlayStatusTapChange {
    if (!_isShowPlayStatusTapChange) {
        _isShowPlayStatusTapChange = YES;
    }
    return _isShowPlayStatusTapChange;
}

- (BOOL)isOpenLoopPlay {
    if (!_isOpenLoopPlay) {
        _isOpenLoopPlay = YES;
    }
    return _isOpenLoopPlay;
}

@end
