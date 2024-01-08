//
//  AUILiveLinkMicAudienceLinkViewController.m
//  AUILiveLinkMic
//
//  Created by ISS013602000846 on 2022/8/3.
//

#import "AUILiveLinkMicAudienceLinkViewController.h"
#import "AUILiveInteractiveParamManager.h"
#import "AUILiveIntercativeBgStatusView.h"
#import "AUILiveIntercativeLinkCustomerView.h"
#import "AUILiveInputNumberAlert.h"
#import "AUILiveExternMainStreamManager.h"
#import "AUILiveBeautyController.h"

typedef NS_ENUM(NSInteger, AUILiveLinkMicAudiencePushStatus) {
    AUILiveLinkMicAudiencePushStatusNone = 0,
    AUILiveLinkMicAudiencePushStatusPushing,
    AUILiveLinkMicAudiencePushStatusPause,
    AUILiveLinkMicAudiencePushStatusError,
    AUILiveLinkMicAudiencePushStatusStop,
};

typedef NS_ENUM(NSInteger, AUILiveLinkMicAnchorPullStatus) {
    AUILiveLinkMicAnchorPullStatusNone = 0,
    AUILiveLinkMicAnchorPullStatusPulling,
    AUILiveLinkMicAnchorPullStatusPause,
    AUILiveLinkMicAnchorPullStatusError,
    AUILiveLinkMicAnchorPullStatusStop,
};

@interface AUILiveLinkMicAudienceLinkViewController ()<AVPDelegate, AlivcLivePusherInfoDelegate, AlivcLivePusherErrorDelegate, AlivcLivePusherNetworkDelegate, AlivcLivePusherCustomFilterDelegate, AlivcLivePusherCustomDetectorDelegate, AliLivePlayerDelegate, AlivcLiveBaseObserver>

@property (nonatomic, strong) AUILiveInteractiveParamManager *paramManager;

@property (nonatomic, strong) AUILiveURLUtils *cdnPlay;
@property (nonatomic, strong) AUILiveURLUtils *rtcPush;
@property (nonatomic, strong) AUILiveURLUtils *rtcPlay;

@property (nonatomic, strong) AliPlayer *cdnPlayer;

@property (nonatomic, strong) AlivcLivePushConfig *rtcPushConfig;
@property (nonatomic, strong) AlivcLivePusher *rtcPusher;

@property (nonatomic, strong) AlivcLivePlayConfig *rtcPlayConfig;
@property (nonatomic, strong) AlivcLivePlayer *rtcPlayer;

@property (nonatomic, strong) AUILiveIntercativeBgStatusView *bgStatusView;
@property (nonatomic, strong) UIView *playerView;

@property (nonatomic, strong) AUILiveIntercativeLinkCustomerView *pusherView;
@property (nonatomic, strong) UILabel *pusherStatusLabel;
@property (nonatomic, strong) UIButton *pusherActionButton;

@property (nonatomic, strong) UIButton *beautyButton;

@property (nonatomic, assign) AUILiveLinkMicAudiencePushStatus audiencePushStatus;
@property (nonatomic, assign) AUILiveLinkMicAnchorPullStatus anchorPullStatus;

@property (nonatomic, assign) BOOL switchRTCPull;

@property (nonatomic, strong) AUILiveExternMainStreamManager *userMainStreamManager;

@end

@implementation AUILiveLinkMicAudienceLinkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.backButton setImage:AUILiveCommonImage(@"ic_push_close") forState:UIControlStateNormal];
    self.titleView.text = self.rtcConfig.streamName;
    
    [self.menuButton setImage:AUILiveCommonImage(@"ic_camera") forState:UIControlStateNormal];
    [self.menuButton addTarget:self action:@selector(publisherSwitchCamera) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.image = AUILiveCommonImage(@"camera_push_bgm_bgImage");
    [self.view addSubview:imageView];
    
    [self registerSDK];
    
    [self setupCDNPlayer];
    [self setupRTCPusher];
    [self setupRTCPlayer];
    [self setupContent];
    // [self addNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.paramManager.beautyOn) {
        [[AUILiveBeautyController sharedInstance] setupBeautyControllerUIWithView:self.view];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showAnchorUserId];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self destory];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)showAnchorUserId {
    __weak typeof(self) weakSelf = self;
    [AUILiveInputNumberAlert show:@[AUILiveCommonString(@"请输入主播的用户ID")] view:self.view maxNumber:64 inputAction:^(BOOL ok, NSArray<NSString *> * _Nonnull inputs) {
        __strong typeof(self) strongSelf = weakSelf;
        if (ok) {
            if (inputs.firstObject == strongSelf.rtcPush.userId) {
                [AVToastView show:AUILiveLinkMicString(@"主播和观众ID不能一致") view:strongSelf.view position:AVToastViewPositionMid];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    __weak typeof(self) weakSelf = self;
                    [weakSelf showAnchorUserId];
                });
            } else {
                strongSelf.cdnPlay.userId = inputs.firstObject;
                strongSelf.rtcPlay.userId = inputs.firstObject;
                [self startCDNPull];
                self.pusherView.hidden = NO;
                self.pusherActionButton.hidden = NO;
                [UIApplication sharedApplication].idleTimerDisabled = YES;
            }
        } else {
            [super goBack];
        }
    }];
}

