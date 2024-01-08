//
//  AUIVideoStandradListView.m
//  AUIVideoList
//
//  Created by zzy on 2023/3/7.
//  Copyright © 2019年 com.alibaba. All rights reserved.
//

#import "AUIVideoStandradListView.h"
#import "AUIVideoStandradScrollView.h"
#import "AUIVideoListProgressView.h"
#import "AUIVideoListTitleContentView.h"
#import "AUIVideoListPlayStateImageView.h"
#import "AUIVideoListSlideIndicationView.h"
#import "AUIVideoListDataManager.h"
#import "AUIVideoCacheGlobalSetting.h"

@interface AUIVideoStandradListView ()<AUIVideoStandradScrollViewDelegate, AVPDelegate>

@property (nonatomic, strong) AliListPlayer *listPlayer;
@property (nonatomic, strong) AUIVideoStandradScrollView *scrollView;
@property (nonatomic, strong) AUIVideoListProgressView *progressView;
@property (nonatomic, strong) AUIVideoListTitleContentView *titleContentView;
@property (nonatomic, strong) AUIVideoListPlayStateImageView *playStateImageView;
@property (nonatomic, strong) AUIVideoListSlideIndicationView *slideIndicationView;
@property (nonatomic, strong) AUIVideoListDataManager *dataManager;
// 数据源
@property (nonatomic,strong)NSMutableArray *sources;
@property (nonatomic, assign) NSInteger currentPlayIndex;
// 播放器当前状态
@property (nonatomic, assign) AVPStatus playerStatus;
@property (nonatomic, assign) BOOL isViewDidLoad;
@property (nonatomic, assign) BOOL isLoadSources;
@property (nonatomic, assign) BOOL isMoveToPlayAtIndex;
@property (nonatomic, assign) BOOL isShowPlayProgressBar;
@property (nonatomic, assign) BOOL isShowPlayTitleContent;
@property (nonatomic, assign) BOOL isShowPlayStatusTapChange;
@property (nonatomic, assign) BOOL isOpenLoopPlay;
@property (nonatomic, assign) BOOL isAutoPlayNext;

@end

@implementation AUIVideoStandradListView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isViewDidLoad = YES;
    self.hiddenMenuButton = YES;
    [self loadSubviews];
    [self initPlayer];
    if (!self.isLoadSources) {
        [self loadSources:[self.dataManager convertSourceData:[AUIVideoListDataManager getDefaultJsonSourceData]].mutableCopy];
    }
    [self loadSourcesToPlay];
    [self loadUI];
    [self loadSlideIndication];
    self.automaticallyAdjustsScrollViewInsets = NO;
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

- (void)initPlayer {
    self.listPlayer.playerView = self.scrollView.playView;
    
    [AUIVideoCacheGlobalSetting setupCacheConfig];
    AVPConfig *config = [self.listPlayer getConfig];
    config.enableLocalCache = YES;
    [self.listPlayer setConfig:config];
    
    if (self.isOpenLoopPlay) {
        self.listPlayer.loop = YES;
    }
}

- (void)loadSubviews {
    [self.view addSubview:self.scrollView];
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
    self.scrollView.currentIndex = 0;
    
    if (self.isMoveToPlayAtIndex) {
        [self moveToPlayAtIndex:(int)self.currentPlayIndex];
    } else {
        [self moveToCurrentPlay];
    }
    
    __weak typeof(self) weakSelf = self;
    self.progressView.onSliderValueChanged = ^(float progress) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.listPlayer seekToTime:progress * strongSelf.listPlayer.duration seekMode:AVP_SEEKMODE_ACCURATE];
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

- (void)setupRefreshHeader {
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshSources)];
    header.accessibilityIdentifier = AUIVideoListAccessibilityStr(@"headerRefresh");
    [self.scrollView getScrollView].mj_header = header;
    header.stateLabel.hidden = YES;
    if ([self isReloadData]) {
        [header loadingView].activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        header.stateLabel.textColor = AUIFoundationColor(@"text_weak");
    }
}

- (void)setupLoadMoreFooter
{
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreSources)];
    footer.accessibilityIdentifier = AUIVideoListAccessibilityStr(@"footerRefresh");
    [self.scrollView getScrollView].mj_footer = footer;
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

- (void)updatePlayerSource:(NSArray<AUIVideoInfo *> *)source {
    if (source.count > 0) {
        for (AUIVideoInfo *model in source) {
            [self.listPlayer addUrlSource:model.url uid:model.uid];
        }
    }
}

- (void)refreshSources {
    if ([[self.scrollView getScrollView].mj_footer isRefreshing]) {
        [[self.scrollView getScrollView].mj_header endRefreshing];
        return;
    }
    
    if ([self isReloadData]) {
        [self reloadData:self.dataManager.requestUrl completion:nil];
    } else {
        [[self.scrollView getScrollView].mj_header endRefreshing];
        [self loadSources:[self.dataManager convertSourceData:[AUIVideoListDataManager getDefaultJsonSourceData]]];
    }
}

