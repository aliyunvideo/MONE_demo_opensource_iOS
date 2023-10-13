//
//  AUILiveBgMusicSettingViewController.h
//  AlivcLiveDemo
//
//  Created by ISS013602000846 on 2022/7/5.
//

#import <UIKit/UIKit.h>
#import "AlivcLivePushViewsProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@interface AUILiveBgMusicSettingView : UIView

@property (nonatomic, weak) id<AUILiveMusicViewDelegate> delegate;

- (void)show:(AlivcLivePushConfig *)config;
- (void)updateMusicPlayProgressTime:(long)progressTime durationTime:(long)durationTime;
- (void)resetMusicPlayStatusWithError;

@end

NS_ASSUME_NONNULL_END