- (void)goBack {
    [AVAlertController showWithTitle:nil message:AUILiveCommonString(@"确认要退出房间吗？") needCancel:YES onCompleted:^(BOOL isCanced) {
        if (!isCanced) {
            [super goBack];
        }
    }];
}

- (void)registerSDK {
    [AlivcLiveBase setObserver:self];
    NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    [AlivcLiveBase setLogPath:cacheDirectory maxPartFileSizeInKB:100*1024*1024];
    [AlivcLiveBase registerSDK];
    
    [self loadAliPlayerLicense];
}

- (void)loadAliPlayerLicense {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [AliPrivateService initLicenseService];
    });
    
    // 开启播放器日志
    [AliPlayer setEnableLog:YES];
    [AliPlayer setLogCallbackInfo:LOG_LEVEL_TRACE callbackBlock:^(AVPLogLevel logLevel,NSString* strLog){
        [AliveLiveDemoUtil writeLogMessageToLocationFile:strLog isCover:NO];
    }];
}

- (void)setupContent {
    [self.view addSubview:self.bgStatusView];
    [self.view addSubview:self.playerView];
    
    [self.view addSubview:self.pusherView];
    self.pusherView.hidden = YES;
    
    [self.view addSubview:self.pusherStatusLabel];
    self.pusherStatusLabel.hidden = YES;

    [self.view addSubview:self.pusherActionButton];
    self.pusherActionButton.hidden = YES;
    
    if (self.paramManager.beautyOn) {
        [self.view addSubview:self.beautyButton];
    }
    self.beautyButton.hidden = YES;
    
    [self.view bringSubviewToFront:self.headerView];
    [self.view bringSubviewToFront:self.pusherView];
    [self.view bringSubviewToFront:self.pusherStatusLabel];
    [self.view bringSubviewToFront:self.pusherActionButton];
    [self.view bringSubviewToFront:self.beautyButton];
}

- (void)setupCDNPlayer {
    self.cdnPlayer = [[AliPlayer alloc] init];
    self.cdnPlayer.delegate = self;
    self.cdnPlayer.autoPlay = YES;
    //针对纯音频场景需要设置启播buffer，加快首桢播放
    if(self.paramManager.audioOnly)
    {
        AVPConfig *config = [self.cdnPlayer getConfig];
        config.enableStrictFlvHeader = YES; //纯音频 或 纯视频 的flv 需要设置 以加快起播
        config.startBufferDuration = 1000; //起播缓存，越大起播越稳定，但会影响起播时间，可酌情设置
        config.highBufferDuration = 500;//卡顿恢复需要的缓存，网络不好的情况可以设置大一些，当前纯音频设置500还好，视频的话建议用默认值3000.
        [self.cdnPlayer setConfig:config];
    }
}

- (void)setupRTCPusher {
    self.rtcPusher = [[AlivcLivePusher alloc] initWithConfig:self.rtcPushConfig];
    if (!self.rtcPusher) {
        [AVToastView show:AUILiveCommonString(@"初始化推流失败") view:self.view position:AVToastViewPositionMid];
        return;
    }
    
    [self.rtcPusher setInfoDelegate:self];
    [self.rtcPusher setErrorDelegate:self];
    [self.rtcPusher setNetworkDelegate:self];
    [self.rtcPusher setCustomFilterDelegate:self];
    [self.rtcPusher setCustomDetectorDelegate:self];
}

- (void)setupRTCPlayer {
    self.rtcPlayer = [[AlivcLivePlayer alloc] init];
    [self.rtcPlayer setLivePlayerDelegate:self];
}

