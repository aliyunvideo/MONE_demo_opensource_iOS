//
//  AUIPlayerFullScreenPlayViewController.m
//  ApsaraVideo
//
//  Created by Bingo on 2021/7/1.
//

#import "AUIPlayerFullScreenPlayViewController.h"
#import "AlivcPlayerManager.h"
#import "AUIPlayerLandscapeVideoContainer.h"
#import "AlivcPlayerPluginEventProtocol.h"
#import "AlivcPlayerWebApiService.h"
#import "AlivcPlayerServer.h"
#import "AlivcPlayerVideo.h"
#import "AUIPlayerDetailViewController.h"

@interface AUIPlayerFullScreenPlayViewController ()<AlivcPlayerPluginEventProtocol>

@property (nonatomic, strong) AUIPlayerLandscapeVideoContainer *detailVideoContainer;
@property (nonatomic, strong) AlivcPlayerVideo *item;
@property (nonatomic, strong) AVActivityIndicator *indicator;

@end

@implementation AUIPlayerFullScreenPlayViewController

- (instancetype)init {
    if (self = [super init]) {
        [[AlivcPlayerManager manager] clear];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hiddenMenuButton = YES;
    self.headerView.hidden = YES;
    
    [AlivcPlayerManager manager].shouldFlowOrientation = NO;
    [AlivcPlayerManager manager].hideAutoOrientation = NO;
    [AlivcPlayerManager manager].pageEventFrom = AlivcPlayerPageEventFromFullScreenPlayPage;
    
    [[AlivcPlayerManager manager] addEventObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadPlayer];
    self.indicator = [AVActivityIndicator start:self.detailVideoContainer];
    self.indicator.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"fullScreenPage_indicator");
    self.indicator.center = self.detailVideoContainer.center;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [AlivcPlayerManager manager].hideAutoOrientation = NO;
    [AlivcPlayerManager manager].pageEventFrom = AlivcPlayerPageEventFromHomePage;
    if ([AlivcPlayerManager manager].pageEventJump != AlivcPlayerPageEventJumpFullScreenToDetailPage) {
        [[AlivcPlayerManager manager] destroyIncludePlayer:YES];
    }
}

- (AUIPlayerLandscapeVideoContainer *)detailVideoContainer
{
    if (!_detailVideoContainer) {
        UIView *containerView = [AlivcPlayerManager manager].playContainView;
        CGFloat scale = 9.0 / 16.0;
        if (containerView.bounds.size.width > 0) {
            scale = containerView.bounds.size.height / containerView.bounds.size.width;
        }
        CGRect rect = [UIScreen mainScreen].bounds;
        _detailVideoContainer = [[AUIPlayerLandscapeVideoContainer alloc] initWithFrame:rect];
        _detailVideoContainer.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"fullScreenPage_detailVideoContainer");
        _detailVideoContainer.backgroundColor = AUIVideoFlowColor(@"vf_video_bg");
    }
    return _detailVideoContainer;
}

- (void)requestURL:(void (^)(BOOL))completion
{
    __weak typeof(self) weakSelf = self;
    AlivcPlayerWebApiService *service = [AlivcPlayerWebApiService new];
    service.retainWhenResume = YES;
    service.requestUrl = [AlivcPlayerServer urlWithPath:[self requestPath]];
    [service resumeWithData:nil withURLParamData:@{@"size":@(1)} completion:^(NSDictionary * _Nullable feedbackData, APWebApiResultCode resultCode, NSString * _Nullable msg) {
        if (resultCode == APWebApiResCodeSucceed) {
            NSArray *newItems = [weakSelf parseVideoItems:feedbackData];
            if (newItems.count > 0) {
                self.item = newItems.firstObject;
                [[AlivcPlayerManager manager] addVidSource:self.item.videoId uuid:self.item.uuid.UUIDString];
                [[AlivcPlayerManager manager] moveToVideoId:self.item.videoId uuid:self.item.uuid.UUIDString];
                [AlivcPlayerManager manager].disableVideo = NO;
                if (completion) {
                    completion(YES);
                }
            } else {
                if (completion) {
                    completion(NO);
                }
            }
        } else {
            if (completion) {
                completion(NO);
            }
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

- (void)loadPlayer {
    [self.view addSubview:self.detailVideoContainer];
    
    UIView *playView = [AlivcPlayerManager manager].playContainView;
    [self.detailVideoContainer addSubview:playView];
    [AlivcPlayerManager manager].recomendVodId = self.item.vodId;
    playView.frame = self.detailVideoContainer.bounds;
}

#pragma mark - AlivcPlayerPluginEventProtocol

- (NSArray<NSNumber *> *)eventList
{
    return @[@(AlivcPlayerEventCenterTypePlayerEventType),
             @(AlivcPlayerEventCenterTypePlayerEventAVPStatus),
             @(AlivcPlayerEventCenterTypeFullScreenPlayToDetailPage)];
}

- (void)onReceivedEvent:(AlivcPlayerEventCenterType)eventType userInfo:(NSDictionary *)userInfo
{
    if (eventType == AlivcPlayerEventCenterTypePlayerEventType) {
        AVPEventType type = [[userInfo objectForKey:@"eventType"] integerValue];
        if (type == AVPEventFirstRenderedStart) {
            [AVActivityIndicator stop:self.indicator];
            [[AlivcPlayerManager manager] setCurrentOrientationForceDisPatch:AlivcPlayerEventCenterTypeOrientationLandsacpeLeft];
        }
    } else if (eventType == AlivcPlayerEventCenterTypePlayerEventAVPStatus) {
        AVPStatus status = [[userInfo objectForKey:@"status"] integerValue];
        if (status == AVPStatusError) {
            [AVActivityIndicator stop:self.indicator];
            [AVToastView show:@"加载失败" view:self.view position:AVToastViewPositionMid];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }
    } else if (eventType == AlivcPlayerEventCenterTypeFullScreenPlayToDetailPage) {
        [[AlivcPlayerManager manager] setCurrentOrientationForceDisPatch:AlivcPlayerEventCenterTypeOrientationPortrait];
        [AlivcPlayerManager manager].pageEventJump = AlivcPlayerPageEventJumpFullScreenToDetailPage;
        
        AUIPlayerDetailViewController *detailVC = [[AUIPlayerDetailViewController alloc] init];
        detailVC.item = self.item;
        
        if (@available(iOS 16.1, *)) {
            AVNavigationController *presentingViewController = (AVNavigationController *)self.presentingViewController;
            [self dismissViewControllerAnimated:NO completion:nil];
            [presentingViewController pushViewController:detailVC animated:NO];
        } else {
            __block AVNavigationController *presentingViewController = (AVNavigationController *)self.presentingViewController;
            [self dismissViewControllerAnimated:NO completion:^{
                [presentingViewController pushViewController:detailVC animated:YES];
            }];
        }
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

@end
