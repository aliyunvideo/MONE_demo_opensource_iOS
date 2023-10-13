//
//  AlivcPlayerBackgroudModePlugin.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/15.
//

#import "AlivcPlayerBackgroudModePlugin.h"
#import <MediaPlayer/MediaPlayer.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "AlivcPlayerManager.h"

@implementation AlivcPlayerBackgroudModePlugin

#pragma mark -- backgroudPlay

- (void)onInstall
{
    [super onInstall];
}

- (NSInteger)level
{
    return 0;
}

- (NSArray<NSNumber *> *)eventList
{
    return @[@(AlivcPlayerEventCenterTypePlayerEventAVPStatus),@(AlivcPlayerEventCenterTypePlayerEventType),@(AlivcPlayerEventCenterTypePlayerBackModeEnabledChanged),@(AlivcPlayerEventCenterPlaySceneChanged),@(AlivcPlayerEventCenterTypePlayListSourceDidChanged)];
}

- (void)onReceivedEvent:(AlivcPlayerEventCenterType)eventType userInfo:(NSDictionary *)userInfo
{
    if (eventType == AlivcPlayerEventCenterTypePlayerEventAVPStatus) {
        
        AVPStatus status = [AlivcPlayerManager manager].playerStatus;
        switch (status) {
            case AVPStatusIdle:
            {
                [self stopBgProgress];
            }
                break;
            case AVPStatusStarted:
            {
                [self addRemoteCommandCenter];
                [self updateButtonStatus];
                [self updatePlayingSongInfo];
            }
                break;
            case AVPStatusStopped:
            case AVPStatusError:
            {
                [self clearBgPlayer];
            }
                break;
            case AVPStatusCompletion:
            {
                [self resetBgPlayer];
            }
                break;
                
            default:
                break;
        }
    } else if (eventType == AlivcPlayerEventCenterTypePlayerEventType) {
        AVPEventType type = [[userInfo objectForKey:@"eventType"] integerValue];
        if (type == AVPEventSeekEnd) {
            [self updatePlayingSongInfo];
        }
    } else if (eventType == AlivcPlayerEventCenterTypePlayerBackModeEnabledChanged) {
        BOOL backModeEnabled = [AlivcPlayerManager manager].backgroudModeEnabled;
        if (!backModeEnabled) {
            [self clearBgPlayer];
        } else {
            [self addRemoteCommandCenter];
            [self updatePlayingSongInfo];
        }
    } else if (eventType == AlivcPlayerEventCenterTypePlayListSourceDidChanged) {
        [self updateButtonStatus];
    }
}

- (void)stopBgProgress
{
    NSMutableDictionary *playingInfoDict = [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo.mutableCopy;
    
    [playingInfoDict setObject:@(0) forKey:MPNowPlayingInfoPropertyPlaybackRate];
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = playingInfoDict;
}

- (void)resetBgPlayer
{
    if (![AlivcPlayerManager manager].autoPlayInList || ![AlivcPlayerManager manager].canPlayNext) {

        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        
        NSMutableDictionary *playingInfoDict = [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo.mutableCopy;
        
        [playingInfoDict setObject:@(0) forKey:MPNowPlayingInfoPropertyPlaybackRate];
        AVPMediaInfo *info = [AlivcPlayerManager manager].getMediaInfo;

                [playingInfoDict setObject:@(info.duration/1000.0) forKey:MPMediaItemPropertyPlaybackDuration];
        [playingInfoDict setObject:@(info.duration/1000.0) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = playingInfoDict;
    }
}

- (void)updateButtonStatus
{
    MPRemoteCommandCenter *recenter = [MPRemoteCommandCenter sharedCommandCenter];
    recenter.nextTrackCommand.enabled = [AlivcPlayerManager manager].playScene != ApPlayerSceneInFeed && [[AlivcPlayerManager manager] canPlayNext];
    recenter.previousTrackCommand.enabled = [AlivcPlayerManager manager].playScene != ApPlayerSceneInFeed && [[AlivcPlayerManager manager] canPlayPre];


}

- (void)updatePlayingSongInfo
{
    AVPMediaInfo *info = [AlivcPlayerManager manager].getMediaInfo;
    if (!info) {
        return;
    }
    
    
    BOOL backModeEnabled = [AlivcPlayerManager manager].backgroudModeEnabled;
    
    if (!backModeEnabled) {
        return;
    }
    
    NSMutableDictionary *playingInfoDict = [NSMutableDictionary dictionary];
    
    //æ ‡é¢˜
    if (info.title) {
        [playingInfoDict setObject:info.title forKey:MPMediaItemPropertyTitle];
    }
    
    //è¿›åº¦æ¡rate
    [playingInfoDict setObject:@(1) forKey:MPNowPlayingInfoPropertyPlaybackRate];
    
    //totalDuration
    [playingInfoDict setObject:@(info.duration/1000.0) forKey:MPMediaItemPropertyPlaybackDuration];
    
    //è¿›åº¦
    [playingInfoDict setObject:@([AlivcPlayerManager manager].currentPosition/1000.0) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    
    //coverimage
    NSURL *url = [NSURL URLWithString:info.coverURL?:@""];
    [[SDWebImageManager sharedManager] loadImageWithURL:url options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        
        if (![imageURL isEqual:url]) {
            return;
        }
        if (image) {
            if ([imageURL isEqual:url]) {
                MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:image];
                [playingInfoDict setObject:artwork forKey:MPMediaItemPropertyArtwork];
                [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = playingInfoDict;
            }
        }
    }];
    
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = playingInfoDict;
}


- (void)clearBgPlayer
{
    MPRemoteCommandCenter *recenter = [MPRemoteCommandCenter sharedCommandCenter];

    [recenter.pauseCommand removeTarget:self];
    [recenter.playCommand removeTarget:self];
    [recenter.nextTrackCommand removeTarget:self];
    [recenter.previousTrackCommand removeTarget:self];

    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = @{};
}

- (MPRemoteCommandHandlerStatus)OnPauseCommand:(id)sender
{
    [[AlivcPlayerManager manager] pause];

    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)OnPlayCommand:(id)sender
{
 
    if ([AlivcPlayerManager manager].playerStatus == AVPStatusCompletion)
    {
        [[AlivcPlayerManager manager] seekToTimeProgress:0 seekMode:1];
    }
    [[AlivcPlayerManager manager] resume];
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)OnNextTrackCommand:(id)sender
{
    [[AlivcPlayerManager manager] playNext];
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)OnPreviousTrackCommand:(id)sender
{
    [[AlivcPlayerManager manager] playPre];
    return MPRemoteCommandHandlerStatusSuccess;
}


- (void)addRemoteCommandCenter
{
    MPRemoteCommandCenter *recenter = [MPRemoteCommandCenter sharedCommandCenter];
    
    recenter.nextTrackCommand.enabled = NO;
    recenter.previousTrackCommand.enabled = NO;
    
    
    [recenter.pauseCommand addTarget:self action:@selector(OnPauseCommand:)];
    [recenter.playCommand addTarget:self action:@selector(OnPlayCommand:)];
    [recenter.nextTrackCommand addTarget:self action:@selector(OnNextTrackCommand:)];
    [recenter.previousTrackCommand addTarget:self action:@selector(OnPreviousTrackCommand:)];

}




@end