- (void)changeCustomerAction:(UIButton *)sender {
    if (self.audiencePushStatus == AUILiveLinkMicAudiencePushStatusPushing ||
        self.audiencePushStatus == AUILiveLinkMicAudiencePushStatusError) {
        __weak typeof(self) weakSelf = self;
        [AVAlertController showWithTitle:nil message:AUILiveLinkMicString(@"确认要结束本次连麦吗？") needCancel:YES onCompleted:^(BOOL isCanced) {
            __strong typeof(self) strongSelf = weakSelf;
            if (!isCanced) {
                if ([strongSelf stopRTCPush]) {
                    self.beautyButton.hidden = YES;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [strongSelf stopRTCPushPreview];
                        
                        if (self.paramManager.isUserMainStream) {
                            [self.userMainStreamManager releaseUserStream];
                        }
                    });
                }
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [strongSelf stopRTCPlay];
                });
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [strongSelf startCDNPull];
                });
            }
        }];
    } else {
        [self stopCDNPull];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([self startRTCPushPreview]) {
                if (self.paramManager.isUserMainStream) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.userMainStreamManager addUserStream];
                    });
                }
                
                [self startRTCPush];
                self.beautyButton.hidden = NO;
            }
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startRTCPlay];
        });
    }
}

#pragma mark -- CDN拉流
/**
 开始CDN拉流
 */
- (void)startCDNPull {
    [self stopCDNPull];
    
    NSString *cdnPlayURL = [self.cdnPlay getCDNURL];
    if (cdnPlayURL == nil || cdnPlayURL.length == 0) {
        [AVToastView show:AUILiveCommonString(@"请输入拉流地址") view:self.view position:AVToastViewPositionMid];
        return;
    }

    self.cdnPlayer.playerView = self.playerView;
    AVPUrlSource *source = [[AVPUrlSource alloc] urlWithString:cdnPlayURL];
    [self.cdnPlayer setUrlSource:source];
    [self.cdnPlayer prepare];
    self.anchorPullStatus = AUILiveLinkMicAnchorPullStatusPulling;
    
    self.switchRTCPull = NO;
}

/**
 停止CDN拉流
 */
- (void)stopCDNPull {
    [self.cdnPlayer stop];
    [self.cdnPlayer clearScreen];
    self.cdnPlayer.playerView = nil;
    self.anchorPullStatus = AUILiveLinkMicAnchorPullStatusStop;
}

/**
 暂停CDN拉流
 */
- (void)pauseCDNPull {
    if (self.anchorPullStatus == AUILiveLinkMicAnchorPullStatusPulling) {
        [self.cdnPlayer pause];
        self.anchorPullStatus = AUILiveLinkMicAnchorPullStatusPause;
    }
}

/**
 恢复CDN拉流
 */
- (void)restartCDNPull {
    if (self.anchorPullStatus == AUILiveLinkMicAnchorPullStatusPause) {
        [self.cdnPlayer start];
        self.anchorPullStatus = AUILiveLinkMicAnchorPullStatusPulling;
    }
}

- (void)pressBeautyButton:(UIButton *)sender {
    if (self.paramManager.beautyOn) {
        [[AUILiveBeautyController sharedInstance] showPanel:YES];
    }
}

#pragma mark -- RTC推流
/**
 开始RTC预览
 */
- (BOOL)startRTCPushPreview {
    if (!self.rtcPusher) {
        [AVToastView show:@"Start Preview Error" view:self.view position:AVToastViewPositionMid];
        return NO;
    }
    
    // 使用同步接口
    int ret = [self.rtcPusher startPreview:[self.pusherView getPlayerShow]];
    if (ret != 0) {
        NSString *errMsg = [NSString stringWithFormat:@"Start Preview Error:%d", ret];
        [AVToastView show:errMsg view:self.view position:AVToastViewPositionMid];
        return NO;
    } else {
        return YES;
    }
}

/**
 停止RTC预览
 */
- (BOOL)stopRTCPushPreview {
    if (!self.rtcPusher) {
        return YES;
    }
    int ret = [self.rtcPusher stopPreview];
    if (ret == 0) {
        self.audiencePushStatus = AUILiveLinkMicAudiencePushStatusStop;
    }
    return ret == 0;
}

/**
 开始RTC推流
 */
- (BOOL)startRTCPush {
    NSString *rtcPushURL = [self.rtcPush getRTCURL];
    if (!rtcPushURL || rtcPushURL.length == 0 || !self.rtcPusher) {
        [AVToastView show:@"Start Push Error" view:self.view position:AVToastViewPositionMid];
        return NO;
    }

    // 使用同步接口
    int ret = [self.rtcPusher startPushWithURL:rtcPushURL];
    if (ret == 0) {
        self.audiencePushStatus = AUILiveLinkMicAudiencePushStatusPushing;
        return YES;
    } else {
        NSString *errMsg = [NSString stringWithFormat:@"Start Push Error:%d", ret];
        [AVToastView show:errMsg view:self.view position:AVToastViewPositionMid];
        return NO;
    }
}

