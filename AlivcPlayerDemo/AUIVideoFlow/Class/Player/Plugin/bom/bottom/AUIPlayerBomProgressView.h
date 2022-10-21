//
//  AUIPlayerBomProgressView.h
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/20.
//

#import <UIKit/UIKit.h>
#import "AUIPlayerProgressView.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIPlayerBomProgressView : UIView
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) AUIPlayerProgressView *progressView;
@property (nonatomic, strong) UILabel *leftTimeLabel;
@property (nonatomic, strong) UILabel *rightTimeLabel;
@property (nonatomic, copy) void(^onSliderValueChanged)(float progress);
@property (nonatomic, copy) void(^onSliderTouchBegin)(float progress);
@property (nonatomic, copy) void(^onSliderTouchEnd)(float progress);




- (void)updateSliderValue:(int64_t)position duration:(int64_t)duration;
- (void)updateCacheProgressValue:(int64_t)position duration:(int64_t)duration;

@end

NS_ASSUME_NONNULL_END
