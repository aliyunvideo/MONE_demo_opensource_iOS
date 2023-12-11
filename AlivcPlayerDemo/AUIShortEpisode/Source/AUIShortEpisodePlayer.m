//
//  AUIShortEpisodePlayer.m
//  AlivcPlayerDemo
//
//  Created by Bingo on 2023/9/19.
//

#import "AUIShortEpisodePlayer.h"
#import "AUIVideoCacheGlobalSetting.h"

#if __has_include(<AliVCSDK_Standard/AliVCSDK_Standard.h>)
#import <AliVCSDK_Standard/AliVCSDK_Standard.h>

#elif __has_include(<AliVCSDK_InteractiveLive/AliVCSDK_InteractiveLive.h>)
#import <AliVCSDK_InteractiveLive/AliVCSDK_InteractiveLive.h>

#elif __has_include(<AliVCSDK_BasicLive/AliVCSDK_BasicLive.h>)
#import <AliVCSDK_BasicLive/AliVCSDK_BasicLive.h>

#elif __has_include(<AliVCSDK_UGC/AliVCSDK_UGC.h>)
#import <AliVCSDK_UGC/AliVCSDK_UGC.h>

#endif

#if __has_include(<AliyunPlayer/AliyunPlayer.h>)
#import <AliyunPlayer/AliyunPlayer.h>
#endif

@interface AUIShortEpisodePlayer () <AVPDelegate>

@property (nonatomic, strong) AUIShortEpisodeData *episodeData;
@property (nonatomic, strong) AliListPlayer *listPlayer;
@property (nonatomic, assign) NSInteger playIndex;

@end

@implementation AUIShortEpisodePlayer

- (void)setupPlayer:(AUIShortEpisodeData *)episodeData {
    self.episodeData = episodeData;
    
    self.listPlayer = [[AliListPlayer alloc] init];
    self.listPlayer.autoPlay = YES;
    self.listPlayer.loop = YES;
    self.listPlayer.scalingMode = AVP_SCALINGMODE_SCALEASPECTFIT;
    self.listPlayer.delegate = self;

    [self enablePreloadStrategy:YES param:@"{\"algorithm\":\"sub\",\"offset\":\"500\"}"];
    [self enableLocalCache:YES];
    [self enableHttpDns:YES];
    
    for (AUIVideoInfo *model in self.episodeData.list) {
        [self.listPlayer addUrlSource:model.url uid:model.uid];
    }
    self.playIndex = -100;
}

- (void)enablePreloadStrategy:(BOOL)enable param:(NSString *)param {
    [self.listPlayer setScene:AVP_SHORT_VIDEO];
    [self.listPlayer enableStrategy:AVP_STRATEGY_DYNAMIC_PRELOAD enable:enable];
    if (enable) {
        [self.listPlayer setStrategyParam:AVP_STRATEGY_DYNAMIC_PRELOAD strategyParam:param];
    }
}

- (void)enableLocalCache:(BOOL)enable {
    if (enable) {
        [AUIVideoCacheGlobalSetting setupCacheConfig];
        AVPConfig *config = [self.listPlayer getConfig];
        config.enableLocalCache = YES;
        [self.listPlayer setConfig:config];
    }
}

- (void)enableHttpDns:(BOOL)enable {
    [AliPlayerGlobalSettings enableHttpDns:enable];
    AVPConfig *config = [self.listPlayer getConfig];
    config.enableHttpDns = -1;
    [self.listPlayer setConfig:config];
}

- (void)destroyPlayer {
    if (!self.listPlayer) {
        return;
    }
    [[self.listPlayer getCurrentPlayer] stop];
    [self.listPlayer destroy];
    self.listPlayer = nil;
}

- (AUIVideoInfo *)playingVideo {
    if (self.playIndex < 0 || self.playIndex >= self.episodeData.list.count) {
        return nil;
    }
    return [self.episodeData.list objectAtIndex:self.playIndex];
}