/**
 停止RTC推流
 */
- (BOOL)stopRTCPush {
    if (!self.rtcPusher) {
        self.audiencePushStatus = AUILiveLinkMicAudiencePushStatusStop;
        return YES;
    }
    
    if ([self.rtcPusher isPushing]) {
        int ret = [self.rtcPusher stopPush];
        self.audiencePushStatus = AUILiveLinkMicAudiencePushStatusStop;
        return ret == 0;
    } else {
        self.audiencePushStatus = AUILiveLinkMicAudiencePushStatusStop;
        return YES;
    }
}

/**
 重新RTC推流
 */
- (BOOL)restartRTCPush {
    NSString *rtcPushURL = [self.rtcPush getRTCURL];
    if (!rtcPushURL || rtcPushURL.length == 0 || !self.rtcPusher) {
        [AVToastView show:@"Restart Push Error" view:self.view position:AVToastViewPositionMid];
        if (self.audiencePushStatus == AUILiveLinkMicAudiencePushStatusPause) {
            self.audiencePushStatus = AUILiveLinkMicAudiencePushStatusError;
        }
        return NO;
    }
    
    int ret = [self.rtcPusher startPushWithURLAsync:rtcPushURL];
    if (ret == 0) {
        self.audiencePushStatus = AUILiveLinkMicAudiencePushStatusPushing;
        return YES;
    } else {
        NSString *errMsg = [NSString stringWithFormat:@"Restart Push Error:%d", ret];
        [AVToastView show:errMsg view:self.view position:AVToastViewPositionMid];
        if (self.audiencePushStatus == AUILiveLinkMicAudiencePushStatusPause) {
            self.audiencePushStatus = AUILiveLinkMicAudiencePushStatusError;
        }
        return NO;
    }
}

#pragma mark -- RTC拉流
/**
 开始RTC拉流
 */
- (void)startRTCPlay {
    NSString *rtcPlayURL = [self.rtcPlay getRTCURL];
    if (rtcPlayURL == nil || rtcPlayURL.length == 0) {
        [AVToastView show:AUILiveCommonString(@"请输入拉流地址") view:self.view position:AVToastViewPositionMid];
        if (self.anchorPullStatus == AUILiveLinkMicAnchorPullStatusPause) {
            self.anchorPullStatus = AUILiveLinkMicAnchorPullStatusError;
        }
        return;
    }
    
    int ret = [self.rtcPlayer setPlayView:self.playerView playCofig:self.rtcPlayConfig];
    if (ret != 0) {
        [AVToastView show:AUILiveCommonString(@"初始化拉流失败") view:self.view position:AVToastViewPositionMid];
        if (self.anchorPullStatus == AUILiveLinkMicAnchorPullStatusPause) {
            self.anchorPullStatus = AUILiveLinkMicAnchorPullStatusError;
        }
    } else {
        [self.rtcPlayer startPlayWithURL:rtcPlayURL];
        self.anchorPullStatus = AUILiveLinkMicAnchorPullStatusPulling;
    }
}

/**
 停止RTC拉流
 */
- (void)stopRTCPlay {
    [self.rtcPlayer stopPlay];
    self.anchorPullStatus = AUILiveLinkMicAnchorPullStatusStop;
}

/**
 切换摄像头
 */
- (void)publisherSwitchCamera {
    if (self.rtcPusher) {
        int ret = [self.rtcPusher switchCamera];
        if (ret != 0) {
            [AVToastView show:AUILiveCommonString(@"切换摄像头失败") view:self.view position:AVToastViewPositionMid];
            NSLog(@"switchCamera error:%d", ret);
        }
    } else {
        [AVToastView show:AUILiveCommonString(@"推流没有初始化，无法调用摄像头") view:self.view position:AVToastViewPositionMid];
    }
}

