//
//  AUIPlayerDetailViewController.m
//  ApsaraVideo
//
//  Created by Bingo on 2021/7/1.
//

#import "AUIPlayerDetailViewController.h"
#import "AlivcPlayerFoundation.h"
#import "AlivcPlayerManager.h"
#import "AUIPlayerDetailVideoContainer.h"
#import "AlivcPlayerWebApiService.h"
#import "AlivcPlayerServer.h"
#import "AlivcPlayerVideo.h"
#import "AlivcPlayerEpisodeModel.h"
#import "AUIPlayerVideoDetailViewCell.h"
#import "AUIPlayerBackScrollView.h"


typedef NS_ENUM(NSUInteger, AlivcPlayerVideoDetailSectionType) {
    AlivcPlayerVideoDetailSectionTypeUser,
    AlivcPlayerVideoDetailSectionTypeRecommend,
};

@interface AUIPlayerDetailViewController ()<UITableViewDelegate, UITableViewDataSource,AlivcPlayerPluginEventProtocol,UIGestureRecognizerDelegate>
@property (nonatomic, weak) UIView *lastVideoContainer;

@property (nonatomic, strong) AUIPlayerDetailVideoContainer *detailVideoContainer;
@property (nonatomic, copy)  NSArray<AlivcPlayerEpisodeModel *>* dataList;


@property (nonatomic, strong)  UITableView *tableView;

@property (nonatomic, strong) UILabel *recommendTitleView;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, weak) UICollectionView *seletedArtCollectionView;


@end

@implementation AUIPlayerDetailViewController

- (instancetype)init {
    if (self = [super init]) {
        [AlivcPlayerManager manager].shouldFlowOrientation = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleView.text = AUIVideoFlowString(@"视频详情");
    self.hiddenMenuButton = YES;
    
    [self.contentView addSubview:self.detailVideoContainer];

    [self.contentView addSubview:self.scrollView];
    [self.scrollView addSubview:self.tableView];
    
    [AlivcPlayerManager manager].shouldFlowOrientation = YES;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [self refreshMessage];
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[AUIPlayerBackScrollView alloc] init];
        _scrollView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"playerDetailPage_scrollView");
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        
        CGFloat top = self.detailVideoContainer.av_bottom;
        _scrollView.frame = CGRectMake(0, top, self.contentView.av_width, self.contentView.av_height - top);
        _scrollView.contentSize = CGSizeMake(self.contentView.av_width, _scrollView.av_height);
        
    }
    return _scrollView;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.scrollView.bounds style:UITableViewStyleGrouped];
        _tableView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"playerDetailPage_tableView");
        _tableView.backgroundColor = AUIFoundationColor(@"bg_weak");
        
        if (@available(iOS 14.0, *)) {
            UIBackgroundConfiguration *config = [UIBackgroundConfiguration clearConfiguration];
            UITableViewCell.appearance.backgroundConfiguration = config;
        }
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 0.f;
        _tableView.estimatedSectionFooterHeight = 0.f;
        _tableView.estimatedSectionFooterHeight = 0.f;

        _tableView.tableFooterView = [UIView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView registerClass:AlivcPlayerVideoDetailViewUserInfoCell.class forCellReuseIdentifier:@"AlivcPlayerVideoDetailViewUserInfoCell"];
        [_tableView registerClass:AlivcPlayerVideoDetailViewRecommendCell.class forCellReuseIdentifier:@"AlivcPlayerVideoDetailViewRecommendCell"];
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"UITableViewCell"];
    }
    
    return _tableView;
}

- (AUIPlayerDetailVideoContainer *)detailVideoContainer
{
    if (!_detailVideoContainer) {
        //UIView *containerView = [AlivcPlayerManager manager].playContainView;
        CGFloat scale = 9.0 / 16.0;
//        if (containerView.bounds.size.width > 0) {
//            scale = containerView.bounds.size.height / containerView.bounds.size.width;
//        }
        CGRect rect = CGRectMake(0, 0, self.contentView.av_width, self.contentView.av_width * scale);
        _detailVideoContainer = [[AUIPlayerDetailVideoContainer alloc] initWithFrame:rect];
        _detailVideoContainer.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"playerDetailPage_detailVideoContainer");
        _detailVideoContainer.backgroundColor = AUIVideoFlowColor(@"vf_video_bg");
    }
    return _detailVideoContainer;
}

- (NSString *)requestPath {
    return  @"/api/vod/getVodDetail";
}

- (void)refreshMessage
{
 
    __weak typeof(self) weakSelf = self;
    AlivcPlayerWebApiService *service = [AlivcPlayerWebApiService new];
    service.retainWhenResume = YES;
    service.requestUrl = [AlivcPlayerServer urlWithPath:[self requestPath]];
    [service resumeWithData:nil withURLParamData:@{@"vodId":@(self.item.vodId)} completion:^(NSDictionary * _Nullable feedbackData, APWebApiResultCode resultCode, NSString * _Nullable msg) {
                
       
        if (resultCode == APWebApiResCodeSucceed) {
            [weakSelf parseData:feedbackData];
        }
     
    }];
}

