//
//  AUILiveLinkMicAnchorLinkViewController.m
//  AUILiveLinkMic
//
//  Created by ISS013602000846 on 2022/7/22.
//

#import "AUILiveLinkMicAnchorLinkViewController.h"
#import "AUILiveInteractiveParamManager.h"
#import "AUILiveIntercativeLinkCustomerView.h"
#import "AUILiveInputNumberAlert.h"
#import "AUILiveExternMainStreamManager.h"
#import "AUILiveBeautyController.h"

typedef NS_ENUM(NSInteger, AUILiveLinkMicAnchorPushStatus) {
    AUILiveLinkMicAnchorPushStatusNone = 0,
    AUILiveLinkMicAnchorPushStatusPushing,
    AUILiveLinkMicAnchorPushStatusPause,
    AUILiveLinkMicAnchorPushStatusError,
    AUILiveLinkMicAnchorPushStatusStop,
};

typedef NS_ENUM(NSInteger, AUILiveLinkMicAudiencePullStatus) {
    AUILiveLinkMicAudiencePullStatusNone = 0,
    AUILiveLinkMicAudiencePullStatusPulling,
    AUILiveLinkMicAudiencePullStatusPause,
    AUILiveLinkMicAudiencePullStatusError,
    AUILiveLinkMicAudiencePullStatusStop,
};

@interface AUILiveLinkMicAnchorLinkViewController ()<AlivcLivePusherInfoDelegate, AlivcLivePusherErrorDelegate, AlivcLivePusherNetworkDelegate, AlivcLivePusherCustomFilterDelegate, AlivcLivePusherCustomDetectorDelegate, AliLivePlayerDelegate, AlivcLiveBaseObserver>

@property (nonatomic, strong) AUILiveInteractiveParamManager *paramManager;

@property (nonatomic, strong) AUILiveURLUtils *rtcPush;
@property (nonatomic, strong) AUILiveURLUtils *rtcPlay;

@property (nonatomic, strong) AlivcLivePushConfig *rtcPushConfig;
@property (nonatomic, strong) AlivcLivePusher *rtcPusher;

@property (nonatomic, strong) AlivcLivePlayConfig *rtcPlayConfig;
@property (nonatomic, strong) AlivcLivePlayer *rtcPlayer;

@property (nonatomic, strong) UIView *pusherView;

@property (nonatomic, strong) AUILiveIntercativeLinkCustomerView *playerView;
@property (nonatomic, strong) UILabel *playerStatusLabel;
@property (nonatomic, strong) UIButton *playerActionButton;

@property (nonatomic, strong) UIButton *beautyButton;

@property (nonatomic, assign) AUILiveLinkMicAnchorPushStatus anchorPushStatus;
@property (nonatomic, assign) AUILiveLinkMicAudiencePullStatus audiencePullStatus;

@property (nonatomic, strong) AUILiveExternMainStreamManager *userMainStreamManager;

@end

@implementation AUILiveLinkMicAnchorLinkViewController

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
    
    [self setupRTCPusher];
    [self setupRTCPlayer];
    [self setupContent];
    
    [self startRTCPushPreview];
    
    if (self.paramManager.isUserMainStream) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.userMainStreamManager addUserStream];
        });
    }
    
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
    BOOL success = [self startRTCPush];
    if (success) {
        self.playerView.hidden = NO;
        self.playerActionButton.hidden = NO;
    }
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self destory];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
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
}