- (void)setAudiencePushStatus:(AUILiveLinkMicAudiencePushStatus)audiencePushStatus {
    _audiencePushStatus = audiencePushStatus;
    if (audiencePushStatus == AUILiveLinkMicAudiencePushStatusPushing ||
        audiencePushStatus == AUILiveLinkMicAudiencePushStatusPause ||
        audiencePushStatus == AUILiveLinkMicAudiencePushStatusError) {
        self.pusherView.customerStatus = AUILiveLinkCustomerStatusPulling;
    } else {
        self.pusherView.customerStatus = AUILiveLinkCustomerStatusNone;
    }
    
    if (audiencePushStatus == AUILiveLinkMicAudiencePushStatusPushing ||
        audiencePushStatus == AUILiveLinkMicAudiencePushStatusPause ||
        audiencePushStatus == AUILiveLinkMicAudiencePushStatusError) {
        self.pusherStatusLabel.hidden = NO;
        self.pusherStatusLabel.text = AUILiveLinkMicString(@"正在连麦");

        self.pusherActionButton.backgroundColor = AUILiveCommonColor(@"ir_button_pulling");
        [self.pusherActionButton setTitle:AUILiveLinkMicString(@"结束连麦") forState:UIControlStateNormal];
    } else {
        self.pusherStatusLabel.hidden = YES;
        self.pusherStatusLabel.text = @"";
        
        self.pusherActionButton.backgroundColor = AUIFoundationColor(@"colourful_fill_strong");
        [self.pusherActionButton setTitle:AUILiveLinkMicString(@"开始连麦") forState:UIControlStateNormal];
    }
}

- (void)setAnchorPullStatus:(AUILiveLinkMicAnchorPullStatus)anchorPullStatus {
    _anchorPullStatus = anchorPullStatus;
    if (anchorPullStatus == AUILiveLinkMicAnchorPullStatusPulling ||
        anchorPullStatus == AUILiveLinkMicAnchorPullStatusPause) {
        self.bgStatusView.hidden = YES;
    } else {
        self.bgStatusView.hidden = NO;
    }
}

- (void)destory {
    if (self.paramManager.isUserMainStream) {
        [self.userMainStreamManager releaseUserStream];
    }
    
    [self.cdnPlayer stop];
    self.cdnPlayer.playerView = nil;
    [self.cdnPlayer destroy];
    self.cdnPlayer = nil;
    
    [self.rtcPusher destory];
    self.rtcPusher = nil;
    self.audiencePushStatus = AUILiveLinkMicAudiencePushStatusNone;
    
    [self.rtcPlayer stopPlay];
    self.rtcPlayer = nil;
    self.anchorPullStatus = AUILiveLinkMicAnchorPullStatusNone;
    
    if (self.paramManager.beautyOn) {
        [[AUILiveBeautyController sharedInstance] destroyBeautyControllerUI];
    }
}

//- (void)addNotifications {
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(applicationWillResignActive:)
//                                                 name:UIApplicationWillResignActiveNotification
//                                               object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(applicationDidBecomeActive:)
//                                                 name:UIApplicationDidBecomeActiveNotification
//                                               object:nil];
//}

#pragma mark -- AVPDelegate
- (void)onPlayerEvent:(AliPlayer *)player eventType:(AVPEventType)eventType {
    if (eventType == AVPEventCompletion) {
        self.anchorPullStatus = AUILiveLinkMicAnchorPullStatusStop;
    }
}

- (void)onError:(AliPlayer *)player errorModel:(AVPErrorModel *)errorModel {
    NSString *errMsg = [NSString stringWithFormat:@"Pull Play Error:[%lu]%@", (unsigned long)errorModel.code, errorModel.message];
    [AVToastView show:errMsg view:self.view position:AVToastViewPositionMid];
    self.anchorPullStatus = AUILiveLinkMicAnchorPullStatusError;
    [self stopCDNPull];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startCDNPull];
    });
}

#pragma mark - AlivcLiveBaseObserver
- (void)onLicenceCheck:(AlivcLiveLicenseCheckResultCode)result Reason:(NSString *)reason
{
    NSLog(@"LicenceCheck %ld, reason %@", (long)result, reason);
    if(result != AlivcLiveLicenseCheckResultCodeSuccess)
    {
        NSString *showMessage = [NSString stringWithFormat:@"License Error: code:%ld message:%@", (long)result, reason];

        dispatch_async(dispatch_get_main_queue(), ^{
            [AVAlertController showWithTitle:AUILiveLinkMicString(@"AlivcLivePusher License Error") message:showMessage needCancel:NO onCompleted:nil];
        });
    }
}

#pragma mark - AlivcLivePusherErrorDelegate
- (void)onSystemError:(AlivcLivePusher *)pusher error:(AlivcLivePushError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.audiencePushStatus = AUILiveLinkMicAudiencePushStatusError;
        [AVToastView show:AUILiveCommonString(@"系统错误") view:self.view position:AVToastViewPositionMid];
    });
}

- (void)onSDKError:(AlivcLivePusher *)pusher error:(AlivcLivePushError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.audiencePushStatus = AUILiveLinkMicAudiencePushStatusError;
        [AVToastView show:AUILiveCommonString(@"SDK错误") view:self.view position:AVToastViewPositionMid];
    });
}