- (void)pause:(BOOL)isPause {
    if (!self.listPlayer) {
        return;
    }
    
    if (isPause) {
        [[self.listPlayer getCurrentPlayer] pause];
    }
    else {
        [[self.listPlayer getCurrentPlayer] start];
    }
}

- (void)stop {
    if (!self.listPlayer) {
        return;
    }
    [self.listPlayer getCurrentPlayer].playerView = nil;
    [[self.listPlayer getCurrentPlayer] stop];
}

- (BOOL)play:(AUIVideoInfo *)videoInfo playerView:(UIView * _Nullable)playerView {
    if (!self.listPlayer) {
        return NO;
    }
    NSInteger index = [self.episodeData.list indexOfObject:videoInfo];
    if (index < 0 || index >= self.episodeData.list.count) {
        return NO;
    }

    if (index == self.playIndex - 1) {
        [self.listPlayer getCurrentPlayer].playerView = playerView;
        [self.listPlayer moveToPre];
    }
    else if (index == self.playIndex + 1) {
        [self.listPlayer getCurrentPlayer].playerView = nil;
        AliPlayer *prePlayer = [self.listPlayer getPreRenderPlayer];
        if (prePlayer) {
            prePlayer.playerView = playerView;
            prePlayer.loop = YES;
            [prePlayer start];
            [self.listPlayer moveToNextWithPrerendered];
        }
        else {
            [self.listPlayer getCurrentPlayer].playerView = playerView;
            [self.listPlayer moveToNext];
        }
    }
    else {
        [self.listPlayer getCurrentPlayer].playerView = playerView;
        [self.listPlayer moveTo:videoInfo.uid];
    }
    self.playIndex = index;
    return YES;
}

- (void)seek:(CGFloat)progress {
    if (!self.listPlayer) {
        return;
    }
    [[self.listPlayer getCurrentPlayer] seekToTime:progress * [self.listPlayer getCurrentPlayer].duration seekMode:AVP_SEEKMODE_ACCURATE];
}

- (BOOL)startPreloadNext:(UIView *)playerView {
    AliPlayer *prePlayer = [self.listPlayer getPreRenderPlayer];
    if (prePlayer) {
        prePlayer.delegate = self;
        
        prePlayer.playerView = playerView;
        [prePlayer seekToTime:0 seekMode:AVP_SEEKMODE_ACCURATE];
        return YES;
    }
    return NO;
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
            NSLog(@"onPlayerEvent:AVPEventPrepareDone");
        }
            break;
        case AVPEventFirstRenderedStart: {
            NSLog(@"onPlayerEvent:AVPEventFirstRenderedStart");
            if (self.onLoadCompletedBlock) {
                self.onLoadCompletedBlock();
            }
        }
            break;
        default:
            break;
    }
}

// 播放器状态改变回调
- (void)onPlayerStatusChanged:(AliPlayer*)player oldStatus:(AVPStatus)oldStatus newStatus:(AVPStatus)newStatus {
    NSLog(@"onPlayerStatusChanged:%tu to %tu", oldStatus, newStatus);
    switch (newStatus) {
        case AVPStatusStarted: {
            if (self.onPlayPauseBlock) {
                self.onPlayPauseBlock(NO);
            }
        }
            break;
        case AVPStatusPaused: {
            if (self.onPlayPauseBlock) {
                self.onPlayPauseBlock(YES);
            }
        }
            break;
        default:
            break;
    }
}

// 视频当前播放位置回调
- (void)onCurrentPositionUpdate:(AliPlayer *)player position:(int64_t)position {
    NSLog(@"onCurrentPositionUpdate:%lld, duration:%lld, position:%lld", self.listPlayer.duration, [self.listPlayer getCurrentPlayer].duration, position);
    if (self.onPlayProgressBlock) {
        int64_t duration = [self.listPlayer getCurrentPlayer].duration;
        CGFloat progress = duration == 0 ? 0 : position / (CGFloat)duration;
        self.onPlayProgressBlock(progress);
    }
}

@end
