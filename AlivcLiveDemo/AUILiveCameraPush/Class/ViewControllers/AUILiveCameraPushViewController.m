//
//  AUILiveCameraPublishViewController.m
//  AlivcLiveCaptureDev
//
//  Created by TripleL on 17/7/10.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import "AUILiveCameraPushViewController.h"
#import "AUILiveCameraPublishView.h"
#import "AlivcLivePushViewsProtocol.h"
#import <CommonCrypto/CommonDigest.h>
#import "Masonry.h"
#import "AUILiveFixedOrientationDirAlertController.h"

#import "AUILiveBeautyController.h"
#import "AUILiveMonitorView.h"
#import "AlivcLiveSettingManager.h"
#import "AUILiveExternMainStreamManager.h"

#define kAlivcLivePusherVCAlertTag 89976
#define kAlivcLivePusherNoticeTimerInterval 5.0

@interface AUILiveCameraPushViewController () <AUILiveCameraPublishViewDelegate, AUILiveMusicViewDelegate,AUILiveAnswerGameViewDelegate,UIAlertViewDelegate,AlivcLivePusherInfoDelegate,AlivcLivePusherErrorDelegate,AlivcLivePusherNetworkDelegate,AlivcLivePusherBGMDelegate,AlivcLivePusherCustomFilterDelegate,AlivcLivePusherCustomDetectorDelegate, AlivcLivePusherSnapshotDelegate, AlivcLiveBaseObserver>{
    int waterMarkCount;
    BOOL isShowWaterMark;
}

// UI
@property (nonatomic, strong) AUILiveCameraPublishView *publisherView;
@property (nonatomic, strong) UIView *previewView;
@property (nonatomic, strong) NSTimer *noticeTimer;
@property (nonatomic, strong) AUILiveMonitorView *monitorView;

// flags
@property (nonatomic, assign) BOOL isAutoFocus;

// SDK
@property (nonatomic, strong) AlivcLivePusher *livePusher;

@property (nonatomic, strong) AUILiveExternMainStreamManager *userMainStreamManager;

@end

@implementation AUILiveCameraPushViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.headerView.hidden = YES;
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

    // 如果不需要退后台继续推流，可以参考这套退后台通知的实现。
//    [self addBackgroundNotifications];

    
    [self setupSubviews];
    
    [self setupDefaultValues];
    
    [self setupDebugTimer];

    [self registerSDK];
    
    int ret = [self setupPusher];
    
    if (ret != 0) {
        [self showPusherInitErrorAlert:ret];
        return;
    }
    
    ret = [self startPreview];
    
    if (ret != 0) {
        [self showPusherStartPreviewErrorAlert:ret isStart:YES];
        return;
    }
    
    if (self.isUserMainStream) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.userMainStreamManager addUserStream];
        });
    }
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // 监控数据view
     _monitorView = [[AUILiveMonitorView alloc] initWithFrame:CGRectMake(10, 130, self.view.frame.size.width - 20, 150)];
     _monitorView.backgroundColor = [UIColor clearColor];
     [self.view addSubview:_monitorView];
    _monitorView.hidden = YES;
    waterMarkCount = 0;
    isShowWaterMark = YES;
    
    [AlivcLiveSettingManager manager].savedConfig = self.pushConfig;
    [[AlivcLiveSettingManager manager] reload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[AUILiveBeautyController sharedInstance] setupBeautyControllerUIWithView:self.view];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[AUILiveBeautyController sharedInstance] destroyBeautyControllerUI];
    [[AlivcLiveSettingManager manager] clear];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    if (self.pushConfig.orientation == AlivcLivePushOrientationLandscapeLeft) {
        return UIInterfaceOrientationMaskLandscapeLeft;
    } else if (self.pushConfig.orientation == AlivcLivePushOrientationLandscapeRight) {
        return UIInterfaceOrientationMaskLandscapeRight;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    if (self.pushConfig.orientation == AlivcLivePushOrientationLandscapeLeft) {
        return UIInterfaceOrientationLandscapeLeft;
    } else if (self.pushConfig.orientation == AlivcLivePushOrientationLandscapeRight) {
        return UIInterfaceOrientationLandscapeRight;
    } else {
        return UIInterfaceOrientationPortrait;
    }
}


#pragma mark - SDK
- (void)registerSDK {
    
    [AlivcLiveBase setObserver:self];
    NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    [AlivcLiveBase setLogPath:cacheDirectory maxPartFileSizeInKB:100*1024*1024];
    [AlivcLiveBase setLogLevel:AlivcLivePushLogLevelDebug];
    [AlivcLiveBase registerSDK];
}

/**
 创建推流
 */
- (int)setupPusher {
   
    if(self.isUserMainStream) {
        
        self.pushConfig.externMainStream = true;
        self.pushConfig.externVideoFormat = AlivcLivePushVideoFormatYUVNV12;
        
    }else {
        
        self.pushConfig.externMainStream = false;
    }
    self.livePusher = [[AlivcLivePusher alloc] initWithConfig:self.pushConfig];
    
    if (!self.livePusher) {
        return -1;
    }
    [self.livePusher setInfoDelegate:self];
    [self.livePusher setErrorDelegate:self];
    [self.livePusher setNetworkDelegate:self];
    [self.livePusher setBGMDelegate:self];
    [self.livePusher setSnapshotDelegate:self];
    [self.livePusher setCustomFilterDelegate:self];
    [self.livePusher setCustomDetectorDelegate:self];
    
    return 0;
}


