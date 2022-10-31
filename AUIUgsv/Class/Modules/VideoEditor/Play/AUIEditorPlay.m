//
//  AUIEditorPlay.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/8.
//

#import "AUIEditorPlay.h"

@interface AUIEditorPlay () <AliyunIPlayerCallback>

@property (nonatomic, strong) NSHashTable<id<AUIVideoPlayObserver>> *observerTable;
@property (nonatomic, weak, readonly) id<AliyunIPlayer> player;
@property (nonatomic, weak) AliyunEditor *editor;

@property (nonatomic, assign) BOOL enableRangePlay;
@property (nonatomic, assign) NSTimeInterval rangeStart;
@property (nonatomic, assign) NSTimeInterval rangeDuration;

@end

@implementation AUIEditorPlay

@synthesize isLoopPlay;

- (instancetype)initWithEditor:(AliyunEditor *)editor {
    self = [super init];
    if (self) {
        self.editor = editor;
        self.speed = 1.0;
        self.editor.playerCallback = self;
    }
    return self;
}

- (id<AliyunIPlayer>)player {
    return self.editor.getPlayer;
}

- (BOOL)isPlaying {
    return self.player.isPlaying;
}

- (void)play {
    if (self.enableRangePlay && [self playOutOffRange]) {
        [self seek:self.rangeStart];
    }
    [self.player play];
    [self onPlayStatusChanged];
}

- (void)pause {
    [self.player pause];
    [self onPlayStatusChanged];
}

- (void)stop {
    [self.player stop];
    [self onPlayStatusChanged];
}

- (void)replay {
    [self seek:self.playRangeStart];
    [self.player play];
    [self onPlayStatusChanged];
}

- (void)seek:(NSTimeInterval)time {
    time = time * self.speed;
    if (self.enableRangePlay) {
        time += self.rangePlayOffset;
    }
    NSLog(@"seek:%f", time);
    [self.player seek:time];
    [self onPlayStatusChanged];
    [self playProgress:[self currentTime] streamProgress:0];
}

- (void)setDisplayView:(UIView *)displayView {
    
}

- (void)setDisplayViewScaleMode:(AUIVideoPlayDisplayViewScaleMode)scaleMode {
    self.editor.renderWrapper.renderMode = scaleMode == AUIVideoPlayDisplayViewScaleModeFit ? AliyunEditorRenderViewModeResize : AliyunEditorRenderViewModeResizeAspect;
}

- (void)updateLayoutForDisplayView {
    
}

- (UIImage *)screenCapture {
    return [self.editor screenCapture];
}

- (NSTimeInterval)currentTime {
    return [self.player getCurrentTime];
}

- (NSTimeInterval)duration
{
    return [self.player getDuration];
}

#pragma mark - Play Range

- (void)enablePlayInRange:(NSTimeInterval)rangeStart rangeDuration:(NSTimeInterval)rangeDuration {
    [self pause];
    self.enableRangePlay = YES;
    self.rangeStart = rangeStart;
    self.rangeDuration = MIN(rangeDuration, [self duration] - (self.rangeStart + self.rangePlayOffset));
}

- (void)disablePlayInRange {
    if (self.enableRangePlay) {
        self.enableRangePlay = NO;
    }
}

- (NSTimeInterval)playRangeTime {
    if (!self.enableRangePlay) {
        return [self currentTime];
    }
    return MAX([self currentTime] - (self.rangeStart + self.rangePlayOffset), 0);
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
    
    NSTimeInterval start = self.rangeStart + self.rangePlayOffset;
    return [self currentTime] >= start + self.rangeDuration || [self currentTime] < start;
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

#pragma AliyunIPlayerCallback

- (void)playerLoad {
    NSEnumerator<id<AUIVideoPlayObserver>>* enumerator = [self.observerTable objectEnumerator];
    id<AUIVideoPlayObserver> observer = nil;
    while ((observer = [enumerator nextObject]))
    {
        if ([observer respondsToSelector:@selector(playerDidLoaded)])
        {
            [observer playerDidLoaded];
        }
    }
}

- (void)playerDidEnd {
    NSEnumerator<id<AUIVideoPlayObserver>>* enumerator = [self.observerTable objectEnumerator];
    id<AUIVideoPlayObserver> observer = nil;
    while ((observer = [enumerator nextObject]))
    {
        if ([observer respondsToSelector:@selector(playerDidEnd)])
        {
            [observer playerDidEnd];
        }
    }
    
    if (self.isLoopPlay) {
        [self replay];
    }
}

- (void)playProgress:(double)playSec streamProgress:(double)streamSec {
//    NSLog(@"seek: playProgress:%f", self.currentTime);
    double progress = self.currentTime / self.duration;
    if (self.enableRangePlay) {
        progress = 0;
        NSTimeInterval duration = [self playRangeDuration];
        if (duration > 0) {
            progress = [self playRangeTime] / duration;
            progress = MIN(1.0, progress);
        }
    }
    NSEnumerator<id<AUIVideoPlayObserver>>* enumerator = [self.observerTable objectEnumerator];
    id<AUIVideoPlayObserver> observer = nil;
    while ((observer = [enumerator nextObject]))
    {
        if ([observer respondsToSelector:@selector(playProgress:)])
        {
            [observer playProgress:progress];
        }
    }
    
    if ([self playOutOffRange] && self.isPlaying) {
        [self pause];
        [self playerDidEnd];
    }
}

- (void)playError:(int)errorCode {
    NSEnumerator<id<AUIVideoPlayObserver>>* enumerator = [self.observerTable objectEnumerator];
    id<AUIVideoPlayObserver> observer = nil;
    while ((observer = [enumerator nextObject]))
    {
        if ([observer respondsToSelector:@selector(playError:)])
        {
            [observer playError:(NSInteger)errorCode];
        }
    }
}

@end