- (void)setupContent {
    [self.view addSubview:self.pusherView];
    
    [self.view addSubview:self.playerView];
    self.playerView.hidden = YES;
    
    [self.view addSubview:self.playerStatusLabel];
    self.playerStatusLabel.hidden = YES;

    [self.view addSubview:self.playerActionButton];
    self.playerActionButton.hidden = YES;
    
    if (self.paramManager.beautyOn) {
        [self.view addSubview:self.beautyButton];
    }
    
    [self.view bringSubviewToFront:self.headerView];
    [self.view bringSubviewToFront:self.playerView];
    [self.view bringSubviewToFront:self.playerStatusLabel];
    [self.view bringSubviewToFront:self.playerActionButton];
    [self.view bringSubviewToFront:self.beautyButton];
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
    if (self.audiencePullStatus == AUILiveLinkMicAudiencePullStatusPulling ||
        self.audiencePullStatus == AUILiveLinkMicAudiencePullStatusError) {
        __weak typeof(self) weakSelf = self;
        [AVAlertController showWithTitle:nil message:AUILiveLinkMicString(@"确认要结束本次连麦吗？") needCancel:YES onCompleted:^(BOOL isCanced) {
            __strong typeof(self) strongSelf = weakSelf;
            if (!isCanced) {
                [strongSelf stopRTCPlay];
            }
        }];
    } else {
        __weak typeof(self) weakSelf = self;
        
        [AUILiveInputNumberAlert show:@[AUILiveLinkMicString(@"请输入观众的用户ID")] view:self.view maxNumber:kAUILiveInputAlertNotMaxNumer inputAction:^(BOOL ok, NSArray<NSString *> * _Nonnull inputs) {
            __strong typeof(self) strongSelf = weakSelf;
            if (ok) {
                if (inputs.firstObject == strongSelf.rtcPush.userId) {
                    [AVToastView show:AUILiveLinkMicString(@"观众和主播ID不能一致") view:self.view position:AVToastViewPositionMid];
                } else {
                    strongSelf.rtcPlay.userId = inputs.firstObject;
                    [strongSelf startRTCPlay];
                }
            }
        }];
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
    int ret = [self.rtcPusher startPreview:self.pusherView];
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
        self.anchorPushStatus = AUILiveLinkMicAnchorPushStatusStop;
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

    int ret = [self.rtcPusher startPushWithURL:rtcPushURL];
    if (ret == 0) {
        self.anchorPushStatus = AUILiveLinkMicAnchorPushStatusPushing;
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
        self.anchorPushStatus = AUILiveLinkMicAnchorPushStatusStop;
        return YES;
    }
    
    if ([self.rtcPusher isPushing]) {
        int ret = [self.rtcPusher stopPush];
        self.anchorPushStatus = AUILiveLinkMicAnchorPushStatusStop;
        return ret == 0;
    } else {
        self.anchorPushStatus = AUILiveLinkMicAnchorPushStatusStop;
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
        if (self.anchorPushStatus == AUILiveLinkMicAnchorPushStatusPause) {
            self.anchorPushStatus = AUILiveLinkMicAnchorPushStatusError;
        }
        return NO;
    }
    
    int ret = [self.rtcPusher startPushWithURLAsync:rtcPushURL];
    if (ret == 0) {
        self.anchorPushStatus = AUILiveLinkMicAnchorPushStatusPushing;
        return YES;
    } else {
        NSString *errMsg = [NSString stringWithFormat:@"Restart Push Error:%d", ret];
        [AVToastView show:errMsg view:self.view position:AVToastViewPositionMid];
        if (self.anchorPushStatus == AUILiveLinkMicAnchorPushStatusPause) {
            self.anchorPushStatus = AUILiveLinkMicAnchorPushStatusError;
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
        if (self.audiencePullStatus == AUILiveLinkMicAudiencePullStatusPause) {
            self.audiencePullStatus = AUILiveLinkMicAudiencePullStatusError;
        }
        return;
    }
    
    int ret = [self.rtcPlayer setPlayView:[self.playerView getPlayerShow] playCofig:self.rtcPlayConfig];
    if (ret != 0) {
        if (self.audiencePullStatus == AUILiveLinkMicAudiencePullStatusPause) {
            self.audiencePullStatus = AUILiveLinkMicAudiencePullStatusError;
        }
        self.audiencePullStatus = AUILiveLinkMicAudiencePullStatusNone;
        [AVToastView show:AUILiveCommonString(@"初始化拉流失败") view:self.view position:AVToastViewPositionMid];
    } else {
        [self.rtcPlayer startPlayWithURL:rtcPlayURL];
        self.audiencePullStatus = AUILiveLinkMicAudiencePullStatusPulling;
        
        [self setMixStream];
    }
}

/**
 停止RTC拉流
 */
- (void)stopRTCPlay {
    [self.rtcPlayer stopPlay];
    self.audiencePullStatus = AUILiveLinkMicAudiencePullStatusStop;
    
    [self relaseMixStream];
}

- (void)setMixStream {
    AlivcLiveTranscodingConfig *liveTranscodingConfig = [[AlivcLiveTranscodingConfig alloc] init];
    
    AlivcLiveMixStream *anchorMixStream = [[AlivcLiveMixStream alloc] init];
    anchorMixStream.userId = self.rtcPush.userId;
    anchorMixStream.x = 0;
    anchorMixStream.y = 0;
    anchorMixStream.width = [self.rtcPushConfig getPushResolution].width;
    anchorMixStream.height = [self.rtcPushConfig getPushResolution].height;
    anchorMixStream.zOrder = 1;
        
    UIView *playShowView = [self.playerView getPlayerShow]; // audience playShowView是playerView的子视图
    AlivcLiveMixStream *audienceMixStream = [[AlivcLiveMixStream alloc] init];
    audienceMixStream.userId = self.rtcPlay.userId;
    audienceMixStream.x = self.playerView.av_left + playShowView.av_left;
    audienceMixStream.y = self.playerView.av_top + playShowView.av_top;
    audienceMixStream.width = playShowView.av_width;
    audienceMixStream.height = playShowView.av_height;
    audienceMixStream.zOrder = 2;
        
    liveTranscodingConfig.mixStreams = [NSArray arrayWithObjects:anchorMixStream, audienceMixStream, nil];
    [self.rtcPusher setLiveMixTranscodingConfig:liveTranscodingConfig];
}

- (void)relaseMixStream {
    [self.rtcPusher setLiveMixTranscodingConfig:nil];
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

- (void)setAudiencePullStatus:(AUILiveLinkMicAudiencePullStatus)audiencePullStatus {
    _audiencePullStatus = audiencePullStatus;
    if (audiencePullStatus == AUILiveLinkMicAudiencePullStatusPulling) {
        self.playerView.customerStatus = AUILiveLinkCustomerStatusPulling;
    } else if (audiencePullStatus == AUILiveLinkMicAudiencePullStatusError) {
        self.playerView.customerStatus = AUILiveLinkCustomerStatusError;
    } else {
        self.playerView.customerStatus = AUILiveLinkCustomerStatusNone;
    }
    
    if (audiencePullStatus == AUILiveLinkMicAudiencePullStatusPulling ||
        audiencePullStatus == AUILiveLinkMicAudiencePullStatusError) {
        self.playerStatusLabel.hidden = NO;
        self.playerStatusLabel.text = AUILiveLinkMicString(@"正在连麦");

        self.playerActionButton.backgroundColor = AUILiveCommonColor(@"ir_button_pulling");
        [self.playerActionButton setTitle:AUILiveLinkMicString(@"结束连麦") forState:UIControlStateNormal];
    } else {
        self.playerStatusLabel.hidden = YES;
        self.playerStatusLabel.text = @"";
        
        self.playerActionButton.backgroundColor = AUIFoundationColor(@"colourful_fill_strong");
        [self.playerActionButton setTitle:AUILiveLinkMicString(@"开始连麦") forState:UIControlStateNormal];
    }
}

- (void)destory {
    if (self.paramManager.isUserMainStream) {
        [self.userMainStreamManager releaseUserStream];
    }
    
    [self.rtcPlayer stopPlay];
    self.rtcPlayer = nil;
    self.audiencePullStatus = AUILiveLinkMicAudiencePullStatusNone;
    
    [self.rtcPusher destory];
    self.rtcPusher = nil;
    self.anchorPushStatus = AUILiveLinkMicAnchorPushStatusNone;
    
    if (self.paramManager.beautyOn) {
        [[AUILiveBeautyController sharedInstance] destroyBeautyControllerUI];
    }
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
        self.anchorPushStatus = AUILiveLinkMicAnchorPushStatusError;
        [AVToastView show:AUILiveCommonString(@"系统错误") view:self.view position:AVToastViewPositionMid];
    });
}

- (void)onSDKError:(AlivcLivePusher *)pusher error:(AlivcLivePushError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.anchorPushStatus = AUILiveLinkMicAnchorPushStatusError;
        [AVToastView show:AUILiveCommonString(@"SDK错误") view:self.view position:AVToastViewPositionMid];
    });
}