/**
 销毁推流
 */
- (void)destoryPusher {
    if (self.isUserMainStream) {
        [self.userMainStreamManager releaseUserStream];
    }
    
    if (self.livePusher) {
        [self.livePusher destory];
    }
    
    self.livePusher = nil;
}


/**
 开始预览
 */
- (int)startPreview {
    
    if (!self.livePusher) {
        return -1;
    }
    int ret = 0;
    if (self.isUseAsyncInterface) {
        // 使用异步接口
        ret = [self.livePusher startPreviewAsync:self.previewView];
        
    } else {
        // 使用同步接口
        ret = [self.livePusher startPreview:self.previewView];
    }
    return ret;
}


/**
 停止预览
 */
- (int)stopPreview {
    
    if (!self.livePusher) {
        return -1;
    }
    int ret = [self.livePusher stopPreview];
    return ret;
}


/**
 开始推流
 */
- (int)startPush {
    if (!self.livePusher) {
        return -1;
    }
    
    // 鉴权测试时，使用Auth A类型的URL。
    [self updateAuthURL];
    
    int ret = 0;
    if (self.isUseAsyncInterface) {
        // 使用异步接口
        ret = [self.livePusher startPushWithURLAsync:self.pushURL];
    
    } else {
        // 使用同步接口
        ret = [self.livePusher startPushWithURL:self.pushURL];
    }
    
    return ret;
}


/**
 停止推流
 */
- (int)stopPush {
    
    if (!self.livePusher) {
        return -1;
    }
    
    int ret = [self.livePusher stopPush];
    return ret;
}


/**
 暂停推流
 */
- (int)pausePush {
    
    if (!self.livePusher) {
        return -1;
    }

    int ret = [self.livePusher pause];
    return ret;
}


/**
 恢复推流
 */
- (int)resumePush {
   
    if (!self.livePusher) {
        return -1;
    }
    
    int ret = 0;

    if (self.isUseAsyncInterface) {
        // 使用异步接口
       ret = [self.livePusher resumeAsync];
        
    } else {
        // 使用同步接口
        ret = [self.livePusher resume];
    }
    return ret;
}



/**
 重新推流
 */
- (int)restartPush {
    
    if (!self.livePusher) {
        return -1;
    }
    
    int ret = 0;
    if (self.isUseAsyncInterface) {
        // 使用异步接口
        ret = [self.livePusher restartPushAsync];
        
    } else {
        // 使用同步接口
        ret = [self.livePusher restartPush];
    }
    return ret;
}


- (void)reconnectPush {
    
    if (!self.livePusher) {
        return;
    }
    
    [self.livePusher reconnectPushAsync];
}

#pragma mark - AlivcLivePusherErrorDelegate

- (void)onSystemError:(AlivcLivePusher *)pusher error:(AlivcLivePushError *)error {

    [self showAlertViewWithErrorCode:error.errorCode
                            errorStr:error.errorDescription
                                 tag:kAlivcLivePusherVCAlertTag+11
                               title:AUILiveCameraPushString(@"错误提示")
                             message:AUILiveCameraPushString(@"系统错误：")
                         cancelTitle:AUILiveCameraPushString(@"退出")
                             okTitle:AUILiveCommonString(@"确定")];
}


- (void)onSDKError:(AlivcLivePusher *)pusher error:(AlivcLivePushError *)error {
    
    [self showAlertViewWithErrorCode:error.errorCode
                            errorStr:error.errorDescription
                                 tag:kAlivcLivePusherVCAlertTag+12
                               title:AUILiveCameraPushString(@"错误提示")
                             message:AUILiveCameraPushString(@"SDK错误：")
                         cancelTitle:AUILiveCameraPushString(@"退出")
                             okTitle:AUILiveCommonString(@"确定")];
}



#pragma mark - AlivcLivePusherNetworkDelegate

- (void)onConnectFail:(AlivcLivePusher *)pusher error:(AlivcLivePushError *)error {
    
    [self showAlertViewWithErrorCode:error.errorCode
                            errorStr:error.errorDescription
                                 tag:kAlivcLivePusherVCAlertTag+23
                               title:AUILiveCameraPushString(@"错误提示")
                             message:AUILiveCommonString(@"链接失败")
                         cancelTitle:AUILiveCameraPushString(@"重连")
                             okTitle:AUILiveCameraPushString(@"退出")];

}


- (void)onSendDataTimeout:(AlivcLivePusher *)pusher {
    
    [self showAlertViewWithErrorCode:0
                            errorStr:nil
                                 tag:0
                               title:AUILiveCameraPushString(@"错误提示")
                             message:AUILiveCommonString(@"发送数据超时")
                         cancelTitle:AUILiveCommonString(@"确定")
                             okTitle:nil];
}

- (void)onSendSeiMessage:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:AUILiveCameraPushString(@"发送消息")];

}


- (void)onConnectRecovery:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:AUILiveCameraPushString(@"网络恢复")];
}


- (void)onNetworkPoor:(AlivcLivePusher *)pusher {
    [self showAlertViewWithErrorCode:0
                            errorStr:nil
                                 tag:0
                               title:AUILiveCameraPushString(@"错误提示")
                             message:AUILiveCommonString(@"当前网速较慢，请检查网络状态")
                         cancelTitle:AUILiveCommonString(@"确定")
                             okTitle:nil];
}