- (void)parseData:(NSDictionary *)feedbackData
{
    NSArray *episodes = [feedbackData objectForKey:@"episodes"];
    if ([episodes isKindOfClass:[NSArray class]]) {
        NSMutableArray *list = [NSMutableArray array];
        for (NSDictionary *dict in episodes) {
            if ([dict isKindOfClass:[NSDictionary class]]) {
                AlivcPlayerEpisodeModel *model = [[AlivcPlayerEpisodeModel alloc] initWithDict:dict];
                [list addObject:model];
            }
        }
        self.dataList = list;
        [self addVidToPlayer];
        [self.tableView reloadData];
    }
}

- (void)addVidToPlayer
{
    
    NSString *currentUUid = [AlivcPlayerManager manager].currentUuid;
    NSString *currentVideoId = [AlivcPlayerManager manager].currentVideoId;

    NSMutableArray *list = [NSMutableArray array];
    [self.dataList enumerateObjectsUsingBlock:^(AlivcPlayerVideo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.videoId && [currentVideoId isEqualToString:obj.videoId]) {
            obj.uuid = [[NSUUID alloc] initWithUUIDString:currentUUid];
        }
        if (obj.videoId && obj.uuid.UUIDString) {
            NSDictionary *dict = [NSDictionary dictionaryWithObject:obj.videoId forKey:obj.uuid.UUIDString];
            
            [list addObject:dict];
        }
    }];
    
    [AlivcPlayerManager manager].playerSourceList = list;
}


- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    [AlivcPlayerManager manager].pageEventFrom = AlivcPlayerPageEventFromDetailPage;
    
    UIView *containerView = [AlivcPlayerManager manager].playContainView;
    containerView.hidden = NO;
    self.lastVideoContainer = containerView.superview;
    [self.detailVideoContainer addSubview:containerView];
    containerView.frame = self.detailVideoContainer.bounds;
    
    if (self.item.videoId && self.item.uuid.UUIDString) {
        
        if (![[AlivcPlayerManager manager].currentVideoId isEqualToString:self.item.videoId]) {
            [AlivcPlayerManager manager].disableVideo = NO;
            [[AlivcPlayerManager manager] moveToVideoId:self.item.videoId uuid:self.item.uuid.UUIDString];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    UIView *containerView = [AlivcPlayerManager manager].playContainView;
    [self.lastVideoContainer addSubview:containerView];
    containerView.frame = self.lastVideoContainer.bounds;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if ([AlivcPlayerManager manager].pageEventJump == AlivcPlayerPageEventJumpFullScreenToDetailPage) {
        [AlivcPlayerManager manager].backgroudModeEnabled = NO;
    }
    
    [AlivcPlayerManager manager].shouldFlowOrientation = NO;
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    if ([AlivcPlayerManager manager].pageEventJump == AlivcPlayerPageEventJumpFullScreenToDetailPage) {
        [[AlivcPlayerManager manager] destroyIncludePlayer:YES];
    }
    [AlivcPlayerManager manager].pageEventJump = AlivcPlayerPageEventJumpNone;
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.recommendList.count > 0) {
        return 2;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case AlivcPlayerVideoDetailSectionTypeRecommend:
            return self.recommendList.count;
            break;
        default:
            return 1;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case AlivcPlayerVideoDetailSectionTypeUser:
        {
            AlivcPlayerVideoDetailViewUserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlivcPlayerVideoDetailViewUserInfoCell" forIndexPath:indexPath];
            cell.item = self.item;
            return cell;
        }
        case AlivcPlayerVideoDetailSectionTypeRecommend:
        {
            AlivcPlayerVideoDetailViewRecommendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlivcPlayerVideoDetailViewRecommendCell" forIndexPath:indexPath];
            
            cell.item = [self.recommendList objectAtIndex:indexPath.row];
            return cell;
        }
    }
    return [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case AlivcPlayerVideoDetailSectionTypeUser:
        {
            return [AlivcPlayerVideoDetailViewUserInfoCell getCellHeight];
        }
        case AlivcPlayerVideoDetailSectionTypeRecommend:
        {
            return 90.f;
        }
    }
    
    return 0.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case AlivcPlayerVideoDetailSectionTypeRecommend:
      
            return 44.f;
        
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case AlivcPlayerVideoDetailSectionTypeRecommend:
        {
            if (self.recommendTitleView == nil) {
                self.recommendTitleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.av_width - 16, 44)];
                self.recommendTitleView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"playerDetailPage_recommendTitleView");
                self.recommendTitleView.text  = [@"   " stringByAppendingString:AUIVideoFlowString(@"相关推荐")];
                self.recommendTitleView.textColor = AUIFoundationColor(@"text_strong");
                self.recommendTitleView.font = AVGetMediumFont(14);

            }
            return self.recommendTitleView;
        }
    }
    return nil;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == AlivcPlayerVideoDetailSectionTypeRecommend) {
        
        if (self.recommendList.count > indexPath.row) {
            AlivcPlayerVideo *item = [self.recommendList objectAtIndex:indexPath.row];
            
            if (item.uuid.UUIDString &&[[AlivcPlayerManager manager].currentUuid isEqual:item.uuid.UUIDString]) {
                return;
            }
            self.item = item;
            [[AlivcPlayerManager manager] moveToVideoId:item.videoId uuid:item.uuid.UUIDString];
            [AlivcPlayerManager manager].disableVideo = NO;
            [self.tableView reloadData];
        }
    }
}

#pragma mark - scrollview

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    ;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.tableView.panGestureRecognizer) {
        if ([gestureRecognizer locationInView:gestureRecognizer.view].x <= 30) {
            return NO;
        }
    }
    return YES;
}
@end