#pragma mark - AlivcLivePusherNetworkDelegate
- (void)onConnectFail:(AlivcLivePusher *)pusher error:(AlivcLivePushError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.audiencePushStatus = AUILiveLinkMicAudiencePushStatusError;
        [AVToastView show:AUILiveCommonString(@"链接失败") view:self.view position:AVToastViewPositionMid];
    });
}

- (void)onSendDataTimeout:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.audiencePushStatus = AUILiveLinkMicAudiencePushStatusError;
        [AVToastView show:AUILiveCommonString(@"发送数据超时") view:self.view position:AVToastViewPositionMid];
    });
}

- (void)onNetworkPoor:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        [AVToastView show:AUILiveCommonString(@"当前网速较慢，请检查网络状态") view:self.view position:AVToastViewPositionMid];
    });
}

- (void)onReconnectStart:(AlivcLivePusher *)pusher {
}

- (void)onReconnectSuccess:(AlivcLivePusher *)pusher {
}

- (void)onConnectionLost:(AlivcLivePusher *)pusher {
}

- (void)onReconnectError:(AlivcLivePusher *)pusher error:(AlivcLivePushError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.audiencePushStatus = AUILiveLinkMicAudiencePushStatusError;
        [AVToastView show:AUILiveCommonString(@"重连失败") view:self.view position:AVToastViewPositionMid];
    });
}

- (void)onPacketsLost:(AlivcLivePusher *)pusher {
}

#pragma mark - AlivcLivePusherInfoDelegate
- (void)onPreviewStarted:(AlivcLivePusher *)pusher {
    if (self.paramManager.beautyOn && !self.paramManager.audioOnly) {
        BOOL processPixelBuffer = !self.rtcPushConfig.enableLocalVideoTexture;
        [[AUILiveBeautyController sharedInstance] setupBeautyController:processPixelBuffer];
    }
}

- (void)onPreviewStoped:(AlivcLivePusher *)pusher {
    BOOL processPixelBuffer = !self.rtcPushConfig.enableLocalVideoTexture;
    if (self.paramManager.beautyOn && !self.paramManager.audioOnly && processPixelBuffer) {
        [[AUILiveBeautyController sharedInstance] destroyBeautyController];
    }
}

- (void)onPushStarted:(AlivcLivePusher *)pusher {
}

- (void)onPushPaused:(AlivcLivePusher *)pusher {
}

- (void)onPushResumed:(AlivcLivePusher *)pusher {
}

- (void)onPushStoped:(AlivcLivePusher *)pusher {
}

- (void)onFirstFramePreviewed:(AlivcLivePusher *)pusher {
}

- (void)onPushRestart:(AlivcLivePusher *)pusher {
}

#pragma mark -- AlivcLivePusherCustomFilterDelegate
// 通知外置滤镜创建回调
- (void)onCreate:(AlivcLivePusher*)pusher context:(void*)context {
    NSLog(@"onCreate");
}

// 通知外置滤镜处理回调
- (int)onProcess:(AlivcLivePusher *)pusher texture:(int)texture textureWidth:(int)width textureHeight:(int)height extra:(long)extra {
    if (self.paramManager.beautyOn) {
        return [[AUILiveBeautyController sharedInstance] processGLTextureWithTextureID:texture withWidth:width withHeight:height];
    }
    return texture;
}

// 通知外置滤镜销毁回调
- (void)onDestory:(AlivcLivePusher*)pusher {
    if (self.paramManager.beautyOn) {
        [[AUILiveBeautyController sharedInstance] destroyBeautyController];
    }
}

- (BOOL)onProcessVideoSampleBuffer:(AlivcLivePusher *)pusher sampleBuffer:(AlivcLiveVideoDataSample *)sampleBuffer {
    BOOL result = NO;
    if (self.paramManager.beautyOn) {
        result = [[AUILiveBeautyController sharedInstance] processPixelBuffer:sampleBuffer.pixelBuffer withPushOrientation:self.rtcPushConfig.orientation];
    }
    return result;
}

#pragma mark -- AlivcLivePusherCustomDetectorDelegate
// 通知外置视频检测创建回调
- (void)onCreateDetector:(AlivcLivePusher *)pusher {
}

// 通知外置视频检测处理回调
- (long)onDetectorProcess:(AlivcLivePusher*)pusher data:(long)data w:(int)w h:(int)h rotation:(int)rotation format:(int)format extra:(long)extra {
    if (self.paramManager.beautyOn) {
        [[AUILiveBeautyController sharedInstance] detectVideoBuffer:data
                                                        withWidth:w
                                                       withHeight:h
                                                  withVideoFormat:self.rtcPushConfig.externVideoFormat
                                              withPushOrientation:self.rtcPushConfig.orientation];
    }
    return data;
}