- (void)onReconnectStart:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:AUILiveCameraPushString(@"重连开始")];
}


- (void)onReconnectSuccess:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:AUILiveCameraPushString(@"重连成功")];
}

- (void)onConnectionLost:(AlivcLivePusher *)pusher {
    
}


- (void)onReconnectError:(AlivcLivePusher *)pusher error:(AlivcLivePushError *)error {
    
    [self showAlertViewWithErrorCode:error.errorCode
                            errorStr:error.errorDescription
                                 tag:kAlivcLivePusherVCAlertTag+22
                               title:AUILiveCameraPushString(@"错误提示")
                             message:AUILiveCommonString(@"重连失败")
                         cancelTitle:AUILiveCameraPushString(@"重连")
                             okTitle:AUILiveCommonString(@"确定")];
}

- (NSString *)onPushURLAuthenticationOverdue:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:@"Auth push url update"];
    
    if(!self.livePusher.isPushing) {
         NSLog(@"推流url鉴权即将过期。更新url");
         [self updateAuthURL];
    }
    return self.pushURL;
}

- (void)onPacketsLost:(AlivcLivePusher *)pusher {
    
}


#pragma mark - AlivcLivePusherInfoDelegate

- (void)onPreviewStarted:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:NSLocalizedString(@"start_preview_log", nil)];
    if (self.beautyOn && !self.pushConfig.audioOnly) {
        BOOL processPixelBuffer = NO;
#ifdef ALIVC_LIVE_INTERACTIVE_MODE
        processPixelBuffer = self.pushConfig.livePushMode ==  AlivcLivePushInteractiveMode;
#endif
        [[AUILiveBeautyController sharedInstance] setupBeautyController:processPixelBuffer];
    }
}


- (void)onPreviewStoped:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:AUILiveCameraPushString(@"停止预览")];
    
    BOOL isInteractiveMode = NO;
#ifdef ALIVC_LIVE_INTERACTIVE_MODE
    isInteractiveMode = self.pushConfig.livePushMode ==  AlivcLivePushInteractiveMode;
#endif
    if (self.beautyOn && !self.pushConfig.audioOnly && isInteractiveMode)
    {
        [[AUILiveBeautyController sharedInstance] destroyBeautyController];
    }
}

- (void)onPushStarted:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:AUILiveCameraPushString(@"开始推流")];
}


- (void)onPushPaused:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:AUILiveCameraPushString(@"暂停")];
}


- (void)onPushResumed:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:AUILiveCameraPushString(@"恢复")];
}


- (void)onPushStoped:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:AUILiveCameraPushString(@"停止推流")];
}


- (void)onFirstFramePreviewed:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:AUILiveCameraPushString(@"首帧渲染")];
}


- (void)onPushRestart:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:AUILiveCameraPushString(@"重新推流")];
}


#pragma mark - AlivcLivePusherBGMDelegate

- (void)onStarted:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:AUILiveCameraPushString(@"BGM Start")];
}


- (void)onStoped:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:AUILiveCameraPushString(@"BGM Stop")];
}


- (void)onPaused:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:AUILiveCameraPushString(@"BGM Pause")];
}


- (void)onResumed:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:AUILiveCameraPushString(@"BGM Resume")];
}


- (void)onProgress:(AlivcLivePusher *)pusher progress:(long)progress duration:(long)duration {
    
    [self.publisherView updateMusicDuration:progress totalTime:duration];
}


- (void)onCompleted:(AlivcLivePusher *)pusher {
    
    [self.publisherView updateInfoText:AUILiveCameraPushString(@"BGM Play Complete")];
}


- (void)onOpenFailed:(AlivcLivePusher *)pusher {
    
    [self.publisherView resetMusicButtonTypeWithPlayError];
    [self showAlertViewWithErrorCode:0
                            errorStr:nil
                                 tag:0
                               title:AUILiveCameraPushString(@"错误提示")
                             message:AUILiveCameraPushString(@"BGM File Open Failed")
                         cancelTitle:AUILiveCommonString(@"确定")
                             okTitle:nil];
}


- (void)onDownloadTimeout:(AlivcLivePusher *)pusher {
    
    [self.publisherView resetMusicButtonTypeWithPlayError];
    [self showAlertViewWithErrorCode:0
                            errorStr:nil
                                 tag:0
                               title:AUILiveCameraPushString(@"错误提示")
                             message:AUILiveCameraPushString(@"BGM Download Timeout")
                         cancelTitle:AUILiveCommonString(@"确定")
                             okTitle:nil];
}

#pragma mark - AlivcLivePusherCustomFilterDelegate
/**
 通知外置滤镜创建回调
 */
- (void)onCreate:(AlivcLivePusher*)pusher context:(void*)context
{
    
}


/**
 通知外置滤镜处理回调
 */
- (int)onProcess:(AlivcLivePusher *)pusher texture:(int)texture textureWidth:(int)width textureHeight:(int)height extra:(long)extra
{
    if (self.beautyOn)
    {
        return [[AUILiveBeautyController sharedInstance] processGLTextureWithTextureID:texture withWidth:width withHeight:height];
    }
    return texture;
}
/**
 通知外置滤镜销毁回调
 */
- (void)onDestory:(AlivcLivePusher*)pusher
{
    [[AUILiveBeautyController sharedInstance] destroyBeautyController];
}

