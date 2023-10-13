//
//  AlivcPlayerManager.m
//  AFNetworking
//
//  Created by mengyehao on 2021/7/2.
//

#import "AlivcPlayerManager.h"

#import "AlivcPlayerSysToken.h"

#import "AlivcPlayerPlayPluginManager.h"
#import "AlivcPlayerEventCenter.h"
#import "AUIPlayerPlayViewLayerManager.h"

#import "AlivcPlayerBottomToolPlugin.h"
#import "AlivcPlayerLandscapePlugin.h"
#import "AlivcPlayerPlayControlPlugin.h"
#import "AlivcPlayerGesturePlugin.h"
#import "AlivcPlayerLockPlugin.h"
#import "AlivcPlayerTopToolPlugin.h"
#import "AlivcPlayerBackgroudModePlugin.h"
#import "AlivcPlayerListenPlugin.h"


#import "AlivcPlayerAccountManager.h"
#import "AlivcPlayerVideoDBManager.h"
#import "UIView+AUIPlayerHelper.h"
#import "AlivcPlayerRotateAnimator.h"
#import "AUIPlayerPlayContainViewPluginInstallProtocol.h"

#define kToolTimerInterval 5
#define AlivcPlayerFirstLaunch_AUIVideoFlow_speedTipKey @"AlivcPlayerFirstLaunch_AUIVideoFlow_speedTipKey"
#define AlivcPlayerFirstLaunch_AUIVideoFlow_FullScreenSpeedTipKey @"AlivcPlayerFirstLaunch_AUIVideoFlow_FullScreenSpeedTipKey"
#define AlivcPlayerFirstLaunch_AUIVideoFlow_FirstLandsacpeSpeedTipKey @"AlivcPlayerFirstLaunch_AUIVideoFlow_FirstLandsacpeSpeedTipKey"

@interface AlivcPlayerManager()<AVPDelegate>

@property (nonatomic, strong) AlivcPlayerPlayPluginManager *pluginManager;
@property (nonatomic, strong) AlivcPlayerEventCenter *eventCenter;
@property (nonatomic, strong) AliListPlayer *player;
@property (nonatomic, strong) AUIPlayerPlayViewLayerManager *layerManager;



@property (nonatomic, strong) AlivcPlayerSysToken *tokenInfo;




@property (nonatomic, strong) NSTimer *toolHiddenTimer;



@property (nonatomic, strong) NSMutableArray<NSDictionary *> *allPlayerContext;

@property (nonatomic, copy) NSString *currentVideoId;

@property (nonatomic, assign) AVPStatus playerStatus;

@property (nonatomic, assign) AVPEventType playerEventType;




@end



@implementation AlivcPlayerManager

@synthesize disableVideo = _disableVideo;

static AlivcPlayerManager *manager = nil;
static dispatch_once_t onceToken;