- (void)loadMoreSources {
    if ([[self.scrollView getScrollView].mj_header isRefreshing]) {
        [[self.scrollView getScrollView].mj_footer endRefreshing];
        return;
    }
    
    if ([self isLoadMoreData]) {
        [self loadMoreData:self.dataManager.requestUrl nextIndex:self.dataManager.nextIndex completion:nil];
    } else {
        if (self.currentPlayIndex == self.sources.count - 1) {
            [[self.scrollView getScrollView].mj_footer endRefreshing];
            [AVToastView show:AUIVideoListString(@"敬请期待～") view:self.view position:AVToastViewPositionMid];
        }
    }
}

- (void)loadSources:(NSArray *)sources {
    self.sources = sources.mutableCopy;
    _isLoadSources = YES;
}

- (void)loadSourcesToPlay {
    [self.listPlayer stop];
    [self.scrollView updateSources:self.sources add:NO];
    [self updatePlayerSource:self.sources];
    [self moveToCurrentPlay];
}

- (void)addSources:(NSArray *)sources {
    [self.sources addObjectsFromArray:sources];
    [self addSourcesToPlay:sources];
}

- (void)addSourcesToPlay:(NSArray *)addSources {
    [self.scrollView updateSources:addSources add:YES];
    [self updatePlayerSource:addSources];
    [self autoMoveToPlayNext];
}

- (void)moveToPlayAtIndex:(int)index {
    self.isMoveToPlayAtIndex = YES;
    self.currentPlayIndex = index;
    if (!self.isViewDidLoad) {
        return;
    }
    
    if (self.sources.count <= index) {
        return;
    }
    [self.scrollView moveScrollAtIndex:index duration:0];
    self.isMoveToPlayAtIndex = NO;
}

