//
//  AUIVideoFlowViewController.m
//  ApsaraVideo
//
//  Created by Bingo on 2021/7/1.
//

#import "AUIVideoFlowViewController.h"
#import "AlivcPlayerVideo.h"
#import "AUIVideoFlowCardCell.h"
#import "AlivcPlayerServer.h"
#import "AlivcPlayerFoundation.h"

#import "AUIPlayerDetailViewController.h"
#import "AlivcPlayerManager.h"
#import "AUIPlayerFeedListVideoContainer.h"

@interface AUIVideoFlowViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,AUIVideoFlowCardCellDelegate, AlivcPlayerPluginEventProtocol>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *emptyLabel;

@property (nonatomic, strong) NSMutableArray<AlivcPlayerVideo *> *items;

@property (nonatomic, assign) BOOL scrollViewDragging;

@property (nonatomic, strong) AUIVideoFlowCardCell *currentPlayCell;

@end

@implementation AUIVideoFlowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.hiddenMenuButton = YES;
    self.titleView.text = AUIVideoFlowString(@"Video Flow");
        
    self.items = [NSMutableArray array];
    
    [self setupCollectionView];

    [self setupRefreshHeader];
    [self setupLoadMoreFooter];
    
    [self.collectionView.mj_header beginRefreshing];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self handlePlayerSuperViewChanged];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [AlivcPlayerManager manager].pageEventFrom = AlivcPlayerPageEventFromFlowPage;
    [AlivcPlayerManager manager].shouldFlowOrientation = YES;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if ([AlivcPlayerManager manager].pageEventJump == AlivcPlayerPageEventJumpFlowToDetailPage) {
        if (!AlivcPlayerManager.manager.playContainView.window) {
            [AlivcPlayerManager.manager pause];
        }
    } else {
        [AlivcPlayerManager manager].backgroudModeEnabled = NO;
        [AlivcPlayerManager manager].shouldFlowOrientation = NO;
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
        [[AlivcPlayerManager manager] destroyIncludePlayer:YES];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat width = self.contentView.av_width;
    CGFloat height = self.contentView.av_height;
    width = MIN(width, height);
    height = MAX(height, self.contentView.av_height);
    
    if ([AlivcPlayerManager manager].currentOrientation == 0) {
        self.collectionView.frame = CGRectMake(0, 0, self.contentView.av_width, self.contentView.av_height);
    } else {
        self.collectionView.frame = self.collectionView.frame;
    }
}


- (void)setupCollectionView {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.contentView.bounds collectionViewLayout:flowLayout];
    self.collectionView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"videoFlowPage_collectionView");
    self.collectionView.backgroundColor = AUIFoundationColor(@"bg_medium");
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.bounces = YES;
    self.collectionView.scrollsToTop = YES;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.delaysContentTouches = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.collectionView registerClass:[AUIVideoFlowCardCell class] forCellWithReuseIdentifier:@"defaultCell"];
#ifdef __IPHONE_11_0
    if ([self.collectionView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)])
    {
        if (@available(iOS 11.0, *)) {
            self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
    }
#endif
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.contentView addSubview:self.collectionView];
}

- (void)setupRefreshHeader
{
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshMessage)];
    header.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"videoFlowPage_headerRefresh");
    self.collectionView.mj_header = header;
    [header stateLabel].hidden = YES;
    [header loadingView].activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    header.stateLabel.textColor = AUIFoundationColor(@"text_weak");
}