+ (instancetype)manager
{
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (void)destroyIncludePlayer:(BOOL)destroyPlayer {
    if (_eventCenter) {
        _eventCenter = nil;
    }
    if (_pluginManager) {
        _pluginManager = nil;
    }
    if (_layerManager) {
        _layerManager = nil;
    }
    if (_tokenInfo) {
        _tokenInfo = nil;
    }
    
    if (_toolHiddenTimer) {
        _toolHiddenTimer = nil;
    }
    
    if (_allPlayerContext) {
        [_allPlayerContext removeAllObjects];
        _allPlayerContext = nil;
    }
    
    if (_player) {
        [self.player stop];
        if (destroyPlayer) {
            [self.player destroy];
        }
        _player = nil;
    }
    
    onceToken = 0;
    manager = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (NSMutableArray<NSDictionary *> *)allPlayerContext
{
    if (!_allPlayerContext) {
        _allPlayerContext = [NSMutableArray array];
    }
    return _allPlayerContext;
}

- (void)setup
{
    _eventCenter = [[AlivcPlayerEventCenter alloc] init];
    _pluginManager = [[AlivcPlayerPlayPluginManager alloc] init];
    _layerManager = [[AUIPlayerPlayViewLayerManager alloc] init];
    _tokenInfo = [[AlivcPlayerSysToken alloc] init];
    [_tokenInfo refreshToken];
    
    [self setupPalyer];
    [self addNotifications];
}

- (void)setupPalyer
{
    _player = [[AliListPlayer alloc] init];
    _player.scalingMode = AVP_SCALINGMODE_SCALEASPECTFIT;
    _player.delegate = self;
    _player.playerView = [self viewAtLevel:0];
    _player.autoPlay = YES;
    // _player.preloadCount = 5;
    _player.stsPreloadDefinition = @"SD";//720p
    [_player setMaxAccurateSeekDelta:30];

    
    AVPConfig *config = [[AVPConfig alloc] init];
    config.clearShowWhenStop = YES;
    [_player setConfig:config];

//    AVPCacheConfig *cacheConfig = [[AVPCacheConfig alloc] init];
//    //开启缓存功能
//    cacheConfig.enable = YES;
//    //能够缓存的单个文件最大时长。超过此长度则不缓存
//    cacheConfig.maxDuration = 60 * 10;
//    //缓存目录的位置，需替换成app期望的路径
//    //NSString *cachePath = [NSDocumentDirectory() stringByAppendingPathComponent:@"AlivcPlayerDemo/AUIPlayerFlow/cache"];
//    //cacheConfig.path = cachePath;
//    //缓存目录的最大大小。超过此大小，将会删除最旧的缓存文件
//    cacheConfig.maxSizeMB = 200;
//    //设置缓存配置给到播放器
//    [self.player setCacheConfig:cacheConfig];

    _controlToolHidden = YES;
    _backgroudModeEnabled = YES;
    _autoPlayInList = YES;
    // zzy 20220630 暂时注释功能
    // _barrageEnabled = YES;
    // zzy 20220630 暂时注释功能
}


#pragma mark - AlivcPlayerPluginManagerProtocol

- (void)registerPlugin:(NSString *)pluginId
{
    if (![self containsPlugin:pluginId]) {
        [self.pluginManager registerPlugin:pluginId];
    }
}

- (void)unRegisterPlugin:(NSString *)pluginId
{
    [self.pluginManager unRegisterPlugin:pluginId];
}

- (BOOL)containsPlugin:(NSString *)pluginId
{
    return  [self.pluginManager containsPlugin:pluginId];
}

- (NSArray<NSString *> *)currentPluginIDList
{
    return [self.pluginManager currentPluginIDList];
}

- (AlivcPlayerBasePlugin *)pluginWithId:(NSString *)pluginId
{
    return [[self pluginManager] pluginWithId:pluginId];
}

#pragma mark - Setter

- (void)setCurrentOrientation:(AlivcPlayerEventCenterTypeOrientation)currentOrientation
{
    if(![AlivcPlayerManager manager].playContainView.window)
    {
        return;
    }
    
    if (_currentOrientation != currentOrientation) {
        _currentOrientation = currentOrientation;
        
        [self dispatchEvent:AlivcPlayerEventCenterTypeOrientationChanged userInfo:@{@"orientation": @(currentOrientation)}];
    }
}

- (void)setCurrentOrientationForceDisPatch:(AlivcPlayerEventCenterTypeOrientation)currentOrientation
{
    _currentOrientation = currentOrientation;
    
    [self dispatchEvent:AlivcPlayerEventCenterTypeOrientationChanged userInfo:@{@"orientation": @(currentOrientation)}];
}

- (void)setLock:(BOOL)lock
{
    if (_lock != lock) {
        _lock = lock;
        [self stopToolHiddenTimer];
        [self startToolHiddenTimer];
        [self dispatchEvent:AlivcPlayerEventCenterTypeLockChanged userInfo:@{@"lock":@(lock)}];
    }
}

- (void)setControlToolHidden:(BOOL)controlToolHidden
{
    if (_controlToolHidden != controlToolHidden) {
        
        _controlToolHidden = controlToolHidden;
        [self dispatchEvent:AlivcPlayerEventCenterTypeControlToolHiddenChanged userInfo:@{@"hidden":@(self.controlToolHidden)}];
        if (!controlToolHidden) {
            [self startToolHiddenTimer];
        } else {
            [self stopToolHiddenTimer];
        }
    }
}

- (void)startToolHiddenTimer
{
    [self stopToolHiddenTimer];
    _toolHiddenTimer = [NSTimer scheduledTimerWithTimeInterval:kToolTimerInterval target:self selector:@selector(onToolTimerCutDown) userInfo:nil repeats:NO];
}

- (void)stopToolHiddenTimer
{
    [_toolHiddenTimer invalidate];
    _toolHiddenTimer = nil;
}

- (void)onToolTimerCutDown
{
    [self setControlToolHidden:YES];
}

- (void)setBackgroudModeEnabled:(BOOL)backgroudModeEnabled
{
    if (_backgroudModeEnabled != backgroudModeEnabled) {
        _backgroudModeEnabled = backgroudModeEnabled;
        
        [self dispatchEvent:AlivcPlayerEventCenterTypePlayerBackModeEnabledChanged userInfo:nil];
    }
}

- (void)setPlayScene:(ApPlayerScene)playScene
{
    if (_playScene != playScene) {
        _playScene = playScene;
        
        [self dispatchEvent:AlivcPlayerEventCenterPlaySceneChanged userInfo:nil];
    }
}

#pragma mark - AlivcPlayerPlayer

- (void)startPlayWithVid:(NSString *)vid
{
    if (![vid isKindOfClass:NSString.class]) {
        return;
    }
        
    [self.allPlayerContext removeAllObjects];
    
    //切换的时候保存进度
    [self saveToLocal:self.currentVideoId];
        
    AVPVidStsSource *source = [[AVPVidStsSource alloc] initWithVid:vid accessKeyId:self.tokenInfo.accessKeyId accessKeySecret:self.tokenInfo.accessKeySecret securityToken:self.tokenInfo.securityToken region:@""];
    [self.player setStsSource:source];
    [self.player prepare];
    self.currentVideoId = vid;
    self.playContainView.hidden = YES;
}

- (void)pause
{
    //暂停保存进度
    [self saveToLocal:self.currentVideoId];
    
    [self.player pause];
}

- (void)resume
{    
    [self.player start];
}

- (void)stop
{
    //停止播放保存进度
    [self saveToLocal:self.currentVideoId];
    
    [self.player stop];
}

//- (void)destroyPlayer {
//    if (self.playerStatus != AVPStatusStopped) {
//        [self.player stop];
//    }
//    [self.player destroy];
//}

- (void)seekToTimeProgress:(CGFloat)progress seekMode:(AVPSeekMode)seekMode
{
    int64_t time = progress * self.player.duration ;
    [self.player seekToTime:time seekMode:seekMode];
    
}

- (void)getThumbnail:(CGFloat)progress {
    int64_t positionMs = progress * self.player.duration ;
    if (self.currentOrientation == AlivcPlayerEventCenterTypeOrientationPortrait) {
        [self.eventCenter dispatchEvent:AlivcPlayerEventCenterTypeSliderDragAction userInfo:@{@"changeThumbail": @(NO), @"portrait":@(YES), @"position":@(positionMs), @"duration": @(self.player.duration)}];
    } else {
        if (self.trackHasThumbnai) {
            [self.player getThumbnail:positionMs];
        } else {
            [self.eventCenter dispatchEvent:AlivcPlayerEventCenterTypeSliderDragAction userInfo:@{@"changeThumbail": @(NO), @"portrait":@(NO), @"position":@(positionMs), @"duration": @(self.player.duration)}];
        }
    }
}

- (int64_t)duration
{
    return self.player.duration;
}

- (int64_t)currentPosition
{
    return self.player.currentPosition;
}
- (AVPMediaInfo *)getMediaInfo
{
    return self.player.getMediaInfo;
}

-(AVPTrackInfo*) getCurrentTrack:(AVPTrackType)type
{
    AVPTrackInfo *info = [self.player getCurrentTrack:type];
    return info;
}

-(void)selectTrack:(AVPTrackInfo *)info
{
//    [self saveToLocal:self.currentVideoId];
//
//    _autoTrack = info.trackIndex == -1;
//    if (_autoTrack) {
//        info.videoHeight = 720;
//    }
//
//    if (!self.allPlayerContext.count) {
//        AVPTrackInfo *currentTrack = [self getCurrentTrack:AVPTRACK_TYPE_SAAS_VOD];
//        if (currentTrack.videoHeight != info.videoHeight) {
//            self.isChangedingTrack = YES;
//            [self.player selectTrack:info.trackIndex];
//        }
//    } else {
//
//        NSString *key = info.trackDefinition;
//        if ([key isEqualToString:@"AUTO"]) {
//            key = @"SD";
//        }
//
//        if (![_player.stsPreloadDefinition isEqualToString:key]) {
//
//            NSString *videoId = self.currentVideoId;
//            NSString *currentUuid = [self currentUuid];
//
//            [self.player clear];
//
//            _player.stsPreloadDefinition = key;
//
//            NSLog(@"Trackkey:%@",key);
//            self.isChangedingTrack = YES;
//
//            [self.allPlayerContext enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                [self.player addVidSource:obj.allValues.firstObject uid:obj.allKeys.firstObject];
//
//            }];
//
//            [self moveToVideoId:videoId uuid:currentUuid];
//        }
//    }
    
    
}

- (void)setRate:(float)rate
{
    self.player.rate = rate;
}

- (float)rate
{
    return self.player.rate;
}

- (void)setVolume:(float)volume
{
    [self.player setVolume:volume];
}

- (float)volume
{
    return self.player.volume;
}

- (void)setDisableVideo:(BOOL)disableVideo
{
    
    if (_disableVideo != disableVideo) {
        _disableVideo = disableVideo;
        [self dispatchEvent:AlivcPlayerEventCenterTypePlayerDisableVideoChanged userInfo:nil];
    }
}

- (void)setHideAutoOrientation:(BOOL)hideAutoOrientation {
    _hideAutoOrientation = hideAutoOrientation;
    if (hideAutoOrientation) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUIDeviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
}

- (BOOL)isHideSpeedTip {
    return ![[NSUserDefaults standardUserDefaults] boolForKey:AlivcPlayerFirstLaunch_AUIVideoFlow_speedTipKey];
}
- (void)hideSpeedTip {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:AlivcPlayerFirstLaunch_AUIVideoFlow_speedTipKey];
}

- (BOOL)isHideFullScreenSpeedTip {
    return ![[NSUserDefaults standardUserDefaults] boolForKey:AlivcPlayerFirstLaunch_AUIVideoFlow_FullScreenSpeedTipKey];
}

- (void)hideFullScreenSpeedTip {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:AlivcPlayerFirstLaunch_AUIVideoFlow_FullScreenSpeedTipKey];
}