- (void)showPlayProgressBar:(BOOL)open {
    if (self.isShowPlayProgressBar != open) {
        if (open) {
            if (!self.isViewDidLoad) {
                if (!self.progressView.superview) {
                    [self.view addSubview:self.progressView];
                }
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
            if (!self.isViewLoaded) {
                if (!self.titleContentView.superview) {
                    [self.view addSubview:self.titleContentView];
                }
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
            AUIVideoInfo *videoInfo = [self findSourceFromIndex:self.currentPlayIndex];
            [self.titleContentView updateTitle:videoInfo.author content:videoInfo.title];
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
    
    [self.scrollView moveScrollAtIndex:self.currentPlayIndex + 1 duration:0.35];
}

- (void)moveToCurrentPlay {
    AUIVideoInfo *videoInfo = [self findSourceFromIndex:self.currentPlayIndex];
    if (videoInfo) {
        [self.listPlayer moveTo:videoInfo.uid];
    }
}

- (void)reloadData:(NSString *)url completion:(nullable void(^)(BOOL success, NSArray<AUIVideoInfo *> *sources, NSError *error))completion {
    self.dataManager.requestUrl = url;
    self.dataManager.nextIndex = nil;
    AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:self.view animated:YES];
    loading.labelText = AUIVideoListString(@"加载中...");
    __weak typeof(self) weakSelf = self;
    [self.dataManager requestVideoInfos:NO completion:^(BOOL success, NSArray *sources, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        if ([[strongSelf.scrollView getScrollView].mj_footer isRefreshing]) {
            [[strongSelf.scrollView getScrollView].mj_footer endRefreshing];
        }
        [loading hideAnimated:YES];
        if (success) {
            if (completion) {
                completion(YES, sources, nil);
            } else {
                [self loadSources:sources];
            }
        } else {
            if (completion) {
                completion(NO, nil, error);
            } else {
                [AVToastView show:error.debugDescription view:self.view position:AVToastViewPositionMid];
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
        if ([[strongSelf.scrollView getScrollView].mj_header isRefreshing]) {
            [[strongSelf.scrollView getScrollView].mj_header endRefreshing];
        }
        [loading hideAnimated:YES];
        if (success) {
            if (completion) {
                completion(YES, sources, strongSelf.dataManager.nextIndex, nil);
            } else {
                [strongSelf addSources:sources];
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

#pragma mark -- AUIVideoStandradScrollViewDelegate
// 全屏点击事件
- (void)tapGestureAction:(AUIVideoStandradScrollView *)scrollView {
    if (self.isShowPlayStatusTapChange) {
        if (self.playerStatus == AVPStatusStarted) {
            [self.listPlayer pause];
            [self.playStateImageView show:YES];
        }else if (self.playerStatus == AVPStatusPaused) {
            [self.listPlayer start];
            [self.playStateImageView show:NO];
        }
    }
}

// 滚动事件,移动位置超过一个
- (void)scrollView:(AUIVideoStandradScrollView *)scrollView didEndDeceleratingAtIndex:(NSInteger)index {
    self.scrollView.showPlayImage = NO;
    AUIVideoInfo *videoInfo = [self findSourceFromIndex:index];
    if (self.playerStatus == AVPStatusPaused && index == self.currentPlayIndex) {
        [self.scrollView showPlayView];
        [self.listPlayer start];
    }else if (videoInfo) {
        self.currentPlayIndex = index;
        [self moveToCurrentPlay];
        [self updateTitleContent];
    }
    NSLog(@"播放第%ld个",(long)index);
}

// 移动到下一个
- (void)scrollView:(AUIVideoStandradScrollView *)scrollView motoNextAtIndex:(NSInteger)index {
    self.scrollView.showPlayImage = NO;
    AUIVideoInfo *videoInfo = [self findSourceFromIndex:index];
    if (videoInfo && self.currentPlayIndex != index) {
        self.currentPlayIndex = index;
        [self.listPlayer moveToNext];
        [self updateTitleContent];
        NSLog(@"播放第%ld个",(long)index);
    }
}

// 移动到上一个
- (void)scrollView:(AUIVideoStandradScrollView *)scrollView motoPreAtIndex:(NSInteger)index {
    self.scrollView.showPlayImage = NO;
    AUIVideoInfo *videoInfo = [self findSourceFromIndex:index];
    if (videoInfo && self.currentPlayIndex != index) {
        self.currentPlayIndex = index;
        [self.listPlayer moveToPre];
        [self updateTitleContent];
        NSLog(@"播放第%ld个",(long)index);
    }
}

// 当前播放视图准备滑动
- (void)scrollViewWillBeginDragging:(AUIVideoStandradScrollView *)scrollView {
    if (self.isShowPlayStatusTapChange) {
        [self.playStateImageView show:NO];
    }
    
    [self.slideIndicationView updateShowStatus:NO];
    [AUIVideoListDataManager updateSlideIndicationShow:NO pageName:NSStringFromClass([self class])];
}

// 当前播放视图移除屏幕
- (void)scrollViewScrollOut:(AUIVideoStandradScrollView *)scrollView {
    [self.listPlayer pause];
    if (self.isShowPlayProgressBar) {
        [self.progressView forceSliderSetOrigin];
    }
}

#pragma mark -- AVPDelegate
// 错误代理回调
- (void)onError:(AliPlayer*)player errorModel:(AVPErrorModel *)errorModel {
    NSLog(@"error:%@", errorModel.message);
}

// 播放器事件回调
-(void)onPlayerEvent:(AliPlayer*)player eventType:(AVPEventType)eventType {
    switch (eventType) {
        case AVPEventPrepareDone: {
        }
            break;
        case AVPEventFirstRenderedStart: {
            [self.scrollView showPlayView];
        }
            break;
        default:
            break;
    }
}

// 播放器状态改变回调
- (void)onPlayerStatusChanged:(AliPlayer*)player oldStatus:(AVPStatus)oldStatus newStatus:(AVPStatus)newStatus {
    self.playerStatus = newStatus;
    switch (newStatus) {
        case AVPStatusStarted: {
            self.scrollView.showPlayImage = NO;
        }
            break;
        case AVPStatusPaused: {
            self.scrollView.showPlayImage = YES;
        }
            break;
        default:
            break;
    }
}

// 视频当前播放位置回调
- (void)onCurrentPositionUpdate:(AliPlayer *)player position:(int64_t)position {
    if (self.isShowPlayProgressBar) {
        [self.progressView updateSliderValue:position duration:player.duration];
    }
    
    if (self.isAutoPlayNext) {
        if (position == player.duration) {
            [self autoMoveToPlayNext];
        }
    }
}

- (AUIVideoInfo *)findSourceFromIndex:(NSInteger)index {
    if (self.sources.count > index) {
        return self.sources[index];
    }
    return nil;
}

- (void)destroyPlay {
    // 退出播放页面时需要销毁播放器
    if (_listPlayer) {
        [_listPlayer stop];
        [_listPlayer destroy];
        _listPlayer = nil;
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
- (AliListPlayer *)listPlayer {
    if (!_listPlayer) {
        _listPlayer = [[AliListPlayer alloc] init];
        _listPlayer.loop = YES;
        _listPlayer.autoPlay = YES;
        _listPlayer.scalingMode = AVP_SCALINGMODE_SCALEASPECTFIT;
        _listPlayer.delegate = self;
        _listPlayer.stsPreloadDefinition = @"FD";
    }
    return _listPlayer;
}

- (AUIVideoStandradScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[AUIVideoStandradScrollView alloc] initWithFrame:self.view.bounds];
        _scrollView.delegate = self;
    }
    return _scrollView;
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

- (NSMutableArray *)sources {
    if (!_sources) {
        _sources = [NSMutableArray array];
    }
    return _sources;
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