- (void)setupLoadMoreFooter
{
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreMessage)];
    footer.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"videoFlowPage_footerRefresh");
    self.collectionView.mj_footer = footer;
    [footer setRefreshingTitleHidden:YES];
    [footer setTitle:AUIVideoFlowString(@"Home_LoadMore_NoData") forState:MJRefreshStateNoMoreData];
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    footer.stateLabel.font = [UIFont systemFontOfSize:14.0f];
    footer.stateLabel.textColor = AUIFoundationColor(@"text_weak");
    [footer loadingView].activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.items.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s",__func__);
    AUIVideoFlowCardCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"defaultCell" forIndexPath:indexPath];
    cell.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"videoFlowPage_defaultCell");
    cell.delegate = self;
    AlivcPlayerVideo *item = [self.items objectAtIndex:indexPath.row];
    cell.item = item;
    
    if ([AlivcPlayerManager manager].currentUuid) {
        UIView *view = [AlivcPlayerManager manager].playContainView;
        if ([item.uuid.UUIDString isEqualToString: [AlivcPlayerManager manager].currentUuid] ) {
            
            AUIVideoFlowCardCell *cardCell = (AUIVideoFlowCardCell*)cell;
            if (view.superview != cardCell.videoContainer) {
                [cardCell.videoContainer addSubview:view];
                self.currentPlayCell = cardCell;
            }
        } else {
            if (view.superview == cell.videoContainer) {
                [view removeFromSuperview];
                self.currentPlayCell = nil;
            }
        }
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 设计稿：在宽为375的手机屏幕上，宽度为375-12*2=351，封面高度为：351*9/16=197，其他高度为67
    CGFloat width = self.collectionView.av_width - 12 * 2;
    return CGSizeMake(width, width* 9 / 16.0 + 67);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 8.0f;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(self.collectionView.av_width - 12 * 2, 16.0f);
}


- (void)refreshMessage
{
    if ([self.collectionView.mj_footer isRefreshing])
    {
        [self.collectionView.mj_header endRefreshing];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    AlivcPlayerWebApiService *service = [AlivcPlayerWebApiService new];
    service.retainWhenResume = YES;
    service.requestUrl = [AlivcPlayerServer urlWithPath:[self requestPath]];
    [service resumeWithData:nil withURLParamData:@{@"size":@(5)} completion:^(NSDictionary * _Nullable feedbackData, APWebApiResultCode resultCode, NSString * _Nullable msg) {
                
        [weakSelf.collectionView.mj_header endRefreshing];
        if (resultCode == APWebApiResCodeSucceed) {
            NSArray *newItems = [weakSelf parseVideoItems:feedbackData];
            [weakSelf.items removeAllObjects];
            [weakSelf.items addObjectsFromArray:newItems];
            [weakSelf.collectionView reloadData];
            
            [weakSelf addVidToPlayer];
            [weakSelf delayAutoPlay];
            
            if (weakSelf.items.count > 0) {
                [weakSelf hideEmptyView];
                weakSelf.collectionView.mj_footer.hidden = NO;
                [weakSelf.collectionView.mj_footer resetNoMoreData];
            }
            else {
                [weakSelf showEmptyView:AUIVideoFlowString(@"Home_Refresh_Empty")];
                weakSelf.collectionView.mj_footer.hidden = YES;
            }
        }
        else {
            if (weakSelf.items.count > 0) {
                [AVToastView show:AUIVideoFlowString(@"Home_Refresh_Failed") view:weakSelf.view position:AVToastViewPositionMid];
                weakSelf.collectionView.mj_footer.hidden = NO;
            }
            else {
                [weakSelf showEmptyView:AUIVideoFlowString(@"Home_Refresh_Failed")];
                weakSelf.collectionView.mj_footer.hidden = YES;
            }
        }
    }];
}

- (void)loadMoreMessage
{
    if ([self.collectionView.mj_header isRefreshing])
    {
        [self.collectionView.mj_footer endRefreshing];
        return;
    }
    
    if (self.items.count == 0) {
        [self.collectionView.mj_footer endRefreshing];
        return;
    }

    __weak typeof(self) weakSelf = self;
    AlivcPlayerWebApiService *service = [AlivcPlayerWebApiService new];
    service.retainWhenResume = YES;
    service.requestUrl = [AlivcPlayerServer urlWithPath:[self requestPath]];
    [service resumeWithData:nil withURLParamData:@{@"size":@(5), @"cursor":@(self.items.lastObject.cursor)} completion:^(NSDictionary * _Nullable feedbackData, APWebApiResultCode resultCode, NSString * _Nullable msg) {
        
        [weakSelf.collectionView.mj_footer endRefreshing];
        if (resultCode == APWebApiResCodeSucceed) {
            NSArray *newItems = [weakSelf parseVideoItems:feedbackData];
            if (newItems.count == 0) {
                [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
            }
            [weakSelf.items addObjectsFromArray:newItems];
            [weakSelf.collectionView reloadData];
            [weakSelf addVidToPlayer];
            [weakSelf delayAutoPlay];
        }
        else {
            [AVToastView show:AUIVideoFlowString(@"Home_LoadMore_Failed") view:weakSelf.view position:AVToastViewPositionMid];
        }
    }];
}

- (NSString *)requestPath {
    return  @"/api/vod/getVodRecommendVideoList";
}

- (NSArray<AlivcPlayerVideo *> *)parseVideoItems:(NSDictionary *)dict {
    NSMutableArray *ret = [NSMutableArray array];
    NSArray<NSDictionary *> *infos = [dict av_dictArrayValueForKey:@"videoList"];
    [infos enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [ret addObject:[[AlivcPlayerVideo alloc] initWithDict:obj]];
    }];
    return ret;
}

- (void)showEmptyView:(NSString *)text {
    if (!self.emptyLabel) {
        self.emptyLabel = [UILabel new];
        self.emptyLabel.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"videoFlowPage_emptyLabel");
        self.emptyLabel.text = text;
        self.emptyLabel.font = AVGetRegularFont(16);
        self.emptyLabel.textColor = APGetColor(APColorTypeFg2);
        self.emptyLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.emptyLabel];
        [self.emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.equalTo(self.contentView);
        }];
    }
    self.emptyLabel.text = text;
    self.emptyLabel.hidden = NO;
}

