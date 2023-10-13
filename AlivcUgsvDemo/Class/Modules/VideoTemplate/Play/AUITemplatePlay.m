//
//  AUITemplatePlay.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/9/23.
//

#import "AUITemplatePlay.h"


@interface AUITemplatePlay () <AliyunAETemplatePlayerDelegate>

@property (nonatomic, strong) NSHashTable<id<AUIVideoPlayObserver>> *observerTable;
@property (nonatomic, weak) AliyunAETemplateEditor *editor;

@property (nonatomic, assign) BOOL isPlaying;

@end

@implementation AUITemplatePlay

@synthesize isLoopPlay;

- (instancetype)initWithEditor:(AliyunAETemplateEditor *)editor {
    self = [super init];
    if (self) {
        self.editor = editor;
        self.player.delegate = self;
    }
    return self;
}

- (AliyunAETemplatePlayer *)player {
    return self.editor.player;
}

- (void)setIsPlaying:(BOOL)isPlaying {
    if (_isPlaying == isPlaying) {
        return;
    }
    _isPlaying = isPlaying;
    [self onPlayStatusChanged];
}

- (void)play {
    [self.player start];
    self.isPlaying = YES;
}

- (void)pause {
    [self.player pause];
    self.isPlaying = NO;
}

- (void)stop {
    [self.player stop];
    self.isPlaying = NO;
}

- (void)replay {
    [self seek:0];
    [self play];
}

- (void)seek:(NSTimeInterval)time {
    [self.player seek:time];
    self.isPlaying = NO;
}

- (void)setDisplayView:(UIView *)displayView {
    UIView *view = [self.player getPlayerView];
    view.frame = displayView.bounds;
    [self.editor commit];
    
    [displayView addSubview:view];
}

- (void)setDisplayViewScaleMode:(AUIVideoPlayDisplayViewScaleMode)scaleMode {
    
}

- (void)updateLayoutForDisplayView {
    UIView *view = [self.player getPlayerView];
    view.frame = view.superview.bounds;
}

- (UIImage *)screenCapture {
    return nil;
}

- (NSTimeInterval)currentTime {
    return [self.player currentTime];
}

- (NSTimeInterval)duration
{
    return [self.player duration];
}

#pragma mark - Play Range

- (void)enablePlayInRange:(NSTimeInterval)rangeStart rangeDuration:(NSTimeInterval)rangeDuration {
    
}

- (void)disablePlayInRange {
    
}

- (NSTimeInterval)playRangeTime {
    return [self currentTime];
}

- (NSTimeInterval)playRangeStart {
    return 0;
}

- (NSTimeInterval)playRangeDuration {
    return [self duration];
}

- (BOOL)playOutOffRange {
    return NO;
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

#pragma mark - AliyunAETemplatePlayerDelegate

- (void)playerDidLoaded {
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
    self.isPlaying = NO;
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

- (void)playProgress:(double)progress {
    NSEnumerator<id<AUIVideoPlayObserver>>* enumerator = [self.observerTable objectEnumerator];
    id<AUIVideoPlayObserver> observer = nil;
    while ((observer = [enumerator nextObject]))
    {
        if ([observer respondsToSelector:@selector(playProgress:)])
        {
            [observer playProgress:progress];
        }
    }
}

- (void)playError:(NSInteger)errorCode {
    self.isPlaying = NO;
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
