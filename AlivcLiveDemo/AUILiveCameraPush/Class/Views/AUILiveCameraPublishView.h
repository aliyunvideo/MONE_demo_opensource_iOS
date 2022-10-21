//
//  AUILiveCameraPublishView.h
//  AlivcLiveCaptureDev
//
//  Created by TripleL on 17/7/10.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlivcLivePushViewsProtocol.h"

@class AlivcLivePushStatsInfo, AlivcLivePushConfig;

@interface AUILiveCameraPublishView : UIView


- (void)setPushViewsDelegate:(id)delegate;


- (instancetype)initWithFrame:(CGRect)frame config:(AlivcLivePushConfig *)config;

- (void)updateInfoText:(NSString *)text;

- (void)updateDebugChartData:(AlivcLivePushStatsInfo *)info;

- (void)updateDebugTextData:(AlivcLivePushStatsInfo *)info;

- (void)hiddenVideoViews;

- (void)updateMusicDuration:(long)currentTime totalTime:(long)totalTime;
- (void)resetMusicButtonTypeWithPlayError;


- (BOOL)getPushButtonType;

@end