- (void)hideEmptyView {
    self.emptyLabel.hidden = YES;
}

#pragma mark - AUIVideoFlowCardCellDelegate

- (void)homeCardCellDetailClick:(AUIVideoFlowCardCell *)cell
{
    [self showDetailViewControllerWithCell:cell seletedTab:0];
}

- (void)homeCardCellDidClickCommentButton:(AUIVideoFlowCardCell *)cell
{
    [self showDetailViewControllerWithCell:cell seletedTab:1];
}

- (void)showDetailViewControllerWithCell:(AUIVideoFlowCardCell *)cell seletedTab:(NSInteger)tab
{
    AUIPlayerDetailViewController *detailVC = [[AUIPlayerDetailViewController alloc] init];
    detailVC.item = cell.item;
    detailVC.recommendList = self.items;
    [self.navigationController pushViewController:detailVC animated:YES];
    self.currentPlayCell = cell;
    [cell.videoContainer addSubview:[AlivcPlayerManager manager].playContainView];
    [AlivcPlayerManager manager].playContainView.frame = cell.videoContainer.bounds;
    [AlivcPlayerManager manager].pageEventJump = AlivcPlayerPageEventJumpFlowToDetailPage;
}

- (void)addVidToPlayer
{
    [[AlivcPlayerManager manager] clear];
    
    [self.items enumerateObjectsUsingBlock:^(AlivcPlayerVideo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[AlivcPlayerManager manager]  addVidSource:obj.videoId uuid:obj.uuid.UUIDString];
    }];
    
}

- (void)delayAutoPlay
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self autoPlay];
    });
}

- (void)homeCardCellPlayButtonClick:(AUIVideoFlowCardCell *)cell
{
    [self playWithCell:cell];
}



