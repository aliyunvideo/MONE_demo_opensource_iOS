//
//  AUIAssetPlay.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/1.
//

#import "AUIAssetPlay.h"
#import "AVAsset+UgsvHelper.h"
#import "AUIFoundation.h"

@interface AUIAssetPlay ()

@property (nonatomic, strong) AVAsset *playAsset;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playItem;
@property (nonatomic, strong) AVPlayerItemVideoOutput *playItemVideoOutput;

@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, assign) AUIVideoPlayDisplayViewScaleMode scaleMode;

@property (nonatomic, strong) id periodicTimeObserver;
@property (nonatomic, assign) NSTimeInterval playTime;
@property (nonatomic, assign) BOOL onPlay; //播放中

@property (nonatomic, assign) BOOL enableRangePlay;
@property (nonatomic, assign) NSTimeInterval rangeStart;
@property (nonatomic, assign) NSTimeInterval rangeDuration;


@property (nonatomic, strong) NSHashTable<id<AUIVideoPlayObserver>> *observerTable;

@end


@implementation AUIAssetPlay

@synthesize isLoopPlay;

- (void)dealloc {
    [self stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (instancetype)initWithAsset:(AVAsset *)asset {
    self = [super init];
    if (self) {
        _playAsset = asset;
        _onPlay = NO;
        //播放完成通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return self;
}

- (void)onPlayToEnd:(NSNotification *)notify
{
    if (notify.object != self.player.currentItem)
    {
        return;
    }

    [self onPlayDidEnd];
    if (self.isLoopPlay) {
        [self replay];
    }
}

- (void)addPlayerPeriodicTimeObserver
{
    [self removePlayerPeriodicTimeObserver];
    __weak typeof(self) weakSelf = self;
    self.periodicTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 60) queue:NULL usingBlock:^(CMTime time)
                 {
        if (!weakSelf.player.currentItem)
        {
            return;
        }
        
        if (weakSelf.player.currentItem.status != AVPlayerItemStatusReadyToPlay)
        {
            return;
        }
        [weakSelf onPlayProgress:CMTimeGetSeconds(time)];
    }];
}

- (void)removePlayerPeriodicTimeObserver
{
    if (self.periodicTimeObserver)
    {
        @try{
            [self.player removeTimeObserver:self.periodicTimeObserver];
        }
        @catch (NSException *exception) {
            
        } @finally {
            
        }
        self.periodicTimeObserver = nil;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"])
    {
        AVPlayerItemStatus status = (AVPlayerItemStatus)[[change objectForKey:@"new"] integerValue];
        [self playItemStateChange:status];
    }
}

- (void)playItemStateChange:(AVPlayerItemStatus)status
{
    switch (status)
    {
        case AVPlayerItemStatusReadyToPlay:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self onPlayDidLoaded];
            });
        }
            break;
            
        case AVPlayerItemStatusFailed:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.onPlay = NO;
                [self onPlayError:self.player.currentItem.error.code];
            });
        }
            break;
            
        case AVPlayerItemStatusUnknown:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.onPlay = NO;
                [self onPlayError:self.player.currentItem.error.code];
            });
        }
            break;
            
        default:
            break;
    }
}

- (BOOL)isPlaying {
    return self.onPlay;
}

- (void)updatePlayLayer {
    if (!self.player || !self.playerView) {
        return;
    }
    
    if (!self.playerLayer) {
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        [self.playerView.layer addSublayer:self.playerLayer];
    }
    self.playerLayer.frame = self.playerView.bounds;
    self.playerLayer.videoGravity = self.scaleMode == AUIVideoPlayDisplayViewScaleModeFit ? AVLayerVideoGravityResizeAspectFill : AVLayerVideoGravityResizeAspect;
}