#ifdef ALIVC_LIVE_INTERACTIVE_MODE
- (BOOL)onProcessVideoSampleBuffer:(AlivcLivePusher *)pusher sampleBuffer:(AlivcLiveVideoDataSample *)sampleBuffer
{
    BOOL result = NO;
    if (self.beautyOn)
    {
        result = [[AUILiveBeautyController sharedInstance] processPixelBuffer:sampleBuffer.pixelBuffer withPushOrientation:self.pushConfig.orientation];
    }
    return result;
}
#endif

#pragma mark - AlivcLivePusherCustomDetectorDelegate
/**
 通知外置视频检测创建回调
 */
- (void)onCreateDetector:(AlivcLivePusher *)pusher
{
#if USE_SENSEME
#eif USE_TAOPAI
#else
//    [[AlivcLibFaceManager shareManager] create];
#endif
}
/**
 通知外置视频检测处理回调
 */
- (long)onDetectorProcess:(AlivcLivePusher*)pusher data:(long)data w:(int)w h:(int)h rotation:(int)rotation format:(int)format extra:(long)extra
{
    if (self.beautyOn)
    {
        [[AUILiveBeautyController sharedInstance] detectVideoBuffer:data
                                                        withWidth:w
                                                       withHeight:h
                                                  withVideoFormat:self.pushConfig.externVideoFormat
                                              withPushOrientation:self.pushConfig.orientation];
    }
    return data;
}

/**
 通知外置视频检测销毁回调
 */
- (void)onDestoryDetector:(AlivcLivePusher *)pusher
{
//    [[AlivcLibFaceManager shareManager] destroy];
}

#pragma mark - AlivcLivesNAPSHOTDelegate
- (void)onSnapshot:(AlivcLivePusher *)pusher image:(UIImage *)image
{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    
    
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd-hh-mm-ss-SS"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    NSString* fileName = [NSString stringWithFormat:@"snapshot-%@.png", dateString];
    NSString *filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:
                          [NSString stringWithFormat:fileName]];
    
    BOOL result =[UIImagePNGRepresentation(image)writeToFile:filePath   atomically:YES]; // 保存成功会返回YES
    if (result == YES) {
        NSLog(@"保存成功");
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{

//                [self.view makeToast:@"保存成功"];
//                UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
            __strong typeof(self) strongSelf = weakSelf;
            NSString *tip = [AUILiveCameraPushString(@"截图已保存至") stringByAppendingString:@"：\n"];
            AUILiveFixedOrientationDirAlertController *alertController = [AUILiveFixedOrientationDirAlertController alertControllerWithTitle:nil message:[tip stringByAppendingString:filePath] preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:AUILiveCommonString(@"确定") style:UIAlertActionStyleCancel handler:nil]];
            [strongSelf presentViewController:alertController animated:YES completion:nil];
        });

    }
}

#pragma mark - 退后台停止推流的实现方案

- (void)addBackgroundNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

}


