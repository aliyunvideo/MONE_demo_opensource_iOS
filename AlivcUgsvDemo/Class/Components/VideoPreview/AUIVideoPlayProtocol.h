//
//  AUIVideoPlayProtocol.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/2.
//

#ifndef AUIVideoPreviewProtocol_h
#define AUIVideoPreviewProtocol_h

typedef NS_ENUM(NSUInteger, AUIVideoPlayDisplayViewScaleMode) {
    AUIVideoPlayDisplayViewScaleModeFit = 0,  // Aspect to fit, cut mode.
    AUIVideoPlayDisplayViewScaleModeFill, // Aspect to fill
};

@protocol AUIVideoPlayObserver <NSObject>

@optional
- (void)playerDidLoaded;
- (void)playerDidEnd;
- (void)playProgress:(double)progress;
- (void)playError:(NSInteger)errorCode;
- (void)playStatus:(BOOL)isPlaying;

@end


@class UIView, UIImage;
@protocol AUIVideoPlayProtocol <NSObject>

- (BOOL)isPlaying;
- (void)play;
- (void)pause;
- (void)stop;
- (void)replay;
- (void)seek:(NSTimeInterval)time;

@property (nonatomic, assign) BOOL isLoopPlay;

- (void)setDisplayView:(UIView *)displayView;
- (void)setDisplayViewScaleMode:(AUIVideoPlayDisplayViewScaleMode)scaleMode;
- (void)updateLayoutForDisplayView;
- (UIImage *)screenCapture;

- (NSTimeInterval)duration;
- (NSTimeInterval)currentTime;

// 限制在一段区域内的播放
- (void)enablePlayInRange:(NSTimeInterval)rangeStart rangeDuration:(NSTimeInterval)rangeDuration;
- (void)disablePlayInRange;
- (NSTimeInterval)playRangeStart;
- (NSTimeInterval)playRangeTime;
- (NSTimeInterval)playRangeDuration;

- (void)addObserver:(id<AUIVideoPlayObserver>)observer;
- (void)removeObserver:(id<AUIVideoPlayObserver>)observer;

@end

#endif /* AUIVideoPreviewProtocol_h */