- (BOOL)isHideFirstLandsacpeSpeedTip {
    return ![[NSUserDefaults standardUserDefaults] boolForKey:AlivcPlayerFirstLaunch_AUIVideoFlow_FirstLandsacpeSpeedTipKey];
}

- (void)hideFirstLandsacpeSpeedTip {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:AlivcPlayerFirstLaunch_AUIVideoFlow_FirstLandsacpeSpeedTipKey];
}

- (void)setPageEventFrom:(AlivcPlayerPageEventFrom)pageEventFrom {
    if (_pageEventFrom != pageEventFrom &&
        (pageEventFrom == AlivcPlayerPageEventFromDetailPage ||
         pageEventFrom == AlivcPlayerPageEventFromFullScreenPlayPage)) {
        _pageEventFrom = pageEventFrom;
        [self.eventCenter dispatchEvent:AlivcPlayerEventCenterTypeSpeedTipShowAction userInfo:nil];
    } else {
        _pageEventFrom = pageEventFrom;
    }
}

#pragma mark - AlivcPlayerListPlayer

- (void)addVidSource:(NSString *)vid uuid:(NSString *)uuid
{
    [self.player addVidSource:vid uid:uuid];
    if (vid && uuid) {
        [self.allPlayerContext addObject:@{uuid:vid}];
    }
}