- (void)applicationWillResignActive:(NSNotification *)notification {

    if (!self.livePusher) {
        return;
    }
    
    // 如果退后台不需要继续推流，则停止推流
    if ([self.livePusher isPushing]) {
        [self.livePusher stopPush];
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {

    if (!self.livePusher) {
        return;
    }
    
    if ([self.publisherView getPushButtonType]) {
        // 当前是推流模式，恢复推流
        [self.livePusher startPushWithURLAsync:self.pushURL];
    }
}

#pragma mark - AUILiveCameraPublishViewDelegate

- (void)publisherOnClickedBackButton {
    [self cancelTimer];
    [self destoryPusher];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self dismissViewControllerAnimated:NO completion:nil];
}


- (int)publisherOnClickedPreviewButton:(BOOL)isPreview button:(UIButton *)sender {
    
    int ret = 0;
    
    if (isPreview) {
        ret = [self startPreview];
        if (ret != 0) {
            [self showPusherStartPreviewErrorAlert:ret isStart:YES];
            [sender setSelected:!sender.selected];
        }
    } else {
        ret = [self stopPreview];
        if (ret != 0) {
            [self showPusherStartPreviewErrorAlert:ret isStart:NO];
            [sender setSelected:!sender.selected];
        }
    }
    
    return ret;
}

- (BOOL)publisherOnClickedPushButton:(BOOL)isPush button:(UIButton *)sender {
    
    if (isPush) {
        // 开始推流
        int ret = [self startPush];
        if (ret != 0) {
            [self showPusherStartPushErrorAlert:ret isStart:YES];
            [sender setSelected:!sender.selected];
            return NO;
        }
        return YES;
    } else {
        // 停止推流
        int ret = [self stopPush];
        if (ret != 0) {
            [self showPusherStartPushErrorAlert:ret isStart:NO];
            [sender setSelected:!sender.selected];
            return NO;
        }
        return YES;
    }
}

- (void)publisherOnClickedPauseButton:(BOOL)isPause button:(UIButton *)sender {
    
    if (isPause) {
        int ret = [self pausePush];
        if (ret != 0) {
            [self showPusherPausePushErrorAlert:ret isPause:YES];
            [sender setSelected:!sender.selected];
        }

    } else {
        int ret = [self resumePush];
        if (ret != 0) {
            [self showPusherPausePushErrorAlert:ret isPause:NO];
            [sender setSelected:!sender.selected];
        }
    }
}


- (int)publisherOnClickedRestartButton {
    
    int ret = [self restartPush];
    if (ret != 0) {
        
        [self showAlertViewWithErrorCode:ret
                                errorStr:nil
                                     tag:0
                                   title:AUILiveCameraPushString(@"错误提示")
                                 message:@"Restart Error"
                             cancelTitle:AUILiveCommonString(@"确定")
                                 okTitle:nil];
    }
    
    return ret;
}

- (void)publisherOnClickedWaterMarkButton {
    
    NSString *watermarkBundlePath = [[NSBundle bundleWithPath:[NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:@"AUILiveCameraPush.bundle/Theme/DarkMode"]] pathForResource:@"watermark" ofType:@"png"];
    
    int ret = 0;
    if(waterMarkCount % 3 == 0)
    {
        if(self.livePusher)
        {
            ret = [self.livePusher addWatermarkWithPath:watermarkBundlePath watermarkCoordX:0.1 watermarkCoordY:0.1 watermarkWidth:0.2];
        }
    }
    else if(waterMarkCount % 3 == 1)
    {
        if(self.livePusher)
        {
            ret = [self.livePusher addWatermarkWithPath:watermarkBundlePath watermarkCoordX:0.4 watermarkCoordY:0.4 watermarkWidth:0.2];
        }
    }
    else if(waterMarkCount % 3 == 2)
    {
        if(self.livePusher)
        {
            ret = [self.livePusher addWatermarkWithPath:watermarkBundlePath watermarkCoordX:0.7 watermarkCoordY:0.7 watermarkWidth:0.2];
        }
    }
    waterMarkCount = waterMarkCount +1 ;
    
    if(ret != 0)
    {
        NSString *message = @"The number of watermarks should not exceed 3";
        [self showAlertViewWithErrorCode:ret
                                errorStr:nil
                                     tag:0
                                   title:AUILiveCameraPushString(@"错误提示")
                                 message:message
                             cancelTitle:AUILiveCommonString(@"确定")
                                 okTitle:nil];
    }
}

- (void)publisherOnClickedRemoveWaterMarkButton{
    if(self.livePusher)
    {
        [self.livePusher setWatermarkVisible:!isShowWaterMark];
        isShowWaterMark = !isShowWaterMark;
    }
}

- (void)publisherOnClickedSwitchCameraButton {
    
    if (self.livePusher) {
        [self.livePusher switchCamera];
    }
}

- (void)publisherOnClickedSnapshotButton {
    
    if (self.livePusher) {
        [self.livePusher snapshot:1 interval:0];
    }
}

- (void)publisherOnClickedFlashButton:(BOOL)flash button:(UIButton *)sender {
    
    if (self.livePusher) {
        [self.livePusher setFlash:flash?true:false];
    }
}

- (void)publisherOnClickedBeautyButton:(BOOL)beautyOn {
    [[AUILiveBeautyController sharedInstance] showPanel:YES];
}

- (void)publisherOnClickedZoom:(CGFloat)zoom {
    
    if (self.livePusher) {
        CGFloat max = [_livePusher getMaxZoom];
        [self.livePusher setZoom:MIN(zoom, max)];
    }
}


- (void)publisherOnClickedFocus:(CGPoint)focusPoint {
    
    if (self.livePusher) {
        [self.livePusher focusCameraAtAdjustedPoint:focusPoint autoFocus:self.isAutoFocus];
    }
}

- (void)publisherOnBitrateChangedTargetBitrate:(int)targetBitrate {
    
    if (self.livePusher) {
        
        int ret = [self.livePusher setTargetVideoBitrate:targetBitrate];
        if (ret != 0) {
            
            [self showAlertViewWithErrorCode:ret
                                    errorStr:nil
                                         tag:0
                                       title:AUILiveCameraPushString(@"错误提示")
                                     message:AUILiveCameraPushString(@"码率参数设置错误！")
                                 cancelTitle:AUILiveCommonString(@"确定")
                                     okTitle:nil];
        }
    }
}


- (void)publisherOnBitrateChangedMinBitrate:(int)minBitrate {
    
    if (self.livePusher) {
        int ret = [self.livePusher setMinVideoBitrate:minBitrate];
    
        if (ret != 0) {
            [self showAlertViewWithErrorCode:ret
                                    errorStr:nil
                                         tag:0
                                       title:AUILiveCameraPushString(@"错误提示")
                                     message:AUILiveCameraPushString(@"码率参数设置错误！")
                                 cancelTitle:AUILiveCommonString(@"确定")
                                     okTitle:nil];
        }
    }
}


- (void)publisherOnClickPushMirrorButton:(BOOL)isPushMirror {
    
    if (self.livePusher) {
        [self.livePusher setPushMirror:isPushMirror?true:false];
    }
}

- (void)publisherOnSelectPreviewDisplayMode:(int)mode {
    if (self.livePusher) {
        [self.livePusher setpreviewDisplayMode:mode];
    }
}

- (void)publisherOnSelectAudioEffectsVoiceChangeMode:(NSInteger)mode {
    if (self.livePusher) {
        [self.livePusher setAudioEffectVoiceChangeMode:mode];
    }
}

- (void)publisherOnSelectAudioEffectsReverbMode:(NSInteger)mode {
    if (self.livePusher) {
        [self.livePusher setAudioEffectReverbMode:mode];
    }
}

- (void)publisherOnClickPreviewMirrorButton:(BOOL)isPreviewMorror {
    
    if (self.livePusher) {
        [self.livePusher setPreviewMirror:isPreviewMorror?true:false];
    }
}


- (void)publisherOnClickAutoFocusButton:(BOOL)isAutoFocus {
    
    if (self.livePusher) {
        [self.livePusher setAutoFocus:isAutoFocus?true:false];
        self.isAutoFocus = isAutoFocus;
    }
}

- (int)publisherOnClickAddDynamically:(NSString *)path x:(float)x y:(float)y w:(float)w h:(float)h
{
    if (self.livePusher) {
        return [self.livePusher addDynamicWaterMarkImageDataWithPath:path x:x y:y w:w h:h];
    }
    return -1;
}

- (void)publisherOnClickRemoveDynamically:(int)vid
{
    if (self.livePusher) {
        [self.livePusher removeDynamicWaterMark:vid];
    }
}


#pragma mark - AUILiveMusicViewDelegate

- (void)musicOnClickPlayButton:(BOOL)isPlay musicPath:(NSString *)musicPath {
    
    if (self.livePusher) {
        if (isPlay) {
            [self.livePusher startBGMWithMusicPathAsync:musicPath];
        } else {
            [self.livePusher stopBGMAsync];
        }
    }
}

- (void)musicOnClickPauseButton:(BOOL)isPause {
    
    if (self.livePusher) {
        if (isPause) {
            [self.livePusher pauseBGM];
        } else {
            [self.livePusher resumeBGM];
        }
    }
}


- (void)musicOnClickLoopButton:(BOOL)isLoop {
    
    if (self.livePusher) {
        [self.livePusher setBGMLoop:isLoop?true:false];
    }
}


- (void)musicOnClickDenoiseButton:(BOOL)isDenoiseOpen {
    
    if (self.livePusher) {
        [self.livePusher setAudioDenoise:isDenoiseOpen];
    }
}

- (void)musicOnClickIntelligentDenoiseButton:(BOOL)isIntelligentDenoiseOpen {
    if (self.livePusher) {
        if (isIntelligentDenoiseOpen) {
            [self.livePusher startIntelligentDenoise];
        } else {
            [self.livePusher stopIntelligentDenoise];
        }
    }
}

- (void)musicOnClickMuteButton:(BOOL)isMute {
    
    if (self.livePusher) {
        [self.livePusher setMute:isMute?true:false];
    }
}

- (void)musicOnClickEarBackButton:(BOOL)isEarBack {
    
    if (self.livePusher) {
        [self.livePusher setBGMEarsBack:isEarBack?true:false];
    }
}

- (void)musicOnSliderAccompanyValueChanged:(int)value {
    
    if (self.livePusher) {
        [self.livePusher setBGMVolume:value];
    }
}

- (void)musicOnSliderVoiceValueChanged:(int)value {
    
    if (self.livePusher) {
        [self.livePusher setCaptureVolume:value];
    }
}

#pragma mark - AlivcLiveBaseObserver
- (void)onLicenceCheck:(AlivcLiveLicenseCheckResultCode)result Reason:(NSString *)reason
{
    NSLog(@"LicenceCheck %ld, reason %@", (long)result, reason);
    if(result != AlivcLiveLicenseCheckResultCodeSuccess)
    {
        NSString *showMessage = [NSString stringWithFormat:@"License Error: code:%ld message:%@", (long)result, reason];

        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            AUILiveFixedOrientationDirAlertController *alert = [AUILiveFixedOrientationDirAlertController alertControllerWithTitle:AUILiveCameraPushString(@"License错误") message:showMessage preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:AUILiveCommonString(@"确定") style:UIAlertActionStyleCancel handler:nil]];
            [strongSelf presentViewController:alert animated:YES completion:nil];
        });
    }
}