- (void)play {
    if (self.playAsset && !self.player) {
        self.playTime = 0;
        self.playItem = [[AVPlayerItem alloc] initWithAsset:self.playAsset];
        [self.playItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        self.playItemVideoOutput = [[AVPlayerItemVideoOutput alloc] init];
        [self.playItem addOutput:self.playItemVideoOutput];
        self.player = [[AVPlayer alloc] init];
        [self.player replaceCurrentItemWithPlayerItem:self.playItem];
        [self addPlayerPeriodicTimeObserver];
        
        [self updatePlayLayer];
        if (self.enableRangePlay) {
            [self seek:self.playRangeStart];
        }
    }
    else {
        if (self.enableRangePlay && [self playOutOffRange]) {
            [self seek:self.playRangeStart];
        }
    }
    [self.player play];
    self.onPlay = YES;
    [self onPlayStatusChanged];
}

- (void)pause {
    if (self.player) {
        [self.player pause];
        self.onPlay = NO;
        [self onPlayStatusChanged];
    }
}

- (void)stop {
    if (self.player) {
        self.playTime = 0;
        [self.playItem removeOutput:self.playItemVideoOutput];
        self.playItemVideoOutput = nil;
        [self.playItem removeObserver:self forKeyPath:@"status"];
        self.playItem = nil;
        [self.player replaceCurrentItemWithPlayerItem:nil];
        [self removePlayerPeriodicTimeObserver];
        self.player = nil;
        
        [self.playerLayer removeFromSuperlayer];
        self.playerLayer = nil;
        
        self.onPlay = NO;
        [self onPlayStatusChanged];
    }
}

- (void)replay {
    __weak typeof(self) weakSelf = self;
    [self pause];
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem seekToTime:CMTimeMakeWithSeconds(self.playRangeStart, 1000) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) {
            // 重新播放需要确保seek成功
            [weakSelf play];
        }
        else {
            [weakSelf stop];
        }
    }];
}

- (void)seek:(NSTimeInterval)time {
    [self pause];
    if (self.player) {
        [self.player.currentItem cancelPendingSeeks];
        [self.player.currentItem seekToTime:CMTimeMakeWithSeconds(time, 1000) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            if (!finished) {
            }
        }];
    }
}

- (void)setDisplayView:(UIView *)displayView {
    self.playerView = displayView;
    [self updatePlayLayer];
}

- (void)setDisplayViewScaleMode:(AUIVideoPlayDisplayViewScaleMode)scaleMode {
    self.scaleMode = scaleMode;
    [self updatePlayLayer];
}

- (void)updateLayoutForDisplayView {
    if (self.playerView && self.playerLayer) {
        self.playerLayer.frame = self.playerView.bounds;
    }
}

- (UIImage *)screenCapture {
    if (!self.player || !self.playerLayer) {
        return nil;
    }
    CMTime itemTime = self.playItem.currentTime;
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:self.playAsset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    CGImageRef videoImage = [imageGenerator copyCGImageAtTime:itemTime
                                                   actualTime:NULL
                                                        error:nil];
    UIImage *frameImg = [UIImage imageWithCGImage:videoImage];
    CGImageRelease(videoImage);
    if (!frameImg) {
        return nil;
    }
    CGSize frameSize = CGSizeMake(frameImg.size.width * frameImg.scale, frameImg.size.height * frameImg.scale);

    CGSize targetSize = self.playerLayer.bounds.size;
    UIGraphicsBeginImageContextWithOptions(targetSize, YES, 0);
    
    if (self.playerLayer.videoGravity == AVLayerVideoGravityResizeAspectFill) {
        [frameImg drawInRect:[UIView av_aspectFillRectWithFillSize:frameSize targetRect:CGRectMake(0, 0, targetSize.width, targetSize.height)]];
    }
    else {
        [frameImg drawInRect:[UIView av_aspectFitRectWithFitSize:frameSize targetRect:CGRectMake(0, 0, targetSize.width, targetSize.height)]];
    }
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return normalizedImage;
}

- (NSTimeInterval)currentTime {
    return self.playTime;
}

- (NSTimeInterval)duration
{
    if (self.player) {
        return CMTimeGetSeconds(self.player.currentItem.duration);
    }
    return [self.playAsset ugsv_getDuration];
}