#pragma mark - AlivcLivePusherNetworkDelegate
- (void)onConnectFail:(AlivcLivePusher *)pusher error:(AlivcLivePushError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.anchorPushStatus = AUILiveLinkMicAnchorPushStatusError;
        [AVToastView show:AUILiveCommonString(@"链接失败") view:self.view position:AVToastViewPositionMid];
    });
}


- (void)onSendDataTimeout:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.anchorPushStatus = AUILiveLinkMicAnchorPushStatusError;
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
        self.anchorPushStatus = AUILiveLinkMicAnchorPushStatusError;
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
        self.audiencePullStatus = AUILiveLinkMicAudiencePullStatusStop;
    } else if (code == AlivcLivePlayErrorStreamStopped) {
        [AVToastView show:AUILiveLinkMicString(@"观众离开") view:self.view position:AVToastViewPositionMid];
        [self stopRTCPlay];
        self.audiencePullStatus = AUILiveLinkMicAudiencePullStatusStop;
    } else {
        self.audiencePullStatus = AUILiveLinkMicAudiencePullStatusError;
        [AVToastView show:msg view:self.view position:AVToastViewPositionMid];
    }
}

- (void)onPlayStarted:(AlivcLivePlayer *)player {
}

- (void)onPlayStoped:(AlivcLivePlayer *)player {
}