#pragma mark - AUILiveAnswerGameViewDelegate

- (void)answerGameOnSendQuestion:(NSString *)question questionId:(NSString *)questionId {
    
    if (self.livePusher) {
        // 先插入SEI信息到流里面，在对server做一个请求告知发送题目
        int ret = [self.livePusher sendMessage:question repeatCount:100 delayTime:0 KeyFrameOnly:false];
        if (ret != 0) {
            [self showAlertViewWithErrorCode:ret
                                    errorStr:nil
                                         tag:0
                                       title:AUILiveCameraPushString(@"错误提示")
                                     message:@"Send Question Error"
                                 cancelTitle:AUILiveCommonString(@"确定")
                                     okTitle:nil];
            return;
        }
        
        [self sendAnswerPostWithQuestionId:questionId expiredSeconds:@"100"];
    }
}



- (void)answerGameOnSendAnswer:(NSString *)answer duration:(NSInteger)duration {
    
    if (self.livePusher) {
        int repeatCount = (int)duration*self.pushConfig.fps;
        int ret = [self.livePusher sendMessage:answer repeatCount:repeatCount delayTime:0 KeyFrameOnly:false];
        if (ret != 0) {
            [self showAlertViewWithErrorCode:ret
                                    errorStr:nil
                                         tag:0
                                       title:AUILiveCameraPushString(@"错误提示")
                                     message:@"Send Answer Error"
                                 cancelTitle:AUILiveCommonString(@"确定")
                                     okTitle:nil];
        }
    }
}