- (void)removeSource:(NSString *)uuid
{
    [self.player removeSource:uuid];
    
    for (NSDictionary *dict in self.allPlayerContext) {
        if ([dict.allKeys.firstObject isEqual:uuid]) {
            [self.allPlayerContext removeObject:dict];
            break;
        }
    }
   
}

- (void)clearScreen {
    [self.player clearScreen];
}

- (void)clear
{
    [self.player clear];
    [self.allPlayerContext removeAllObjects];
    self.playerSourceList = nil;
}

- (NSString *)currentUuid
{
    return [[self player] currentUid];
}

- (BOOL)containVideoId:(NSString *)videoId uuid:(NSString *)uuid
{
    if (!videoId) {
        return NO;
    }
    if (!uuid) {
        return NO;
    }
    NSDictionary *temp = [NSDictionary dictionaryWithObject:videoId forKey:uuid];
    
    for (NSDictionary *dict in self.allPlayerContext) {
        if ([dict isEqual:temp]) {
            return YES;
        }
    }
    return NO;

}

- (BOOL)moveToVideoId:(NSString *)videoId uuid:(NSString *)uuid
{
    
    NSLog(@"moveToVideoId:%@,uuid:%@",videoId,uuid);
        
    //切换保存进度
    [self saveToLocal:self.currentVideoId];
    
    BOOL ret =  [self.player moveTo:uuid accId:self.tokenInfo.accessKeyId accKey:self.tokenInfo.accessKeySecret token:self.tokenInfo.securityToken region:@""];
    self.currentVideoId = videoId;
    
    self.rate = 1.0;

    return ret;
}