- (void)autoPlay
{
    NSArray<NSIndexPath *> *list = self.collectionView.indexPathsForVisibleItems;
    
    if (self.currentPlayCell) {
        
        NSIndexPath *path = [self.collectionView indexPathForCell:self.currentPlayCell];
        
        if ([list containsObject:path]) {
            if ([[AlivcPlayerManager manager].currentUuid isEqualToString:self.currentPlayCell.item.uuid.UUIDString?:@""]) {
                return;
            }
        }
    }
    
    list = [list sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *obj1, NSIndexPath * obj2) {
        return obj1.row > obj2.row;
    }];

    for (NSIndexPath *index in list) {

        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:index];
        CGRect rect = cell.frame;
        rect.origin.y -= self.collectionView.contentOffset.y;


        if (rect.origin.y >= 0) {
            [self playWithCell:(AUIVideoFlowCardCell *)cell];
            break;
        }
    }
}

- (void)playWithCell:(AUIVideoFlowCardCell *)cell
{
    if (![cell isKindOfClass:[AUIVideoFlowCardCell class]]) {
        return;
    }
    
    if (!cell.item.uuid.UUIDString) {
        return;
    }    
    
    [AlivcPlayerManager manager].playContainView.hidden = NO;
    
    UIView *playView = [AlivcPlayerManager manager].playContainView;
    playView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"videoFlowPage_playView");
    [cell.videoContainer addSubview:playView];
    playView.frame = cell.videoContainer.bounds;
    [AlivcPlayerManager manager].recomendVodId = cell.item.vodId;

    if ([self checkNewPlay]) {
        [[AlivcPlayerManager manager] stop];
    }
    
    self.currentPlayCell = cell;
    
    [[AlivcPlayerManager manager] addEventObserver:self];

    if ([[AlivcPlayerManager manager].currentUuid isEqualToString:cell.item.uuid.UUIDString]) {
        if ([AlivcPlayerManager manager].playerStatus == AVPStatusPaused) {
            [[AlivcPlayerManager manager] resume];
        }
        return;
    }
    
    [[AlivcPlayerManager manager] moveToVideoId:cell.item.videoId uuid:cell.item.uuid.UUIDString];
    // [[AlivcPlayerManager manager] clearScreen];
    [AlivcPlayerManager manager].disableVideo = NO;
   
    
}

- (BOOL)checkNewPlay {
    BOOL isNewPlay = YES;
    if (self.currentPlayCell) {
        CGRect rect = self.currentPlayCell.frame;
        rect.origin.y -= self.collectionView.contentOffset.y;
        if (rect.origin.y > 0) {
            isNewPlay = NO;
        }
    }
    return isNewPlay;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.scrollViewDragging = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
{
    NSLog(@"%s:%d",__func__,decelerate);
    if (!decelerate)
    {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidEndDecelerating");

    if (self.scrollViewDragging) {
        self.scrollViewDragging = NO;
        if ([self.collectionView.mj_header isRefreshing] || [self.collectionView.mj_footer isRefreshing]) {
            return;
        }
        //[[AlivcPlayerManager manager] clearScreen];
        [self autoPlay];
    }
}

#pragma mark - AlivcPlayerPluginEventProtocol

- (NSArray<NSNumber *> *)eventList
{
    return @[@(AlivcPlayerEventCenterPlaySceneChanged)];
}

- (void)onReceivedEvent:(AlivcPlayerEventCenterType)eventType userInfo:(NSDictionary *)userInfo
{
    if (eventType == AlivcPlayerEventCenterPlaySceneChanged) {
        [self handlePlayerSuperViewChanged];
    }
}

- (void)handlePlayerSuperViewChanged
{
    [self playVisibleVideoIfNeed];
}

- (void)playVisibleVideoIfNeed
{
    if (self.items.count == 0) {
        return;
    }

    if (self.currentPlayCell) {

        if ([AlivcPlayerManager manager].playContainView.superview == nil ||
            [AlivcPlayerManager manager].playContainView.superview == self.currentPlayCell.videoContainer) {
            [self autoPlay];
        }
    } else {
        [self autoPlay];
    }
}

@end