- (void)onVideoPlaying:(AlivcLivePlayer*)player {
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


//- (void)applicationWillResignActive:(NSNotification *)notification {
//    if (self.anchorPushStatus == AUILiveLinkMicAnchorPushStatusPushing) {
//        [self stopRTCPush];
//        self.anchorPushStatus = AUILiveLinkMicAnchorPushStatusPause;
//    }
//    
//    if (self.audiencePullStatus == AUILiveLinkMicAudiencePullStatusPulling) {
//        [self stopRTCPlay];
//        self.audiencePullStatus = AUILiveLinkMicAudiencePullStatusPause;
//    }
//}
//
//- (void)applicationDidBecomeActive:(NSNotification *)notification {
//    if (self.anchorPushStatus == AUILiveLinkMicAnchorPushStatusPause) {
//        [self restartRTCPush];
//    }
//    
//    if (self.audiencePullStatus == AUILiveLinkMicAudiencePullStatusPause) {
//        [self startRTCPlay];
//    }
//}

#pragma mark -- lazy load
- (AUILiveInteractiveParamManager *)paramManager {
    if (!_paramManager) {
        _paramManager = [AUILiveInteractiveParamManager manager];
    }
    return _paramManager;
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

- (AlivcLivePushConfig *)rtcPushConfig {
    if (!_rtcPushConfig) {
        _rtcPushConfig = [[AlivcLivePushConfig alloc] init];
        _rtcPushConfig.livePushMode = AlivcLivePushInteractiveMode;
        _rtcPushConfig.resolution = self.paramManager.resolution;
        _rtcPushConfig.fps = AlivcLivePushFPS20;
        _rtcPushConfig.enableAutoBitrate = true;
        _rtcPushConfig.videoEncodeGop = self.paramManager.videoEncodeGop;
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

- (UIView *)pusherView {
    if (!_pusherView) {
        _pusherView = [[UIView alloc] initWithFrame:self.view.bounds];
    }
    return _pusherView;
}

- (AUILiveIntercativeLinkCustomerView *)playerView {
    if (!_playerView) {
        CGFloat customerBottom = self.view.av_bottom - AVSafeBottom - 31;
        _playerView = [[AUILiveIntercativeLinkCustomerView alloc] initWithFrame:CGRectMake(self.view.av_width - 16 - 90, customerBottom - 30 - 15 - 160, 90, 160)];
        _playerView.backgroundColor = AUIFoundationColor(@"fg_strong");
        _playerView.customerStatus = AUILiveLinkCustomerStatusNone;
    }
    return _playerView;
}

- (UILabel *)playerStatusLabel {
    if (!_playerStatusLabel) {
        _playerStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.headerView.av_bottom + 4, self.view.av_width, 18)];
        _playerStatusLabel.textColor = AUIFoundationColor(@"text_strong");
        _playerStatusLabel.font = AVGetRegularFont(12);
        _playerStatusLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _playerStatusLabel;
}

- (UIButton *)playerActionButton {
    if (!_playerActionButton) {
        CGFloat customerBottom = self.view.av_bottom - AVSafeBottom - 31;
        _playerActionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playerActionButton.frame = CGRectMake(self.playerView.av_left, customerBottom - 30, 90, 30);
        _playerActionButton.backgroundColor = AUIFoundationColor(@"colourful_fill_strong");
        _playerActionButton.layer.cornerRadius = 15;
        [_playerActionButton setTitle:AUILiveLinkMicString(@"开始连麦") forState:UIControlStateNormal];
        [_playerActionButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
        _playerActionButton.titleLabel.font = AVGetRegularFont(16);
        [_playerActionButton addTarget:self action:@selector(changeCustomerAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playerActionButton;
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