- (BOOL)forceRePlaymoveToVideoId:(NSString *)videoId uuid:(NSString *)uuid
{
    [self stop];
    
    BOOL ret =  [self.player moveTo:uuid accId:self.tokenInfo.accessKeyId accKey:self.tokenInfo.accessKeySecret token:self.tokenInfo.securityToken region:@""];
    self.currentVideoId = videoId;
    
    return ret;
}

#pragma mark - AUIPlayerPlayViewLayerManagerProtocol

- (UIView *)playContainView
{

    return self.layerManager.playContainView;
}

- (UIView *)viewAtLevel:(NSInteger)level
{
    return [self.layerManager viewAtLevel:level];
}

#pragma mark - AlivcPlayerEventCenterProtocol

- (void)dispatchEvent:(AlivcPlayerEventCenterType)eventType userInfo:(NSDictionary *)userInfo
{
    NSString *pluginId  =@"";
    switch (eventType) {
        case AlivcPlayerEventCenterTypePlayerDisableVideoChanged:
        {
            pluginId = @"AlivcPlayerListenPlugin";
        }
            break;
            
            
        default:
            break;
    }
    
    if(pluginId.length && ![self.pluginManager pluginWithId:pluginId]) {
        [self.pluginManager registerPlugin:pluginId];
    }
    [self.eventCenter dispatchEvent:eventType userInfo:userInfo];
}

- (void)addEventObserver:(id<AlivcPlayerPluginEventProtocol>)observer
{
    [self.eventCenter addEventObserver:observer];
}

- (void)removeEventObserver:(id<AlivcPlayerPluginEventProtocol>)observer
{
    [self.eventCenter removeEventObserver:observer];
}

#pragma mark - AVPDelegate

/**
 @brief æ’­æ”¾å™¨äº‹ä»¶å›žè°ƒ
 */