// 通知外置视频检测销毁回调
- (void)onDestoryDetector:(AlivcLivePusher *)pusher {
    
}

#pragma mark -- AliLivePlayerDelegate
- (void)onError:(AlivcLivePlayer *)player code:(AlivcLivePlayerError)code message:(NSString *)msg {
    NSString *errMsg = [NSString stringWithFormat:@"Pull Play Error:[%lu]%@", (unsigned long)code, msg];
    NSLog(@"play error:%@", errMsg);
    if (code == AlivcLivePlayErrorStreamNotFound) {
        [AVToastView show:AUILiveCommonString(@"没有拉到流") view:self.view position:AVToastViewPositionMid];
        [self stopRTCPlay];
        self.anchorPullStatus = AUILiveLinkMicAnchorPullStatusStop;
    } else if (code == AlivcLivePlayErrorStreamStopped) {
        [AVToastView show:AUILiveCommonString(@"主播离开") view:self.view position:AVToastViewPositionMid];
        [self stopRTCPlay];
        self.anchorPullStatus = AUILiveLinkMicAnchorPullStatusStop;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    } else {
        self.anchorPullStatus = AUILiveLinkMicAnchorPullStatusError;
        [AVToastView show:msg view:self.view position:AVToastViewPositionMid];
    }
}

- (void)onPlayStarted:(AlivcLivePlayer *)player {
}

- (void)onPlayStoped:(AlivcLivePlayer *)player {
}

- (void)onVideoPlaying:(AlivcLivePlayer*)player {
}

//- (void)applicationWillResignActive:(NSNotification *)notification {
//    if (self.anchorPullStatus == AUILiveLinkMicAnchorPullStatusPulling) {
//        [self stopRTCPush];
//        self.audiencePushStatus = AUILiveLinkMicAudiencePushStatusPause;
//    }
//
//    if (self.audiencePushStatus == AUILiveLinkMicAudiencePushStatusPushing) {
//        if (self.switchRTCPull) {
//            [self pauseCDNPull];
//        } else {
//            [self stopRTCPlay];
//        }
//        self.anchorPullStatus = AUILiveLinkMicAnchorPullStatusPause;
//    }
//}
//
//- (void)applicationDidBecomeActive:(NSNotification *)notification {
//    if (self.audiencePushStatus == AUILiveLinkMicAudiencePushStatusPause) {
//        [self restartRTCPush];
//    }
//
//    if (self.audiencePushStatus == AUILiveLinkMicAudiencePushStatusPause) {
//        if (self.switchRTCPull) {
//            [self restartCDNPull];
//        } else {
//            [self startRTCPlay];
//        }
//    }
//}

#pragma mark -- lazy load
- (AUILiveInteractiveParamManager *)paramManager {
    if (!_paramManager) {
        _paramManager = [AUILiveInteractiveParamManager manager];
    }
    return _paramManager;
}

- (AUILiveURLUtils *)cdnPlay {
    if (!_cdnPlay) {
        _cdnPlay = [[AUILiveURLUtils alloc] init];
        _cdnPlay.isRTC = NO;
        _cdnPlay.isPlay = YES;
        _cdnPlay.streamName = self.rtcConfig.streamName;
        _cdnPlay.isAudioOnly = self.paramManager.audioOnly;
    }
    return _cdnPlay;
}

- (AUILiveURLUtils *)rtcPush {
    if (!_rtcPush) {
        _rtcPush = [[AUILiveURLUtils alloc] init];
        _rtcPush.isRTC = YES;
        _rtcPush.isPlay = NO;
        _rtcPush.userId = self.rtcConfig.userId;
        _rtcPush.streamName = self.rtcConfig.streamName;
    }
    return _rtcPush;
}

- (AUILiveURLUtils *)rtcPlay {
    if (!_rtcPlay) {
        _rtcPlay = [[AUILiveURLUtils alloc] init];
        _rtcPlay.isRTC = YES;
        _rtcPlay.isPlay = YES;
        _rtcPlay.streamName = self.rtcConfig.streamName;
    }
    return _rtcPlay;
}

- (AUILiveIntercativeBgStatusView *)bgStatusView {
    if (!_bgStatusView) {
        _bgStatusView = [[AUILiveIntercativeBgStatusView alloc] initWithFrame:self.view.bounds];
    }
    return _bgStatusView;
}

