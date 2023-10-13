//
//  AlivcLivePushViewsProtocol.h
//  AlivcLivePusherTest
//
//  Created by lyz on 2017/11/24.
//  Copyright © 2017年 TripleL. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol AUILiveCameraPublishViewDelegate <NSObject>

- (void)publisherOnClickedBackButton;

- (int)publisherOnClickedPreviewButton:(BOOL)isPreview button:(UIButton *)sender;

- (BOOL)publisherOnClickedPushButton:(BOOL)isPush button:(UIButton *)sender;

- (void)publisherOnClickedPauseButton:(BOOL)isPause button:(UIButton *)sender;

- (int)publisherOnClickedRestartButton;

- (void)publisherOnClickedPushVideoButton:(BOOL)isMute button:(UIButton *)sender;
- (void)publisherOnClickedSwitchCameraButton;
- (void)publisherDataMonitorView;
- (void)publisherOnClickedWaterMarkButton;
- (void)publisherOnClickedRemoveWaterMarkButton;

- (void)publisherOnClickedSnapshotButton;

- (void)publisherOnClickedFlashButton:(BOOL)flash button:(UIButton *)sender;

- (void)publisherOnClickedBeautyButton:(BOOL)beautyOn;


- (void)publisherOnClickedZoom:(CGFloat)zoom;

- (void)publisherOnClickedFocus:(CGPoint)focusPoint;

- (void)publisherOnClickedShowDebugTextInfo:(BOOL)isShow;

- (void)publisherOnClickedShowDebugChartInfo:(BOOL)isShow;

- (void)publisherOnBitrateChangedTargetBitrate:(int)targetBitrate;

- (void)publisherOnBitrateChangedMinBitrate:(int)minBitrate;


- (void)publisherOnClickSharedButon;

- (int)publisherOnClickAddDynamically:(NSString *)path x:(float)x y:(float)y w:(float)w h:(float)h;

- (void)publisherOnClickRemoveDynamically:(int)vid;

- (void)publisherOnClickAutoFocusButton:(BOOL)isAutoFocus;

- (void)publisherOnClickPreviewMirrorButton:(BOOL)isPreviewMorror;

- (void)publisherOnClickPushMirrorButton:(BOOL)isPushMirror;

- (void)publisherOnSelectPreviewDisplayMode:(int)mode;

- (void)publisherOnSelectAudioEffectsVoiceChangeMode:(NSInteger)mode;

- (void)publisherOnSelectAudioEffectsReverbMode:(NSInteger)mode;

@end


@protocol AUILiveMusicViewDelegate <NSObject>

- (void)musicOnClickPlayButton:(BOOL)isPlay musicPath:(NSString *)musicPath;

- (void)musicOnClickPauseButton:(BOOL)isPause;

- (void)musicOnClickLoopButton:(BOOL)isLoop;

- (void)musicOnClickMuteButton:(BOOL)isMute;

- (void)musicOnClickEarBackButton:(BOOL)isEarBack;

- (void)musicOnClickDenoiseButton:(BOOL)isDenoiseOpen;

- (void)musicOnClickIntelligentDenoiseButton:(BOOL)isIntelligentDenoiseOpen;

- (void)musicOnSliderAccompanyValueChanged:(int)value;

- (void)musicOnSliderVoiceValueChanged:(int)value;

@end

@protocol AUILiveAnswerGameViewDelegate <NSObject>

- (void)answerGameOnSendQuestion:(NSString *)question questionId:(NSString *)questionId;
- (void)answerGameOnSendAnswer:(NSString *)answer duration:(NSInteger)duration;

@end