- (void)enablePlayInRange:(NSTimeInterval)rangeStart rangeDuration:(NSTimeInterval)rangeDuration {
    [self pause];
    self.enableRangePlay = YES;
    self.rangeStart = rangeStart;
    self.rangeDuration = MIN(rangeDuration, [self duration] - self.rangeStart);
}

- (void)disablePlayInRange {
    if (self.enableRangePlay) {
        self.enableRangePlay = NO;
    }
}

- (NSTimeInterval)playRangeTime {
    if (!self.enableRangePlay) {
        [self currentTime];
    }
    return MAX([self currentTime] - self.rangeStart, 0);
}

- (NSTimeInterval)playRangeStart {
    if (!self.enableRangePlay) {
        return 0;
    }
    return self.rangeStart;
}

- (NSTimeInterval)playRangeDuration {
    if (!self.enableRangePlay) {
        return [self duration];
    }
    return self.rangeDuration;
}

- (BOOL)playOutOffRange {
    if (!self.enableRangePlay) {
        return NO;
    }
    return [self currentTime] >= self.rangeStart + self.rangeDuration;
}

#pragma mark - Observer & Raise Event

- (NSHashTable<id<AUIVideoPlayObserver>> *)observerTable {
    if (!_observerTable) {
        _observerTable = [NSHashTable weakObjectsHashTable];
    }
    return _observerTable;
}

- (void)addObserver:(id<AUIVideoPlayObserver>)observer {
    if ([self.observerTable containsObject:observer])
    {
        return;
    }
    [self.observerTable addObject:observer];
}

- (void)removeObserver:(id<AUIVideoPlayObserver>)observer {
    [self.observerTable removeObject:observer];
}

- (void)onPlayStatusChanged {
    NSEnumerator<id<AUIVideoPlayObserver>>* enumerator = [self.observerTable objectEnumerator];
    id observer = nil;
    while ((observer = [enumerator nextObject]))
    {
        if ([observer respondsToSelector:@selector(playStatus:)])
        {
            [observer playStatus:self.isPlaying];
        }
    }
}

- (void)onPlayDidLoaded {
    NSEnumerator<id<AUIVideoPlayObserver>>* enumerator = [self.observerTable objectEnumerator];
    id observer = nil;
    while ((observer = [enumerator nextObject]))
    {
        if ([observer respondsToSelector:@selector(playerDidLoaded)])
        {
            [observer playerDidLoaded];
        }
    }
}

- (void)onPlayDidEnd {
    NSEnumerator<id<AUIVideoPlayObserver>>* enumerator = [self.observerTable objectEnumerator];
    id observer = nil;
    while ((observer = [enumerator nextObject]))
    {
        if ([observer respondsToSelector:@selector(playerDidEnd)])
        {
            [observer playerDidEnd];
        }
    }
}

- (void)onPlayProgress:(NSTimeInterval)time {
    self.playTime = time;
    double progress = 0;
    NSTimeInterval duration = [self playRangeDuration];
    if (duration > 0) {
        progress = [self playRangeTime] / duration;
        progress = MIN(1.0, progress);
    }
    NSEnumerator<id<AUIVideoPlayObserver>>* enumerator = [self.observerTable objectEnumerator];
    id observer = nil;
    while ((observer = [enumerator nextObject]))
    {
        if ([observer respondsToSelector:@selector(playProgress:)])
        {
            [observer playProgress:progress];
        }
    }
    
    if ([self playOutOffRange] && self.onPlay) {
        [self pause];
        [self onPlayDidEnd];
        if (self.isLoopPlay) {
            [self replay];
        }
    }
}

- (void)onPlayError:(NSInteger)errorCode {
    NSEnumerator<id<AUIVideoPlayObserver>>* enumerator = [self.observerTable objectEnumerator];
    id observer = nil;
    while ((observer = [enumerator nextObject]))
    {
        if ([observer respondsToSelector:@selector(playError:)])
        {
            [observer playError:errorCode];
        }
    }
}

@end