-(void)onPlayerEvent:(AliPlayer*)player eventType:(AVPEventType)eventType
{
    NSLog(@"AliPlayereventType:%ld",eventType);
    
   _playerEventType = eventType;
    
    if (eventType == AVPEventFirstRenderedStart) {
        self.playContainView.hidden = NO;
    } else if (eventType == AVPEventCompletion) {
        self.playContainView.hidden = NO;
        [self saveToLocal:self.currentVideoId];
    }
    [self.eventCenter dispatchEvent:AlivcPlayerEventCenterTypePlayerEventType userInfo:@{@"eventType":@(eventType)}];
}

/**
 @brief æ’­æ”¾å™¨æè¿°äº‹ä»¶å›žè°ƒ
 */
-(void)onPlayerEvent:(AliPlayer*)player eventWithString:(AVPEventWithString)eventWithString description:(NSString *)description
{
    NSLog(@"description:%@",description);

    [self.eventCenter dispatchEvent:AlivcPlayerEventCenterTypePlayerEventTypeWithString userInfo:@{
        @"eventWithString":@(eventWithString),
        @"description":description
    }];
}

/**
 @brief é”™è¯¯ä»£ç†å›žè°ƒ
 */
- (void)onError:(AliPlayer*)player errorModel:(AVPErrorModel *)errorModel
{
    if (errorModel.code == ERROR_SERVER_POP_TOKEN_EXPIRED) {
        [self.tokenInfo refreshToken];
    }
    [self dispatchEvent:AlivcPlayerEventCenterTypePlayerOnAVPError userInfo:@{@"error":errorModel.description?:@"出错啦"}];
}

/**
 @brief è§†é¢‘å¤§å°å˜åŒ–å›žè°ƒ
 */
- (void)onVideoSizeChanged:(AliPlayer*)player width:(int)width height:(int)height rotation:(int)rotation
{
    
}

/**
 @brief è§†é¢‘å½“å‰æ’­æ”¾ä½ç½®å›žè°ƒ
 */
- (void)onCurrentPositionUpdate:(AliPlayer*)player position:(int64_t)position
{
    [self.eventCenter dispatchEvent:AlivcPlayerEventCenterTypePlayerPlayProgress userInfo:@{
        @"position":@(position),
        @"duration":@(player.duration)
    }];
    
}

/**
 @brief è§†é¢‘ç¼“å­˜ä½ç½®å›žè°ƒ
 */
- (void)onBufferedPositionUpdate:(AliPlayer*)player position:(int64_t)position
{
    NSLog(@"BufferedProgress:%ld",position);

    
    [self.eventCenter dispatchEvent:AlivcPlayerEventCenterTypePlayerBufferedProgress userInfo:@{
        @"position":@(position),
        @"duration":@(player.duration)
    }];
    
}

/**
 @brief èŽ·å–trackä¿¡æ¯å›žè°ƒ
 */
- (void)onTrackReady:(AliPlayer*)player info:(NSArray<AVPTrackInfo*>*)info
{
    AVPMediaInfo *mediaInfo = [player getMediaInfo];
    if ((nil != mediaInfo.thumbnails) && (0 < [mediaInfo.thumbnails count])) {
        [player setThumbnailUrl:[mediaInfo.thumbnails objectAtIndex:0].URL];
        self.trackHasThumbnai = YES;
    }else {
        self.trackHasThumbnai = NO;
    }
}

//- (int)onChooseTrackIndex:(AliPlayer *)player info:(NSArray<AVPTrackInfo *> *)info
//{
//
//}

/**
 @brief trackåˆ‡æ¢å®Œæˆå›žè°ƒ
 */
- (void)onTrackChanged:(AliPlayer*)player info:(AVPTrackInfo*)info
{
}

/**
 @brief å¤–æŒ‚å­—å¹•è¢«æ·»åŠ
 */
- (void)onSubtitleExtAdded:(AliPlayer*)player trackIndex:(int)trackIndex URL:(NSString *)URL
{
    
}