- (void)sendAnswerPostWithQuestionId:(NSString *)questionId expiredSeconds:(NSString *)expiredSeconds {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://101.132.137.92/mgr/pushQuestion"]];
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";

    // lieId对应为播放端的拉流地址 去掉rtmp头 去掉authKey
    NSString *urlSting = self.pushURL;
    if ([urlSting containsString:@"auth_key"]) {
        urlSting = [[urlSting componentsSeparatedByString:@"?auth_key"] firstObject];
    }
    NSString *liveId = [[[urlSting componentsSeparatedByString:@"rtmp://"] lastObject] stringByReplacingOccurrencesOfString:@"push" withString:@"pull"];
    NSDictionary *param = @{@"liveId":liveId,
                            @"questionId":questionId,
                            @"expiredSeconds":@(15),
                            @"seiDelay":@(2000),
                            @"noSEI":@"true"};
    
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [self showAlertViewWithErrorCode:error.code
                                        errorStr:error.description
                                             tag:0
                                           title:@"Error"
                                         message:@"Request Answer Game HTTP Error"
                                     cancelTitle:AUILiveCommonString(@"确定")
                                         okTitle:nil];
            } else {
                [self.publisherView updateInfoText:AUILiveCameraPushString(@"Request Answer Game HTTP  Success")];
            }
        });
    }];
    [sessionDataTask resume];
}

#pragma - UI
- (void)setupSubviews {
    
    self.view.backgroundColor = [UIColor grayColor];
    [self.view addSubview: self.previewView];
    [self.view addSubview: self.publisherView];
}

- (void)showPusherInitErrorAlert:(int)error {
    
    [self showAlertViewWithErrorCode:error
                            errorStr:nil
                                 tag:kAlivcLivePusherVCAlertTag+31
                               title:AUILiveCameraPushString(@"错误提示")
                             message:@"Init AlivcLivePusher Error"
                         cancelTitle:AUILiveCameraPushString(@"退出")
                             okTitle:nil];
}

- (void)showPusherStartPreviewErrorAlert:(int)error isStart:(BOOL)isStart {
    
    NSString *message = @"Stop Preview Error";
    NSInteger tag = 0;
    if (isStart) {
        message = @"Start Preview Error";
        tag = kAlivcLivePusherVCAlertTag+32;
    }
    
    [self showAlertViewWithErrorCode:error
                            errorStr:nil
                                 tag:tag
                               title:AUILiveCameraPushString(@"错误提示")
                             message:message
                         cancelTitle:AUILiveCommonString(@"确定")
                             okTitle:nil];
}


- (void)showPusherStartPushErrorAlert:(int)error isStart:(BOOL)isStart {
    
    NSString *message = @"Stop Push Error";
    if (isStart) {
        message = @"Start Push Error";
    }

    [self showAlertViewWithErrorCode:error
                            errorStr:nil
                                 tag:0
                               title:AUILiveCameraPushString(@"错误提示")
                             message:message
                         cancelTitle:AUILiveCommonString(@"确定")
                             okTitle:nil];
}


- (void)showPusherPausePushErrorAlert:(int)error isPause:(BOOL)isPause {
    
    NSString *message = @"Pause Error";
    if (isPause) {
        message = @"Resume Error";
    }
    
    [self showAlertViewWithErrorCode:error
                            errorStr:nil
                                 tag:0
                               title:AUILiveCameraPushString(@"错误提示")
                             message:message
                         cancelTitle:AUILiveCommonString(@"确定")
                             okTitle:nil];
}


- (void)setupDefaultValues {
    
    self.isAutoFocus = self.pushConfig.autoFocus;
}

- (void)showAlertViewWithErrorCode:(NSInteger)errorCode errorStr:(NSString *)errorStr tag:(NSInteger)tag title:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle okTitle:(NSString *)okTitle {
    
    if (errorCode == ALIVC_LIVE_PUSHER_PARAM_ERROR) {
        errorStr = AUILiveCameraPushString(@"接口输入参数错误");
    }
    
    if (errorCode == ALIVC_LIVE_PUSHER_SEQUENCE_ERROR) {
        errorStr = AUILiveCameraPushString(@"接口调用顺序错误");
    }
    
    if(errorCode == ALIVC_LIVE_PUSHER_RTC_NOT_SUPPORT_AUDIO_OR_VIDEOONLY_PUSH) {
        errorStr = AUILiveCameraPushString(@"RTC协议暂不支持推纯音频或纯视频流");
    }
    
    NSString *showMessage = [NSString stringWithFormat:@"%@: code:%lx message:%@", message, errorCode, errorStr];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        AUILiveFixedOrientationDirAlertController *alert = [AUILiveFixedOrientationDirAlertController alertControllerWithTitle:title
                                                                       message:showMessage
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        if (okTitle && okTitle.length > 0) {
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:okTitle
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                if (tag == kAlivcLivePusherVCAlertTag+22 ||
                    tag == kAlivcLivePusherVCAlertTag+23) {
                    [strongSelf publisherOnClickedBackButton];
                }
            }];
            [alert addAction:okAction];
        }
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * _Nonnull action) {
            if (tag == kAlivcLivePusherVCAlertTag+11 ||
                tag == kAlivcLivePusherVCAlertTag+12 ||
                tag == kAlivcLivePusherVCAlertTag+31 ||
                tag == kAlivcLivePusherVCAlertTag+32 ||
                tag == kAlivcLivePusherVCAlertTag+33) {
                [strongSelf publisherOnClickedBackButton];
            }
            
            if (tag == kAlivcLivePusherVCAlertTag+22 ||
                tag == kAlivcLivePusherVCAlertTag+23) {
                [strongSelf reconnectPush];
            }
        }];
        [alert addAction:cancelAction];
        [strongSelf presentViewController:alert animated:YES completion:nil];
    });
}


