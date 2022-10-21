//
//  AUIMusicStateModel.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/8.
//

#import "AUIMusicStateModel.h"
#import "AUIResourceManager.h"
#import <AVFoundation/AVFoundation.h>

@implementation AUIMusicStateModel

- (instancetype) initWithMusic:(AUIMusicModel *)music {
    self = [super init];
    if (self) {
        _music = music;
        self.musicLocalPath = [AUIResourceManager.manager getLocalMusicWithId:_music.musicId];
    }
    return self;
}

- (void) setState:(AUIMusicResourceState)state {
    if (_state == state) {
        return;
    }
    _state = state;
    if ([_delegate respondsToSelector:@selector(onAUIMusicStateModel:didChangeState:)]) {
        [_delegate onAUIMusicStateModel:self didChangeState:state];
    }
}

- (void) setDownloadProgress:(float)downloadProgress {
    if (_downloadProgress == downloadProgress) {
        return;
    }
    _downloadProgress = downloadProgress;
    if ([_delegate respondsToSelector:@selector(onAUIMusicStateModel:didChangeProgress:)]) {
        [_delegate onAUIMusicStateModel:self didChangeProgress:downloadProgress];
    }
}

- (void) setMusicLocalPath:(NSString *)musicLocalPath {
    if (musicLocalPath && ![NSFileManager.defaultManager fileExistsAtPath:musicLocalPath]) {
        musicLocalPath = nil;
    }
    
    _musicLocalPath = musicLocalPath;
    if (musicLocalPath.length == 0) {
        self.state = AUIMusicResourceStateNetwork;
        self.downloadProgress = 0.0;
    } else {
        self.state = AUIMusicResourceStateLocal;
        self.downloadProgress = 1.0;
    }
}

- (NSTimeInterval)duration {
    if (!_musicLocalPath) {
        return 0;
    }
    
    AVAsset *assert = [AVAsset assetWithURL:[NSURL fileURLWithPath:_musicLocalPath]];
    NSArray *audioTracks = [assert tracksWithMediaType:AVMediaTypeAudio];
    if (audioTracks.count > 0) {
        AVAssetTrack *track = audioTracks.firstObject;
        return CMTimeGetSeconds(CMTimeRangeGetEnd(track.timeRange));
    }
    return 0;
}

- (void) download {
    if (self.state != AUIMusicResourceStateNetwork) {
        return;
    }
    
    self.state = AUIMusicResourceStateDownloading;
    __weak typeof(self) weakSelf = self;
    [AUIResourceManager.manager downloadMusicWithId:_music.musicId onProgress:^(float progress) {
        weakSelf.downloadProgress = progress;
    } onSuccess:^(NSString *localPath) {
        weakSelf.musicLocalPath = localPath;
    } onFail:^(NSError *errMsg) {
        NSLog(@"download music fail with error: %@", errMsg);
        weakSelf.musicLocalPath = nil;
    }];
}

@end