/**
 @brief å­—å¹•æ˜¾ç¤ºå›žè°ƒ
 */
- (void)onSubtitleShow:(AliPlayer*)player trackIndex:(int)trackIndex subtitleID:(long)subtitleID subtitle:(NSString *)subtitle
{
    
}

/**
 @brief å­—å¹•éšè—å›žè°ƒ
 */
- (void)onSubtitleHide:(AliPlayer*)player trackIndex:(int)trackIndex subtitleID:(long)subtitleID
{
    
}

/**
 @brief èŽ·å–ç¼©ç•¥å›¾æˆåŠŸå›žè°ƒ
 */
- (void)onGetThumbnailSuc:(int64_t)positionMs fromPos:(int64_t)fromPos toPos:(int64_t)toPos image:(id)image
{
    [self.eventCenter dispatchEvent:AlivcPlayerEventCenterTypeSliderDragAction userInfo:@{@"changeThumbail": @(YES), @"thumbail":image, @"position":@(positionMs), @"duration": @(self.player.duration)}];
}

/**
 @brief èŽ·å–ç¼©ç•¥å›¾å¤±è´¥å›žè°ƒ
 */
- (void)onGetThumbnailFailed:(int64_t)positionMs
{
    [self.eventCenter dispatchEvent:AlivcPlayerEventCenterTypeSliderDragAction userInfo:@{@"changeThumbail": @(NO), @"portrait":@(NO)}];
}

/**
 @brief æ’­æ”¾å™¨çŠ¶æ€æ”¹å˜å›žè°ƒ
 */
- (void)onPlayerStatusChanged:(AliPlayer*)player oldStatus:(AVPStatus)oldStatus newStatus:(AVPStatus)newStatus
{
    NSLog(@"AVPStatus:%ld",newStatus);
    _playerStatus = newStatus;
    
    if (newStatus == AVPStatusStarted) {
        [self registerPluginDelayPlugins];
    }
    
    [self.eventCenter dispatchEvent:AlivcPlayerEventCenterTypePlayerEventAVPStatus userInfo:@{@"status":@(newStatus)}];
    
}

#pragma mark - NSNotificationCenter

- (void)addNotifications
{
    self.hideAutoOrientation = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}


- (void)onUIDeviceOrientationDidChange:(NSNotification *)notification
{
    if (self.lock) {
        NSLog(@"player is locked");
        return;
    }
    
    if ([AlivcPlayerRotateAnimator isAimationing]) {
        NSLog(@"isAimationing");
        return;
    }
    
    
    
    UIDevice* device = notification.object;
    
    if (device.orientation == UIDeviceOrientationPortrait) {
        self.currentOrientation = AlivcPlayerEventCenterTypeOrientationPortrait;
        
    } else if (device.orientation == UIDeviceOrientationLandscapeLeft) {
        self.currentOrientation = AlivcPlayerEventCenterTypeOrientationLandsacpeLeft;
        
    }  else if (device.orientation == UIDeviceOrientationLandscapeRight) {
        self.currentOrientation = AlivcPlayerEventCenterTypeOrientationLandsacpeRight;
    }
}


- (void)onAppWillResignActive:(NSNotification *)notification
{
    if (!self.backgroudModeEnabled) {
        [self.player pause];
    }
}

//- (void)onAppDidBecomeActive:(NSNotification *)notification {
//    [self.player start];
//}


#pragma mark - AlivcPlayerVideoHistoryProtocol

- (void)saveToLocal:(NSString *)videoId
{
    if (videoId.length <= 0) {
        return;
    }
    
    int64_t watchTime = self.player.currentPosition;
    if (self.playerEventType == AVPEventCompletion) {
        watchTime = self.player.duration;
    }
    
    if (watchTime <= 0) {
        return;
    }
    
    
    NSString *userId = [AlivcPlayerAccountManager manager].currentUserId;
    AlivcPlayerVideoDBModel *model = [AlivcPlayerVideoDBModel new];
    model.userId = userId;
    model.videoId = videoId;
    model.watchTime = [NSString stringWithFormat:@"%lld",watchTime];
    [[AlivcPlayerVideoDBManager shareManager] addHistoryTVModel:model];
    
}