- (AlivcLivePushConfig *)rtcPushConfig {
    if (!_rtcPushConfig) {
        _rtcPushConfig = [[AlivcLivePushConfig alloc] init];
        _rtcPushConfig.livePushMode = AlivcLivePushInteractiveMode;
        _rtcPushConfig.resolution = self.paramManager.resolution;
        _rtcPushConfig.fps = AlivcLivePushFPS20;
        _rtcPushConfig.enableAutoBitrate = true;
        _rtcPushConfig.videoEncodeGop = AlivcLivePushVideoEncodeGOP_2;
        _rtcPushConfig.connectRetryInterval = 2000;
        _rtcPushConfig.previewMirror = false;
        _rtcPushConfig.orientation = AlivcLivePushOrientationPortrait;
        _rtcPushConfig.enableAutoResolution = YES;
        _rtcPushConfig.previewDisplayMode = ALIVC_LIVE_PUSHER_PREVIEW_ASPECT_FIT;
        _rtcPushConfig.videoEncoderMode = self.paramManager.videoEncoderMode;
        _rtcPushConfig.audioEncoderMode = self.paramManager.audioEncoderMode;
        _rtcPushConfig.audioOnly = self.paramManager.audioOnly;
        _rtcPushConfig.videoHardEncoderCodec = self.paramManager.videoHardEncoderCodec;
        _rtcPushConfig.fps = self.paramManager.fps;
        
        if(self.paramManager.isUserMainStream) {
            _rtcPushConfig.externMainStream = true;
            _rtcPushConfig.externVideoFormat = AlivcLivePushVideoFormatYUVNV12;
        } else {
            _rtcPushConfig.externMainStream = false;
        }
    }
    return _rtcPushConfig;
}

- (AlivcLivePlayConfig *)rtcPlayConfig {
    if (!_rtcPlayConfig) {
        _rtcPlayConfig = [[AlivcLivePlayConfig alloc] init];
        _rtcPlayConfig.renderMode = AlivcLivePlayRenderModeAuto;
    }
    return _rtcPlayConfig;
}

- (UIView *)playerView {
    if (!_playerView) {
        _playerView = [[UIView alloc] initWithFrame:self.view.bounds];
    }
    return _playerView;
}

- (AUILiveIntercativeLinkCustomerView *)pusherView {
    if (!_pusherView) {
        CGFloat pusherBottom = self.view.av_bottom - AVSafeBottom - 31;
        _pusherView = [[AUILiveIntercativeLinkCustomerView alloc] initWithFrame:CGRectMake(self.view.av_width - 16 - 90, pusherBottom - 30 - 15 - 160, 90, 160)];
        _pusherView.backgroundColor = AUIFoundationColor(@"fg_strong");
        _pusherView.customerStatus = AUILiveLinkCustomerStatusNone;
    }
    return _pusherView;
}

- (UILabel *)pusherStatusLabel {
    if (!_pusherStatusLabel) {
        _pusherStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.headerView.av_bottom + 4, self.view.av_width, 18)];
        _pusherStatusLabel.textColor = AUIFoundationColor(@"text_strong");
        _pusherStatusLabel.font = AVGetRegularFont(12);
        _pusherStatusLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _pusherStatusLabel;
}

- (UIButton *)pusherActionButton {
    if (!_pusherActionButton) {
        CGFloat pusherBottom = self.view.av_bottom - AVSafeBottom - 31;
        _pusherActionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _pusherActionButton.frame = CGRectMake(self.pusherView.av_left, pusherBottom - 30, 90, 30);
        _pusherActionButton.backgroundColor = AUIFoundationColor(@"colourful_fill_strong");
        _pusherActionButton.layer.cornerRadius = 15;
        [_pusherActionButton setTitle:AUILiveLinkMicString(@"开始连麦") forState:UIControlStateNormal];
        [_pusherActionButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
        _pusherActionButton.titleLabel.font = AVGetRegularFont(16);
        [_pusherActionButton addTarget:self action:@selector(changeCustomerAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pusherActionButton;
}

- (UIButton *)beautyButton {
    if (!_beautyButton) {
        _beautyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _beautyButton.frame = CGRectMake(self.contentView.av_right - 60 - 5, self.contentView.av_top + 20, 60, 60);
        [_beautyButton setImage:AUILiveCommonImage(@"alivc_beauty") forState:UIControlStateNormal];
        [_beautyButton addTarget:self action:@selector(pressBeautyButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _beautyButton;
}

- (AUILiveExternMainStreamManager *)userMainStreamManager {
    if (!_userMainStreamManager) {
        _userMainStreamManager = [[AUILiveExternMainStreamManager alloc] init];
        _userMainStreamManager.pushConfig = self.rtcPushConfig;
        _userMainStreamManager.livePusher = self.rtcPusher;
    }
    return _userMainStreamManager;
}

@end