#pragma mark - Timer

- (void)setupDebugTimer {
    
    self.noticeTimer = [NSTimer scheduledTimerWithTimeInterval:kAlivcLivePusherNoticeTimerInterval target:self selector:@selector(noticeTimerAction:) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:self.noticeTimer forMode:NSDefaultRunLoopMode];
}

- (void)cancelTimer{
    
    if (self.noticeTimer) {
        [self.noticeTimer invalidate];
        self.noticeTimer = nil;
    }
}


- (void)noticeTimerAction:(NSTimer *)sender {
    
    if (!self.livePusher) {
        return;
    }

    BOOL isPushing = [self.livePusher isPushing];
    NSString *text = @"";
    if (isPushing) {
        text = [NSString stringWithFormat:@"%@:%@|%@:%@",AUILiveCameraPushString(@"推流中"), isPushing?@"YES":@"NO", AUILiveCameraPushString(@"推流中"), [self.livePusher getPushURL]];
    } else {
        // 未推流
        text = [NSString stringWithFormat:@"%@",AUILiveCameraPushString(@"未推流")];
    }

    [self.publisherView updateInfoText:text];
    [self monitorInfo];
}

- (void)publisherDataMonitorView {
    self.monitorView.hidden =  !self.monitorView.hidden;
}

- (void)monitorInfo{
    AlivcLivePushStatsInfo *info = [self.livePusher getLivePushStatusInfo];
    self.monitorView.titleLabel.text = AUILiveCameraPushString(@"本地视频统计信息");
    self.monitorView.sentBitrateLabel.text = [NSString stringWithFormat:@"%@ %d kbps",AUILiveCameraPushString(@"发送码率："), info.videoEncodedBitrate];
    self.monitorView.sentFpsLabel.text = [NSString stringWithFormat:@"%@ %d fps",AUILiveCameraPushString(@"编码帧率："),info.videoEncodedFps];
//    self.monitorView.encodeFpsLabel.text = [NSString stringWithFormat:@"编码帧率：%d fps",info.videoEncodedFps];
}

#pragma mark - 懒加载

- (AUILiveCameraPublishView *)publisherView {
    
    if (!_publisherView) {
        _publisherView = [[AUILiveCameraPublishView alloc] initWithFrame:[self getFullScreenFrame]
                                                            config:self.pushConfig];
        [_publisherView setPushViewsDelegate:self];
        _publisherView.backgroundColor = [UIColor clearColor];
    }
    return _publisherView;
}

- (UIView *)previewView {
    
    if (!_previewView) {
        _previewView = [[UIView alloc] init];
        _previewView.backgroundColor = [UIColor clearColor];
        _previewView.frame = [self getFullScreenFrame];
    }
    return _previewView;
}


- (CGRect)getFullScreenFrame {
    
    CGRect frame = self.view.bounds;
    if ([UIView av_isIphoneX]) {
        // iPhone X UI适配
        frame = CGRectMake(0, 0, AlivcScreenWidth, AlivcScreenHeight);
    }
    if (self.pushConfig.orientation != AlivcLivePushOrientationPortrait) {
        CGFloat temSize = frame.size.height;
        frame.size.height = frame.size.width;
        frame.size.width = temSize;
        
        CGFloat temPoint = frame.origin.y;
        frame.origin.y = frame.origin.x;
        frame.origin.x = temPoint;

    }
    return frame;
}


#pragma mark - Auth

// 以下为测试鉴权使用，一般场景下，建议使用APPServer下发推流地址。Auth计算参考官方文档
- (void)updateAuthURL {
    
    if (self.authKey && self.authDuration) {
        // 开启测试鉴权的情况下，拼接鉴权A类型URL
        NSString *authPushURL = [self getAuthTestPushURLWithDuation:[self.authDuration integerValue] authKey:self.authKey];
        self.pushURL = authPushURL;
    }
}

- (NSString *)getAuthTestPushURLWithDuation:(NSInteger)duration authKey:(NSString *)authKey {
    
    NSString *basePushURL = [[self.pushURL componentsSeparatedByString:@"?auth_key="] firstObject];
    NSInteger currentTime = [[NSDate date] timeIntervalSince1970];
    
    NSInteger timestamp = currentTime + duration;
    
    NSString *uri = [[self.pushURL componentsSeparatedByString:@"push-videocall.aliyuncs.com"] lastObject];
    NSString *hash = [self MD5ForLower32Bate:[NSString stringWithFormat:@"%@-%ld-0-0-%@",uri, timestamp, authKey]];
    
    NSString *newPushURL = [NSString stringWithFormat:@"%@?auth_key=%ld-0-0-%@", basePushURL, timestamp, hash];
    NSLog(@"lyz - new push url:%@", newPushURL);
    return newPushURL;
}


- (NSString *)MD5ForLower32Bate:(NSString *)str{
    
    //要进行UTF8的转码
    const char* input = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    
    return digest;
}

#pragma mark -- lazy load
- (AUILiveExternMainStreamManager *)userMainStreamManager {
    if (!_userMainStreamManager) {
        _userMainStreamManager = [[AUILiveExternMainStreamManager alloc] init];
        _userMainStreamManager.pushConfig = self.pushConfig;
        _userMainStreamManager.livePusher = self.livePusher;
    }
    return _userMainStreamManager;
}

@end