- (int64_t)localWatchTime:(NSString *)videoId
{
    if (videoId.length <= 0) {
        return 0;
    }
    NSString *userId = [AlivcPlayerAccountManager manager].currentUserId;
    AlivcPlayerVideoDBModel *model = [[AlivcPlayerVideoDBManager shareManager] getHistoryTVModelFromvideoId:videoId userId:userId];
    return model.watchTime.longLongValue;
    
}


#pragma mark - NextOrProvise

- (void)playNext
{
    NSInteger index = [self findCurrentIndex];
    index += 1;
    if (index < self.playerSourceList.count && index >= 0) {
        NSDictionary *dict = [self.playerSourceList objectAtIndex:index];
        [self moveToVideoId:dict.allValues.firstObject uuid:dict.allKeys.firstObject];
    }

}

- (void)playPre
{
    NSInteger index = [self findCurrentIndex];
    index -= 1;

    if (index >= 0 && index < self.playerSourceList.count) {
        NSDictionary *dict = [self.playerSourceList objectAtIndex:index];
        [self moveToVideoId:dict.allValues.firstObject uuid:dict.allKeys.firstObject];
    }
}

- (BOOL)canPlayNext
{
    NSInteger index = [self findCurrentIndex];
    if (index < 0) {
        return NO;
    }
    
    return index < self.playerSourceList.count-1;
}

- (BOOL)canPlayPre
{
    NSInteger index = [self findCurrentIndex];
    if (index < 0) {
        return NO;
    }
    
    return index > 0;
}

- (NSInteger)findCurrentIndex
{
    NSInteger index = -1;
    for (int i=0;i<self.playerSourceList.count;i++) {
        NSDictionary *dict = self.playerSourceList[i];
        if ([self.currentUuid isEqual:dict.allKeys.firstObject]) {
            index = i;
            break;
        }
    }
    return index;
}

- (void)setPlayerSourceList:(NSArray<NSDictionary<NSString *,NSString *> *> *)playerSourceList
{
 
    
    if (playerSourceList && ![_playerSourceList isEqual:playerSourceList]) {
        _playerSourceList = playerSourceList;
        for (NSDictionary *dict in playerSourceList) {
            [self addVidSource:dict.allValues.firstObject uuid:dict.allKeys.firstObject];
        }
        
        [self dispatchEvent:AlivcPlayerEventCenterTypePlayListSourceDidChanged userInfo:nil];
    } else {
        if (!playerSourceList && _playerSourceList) {
            _playerSourceList = playerSourceList;
            
            [self dispatchEvent:AlivcPlayerEventCenterTypePlayListSourceDidChanged userInfo:nil];

        }
    }
}


- (void)registerPluginDelayPlugins
{
    UIView<AUIPlayerPlayContainViewPluginInstallProtocol> *newSuperview = self.playContainView.superview;
    
    
    if ([newSuperview conformsToProtocol:@protocol(AUIPlayerPlayContainViewPluginInstallProtocol)]) {
        
        if ([newSuperview respondsToSelector:@selector(pluginMap)]) {
            NSDictionary<NSString *, NSNumber*> *dict = [newSuperview performSelector:@selector(pluginMap)];
            NSArray *currentPluginList = [AlivcPlayerManager manager].currentPluginIDList.copy;
            
            NSArray *idlist = dict.allKeys;
            NSArray *values = dict.allValues;
            
            for (int i = 0; i<idlist.count; i++) {
                NSString *pluginId = idlist[i];
                AlivcPlayerBasePluginLoadOption option = [values[i] integerValue];
                if (option == AlivcPlayerBasePluginLoadOptionDelay) {
                    [[AlivcPlayerManager manager] registerPlugin:pluginId];
                }
            }
        }
    }
        
}

@end
