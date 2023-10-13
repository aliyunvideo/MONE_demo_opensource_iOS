//
//  AUIVideoPlayProgressView.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/7.
//

#import <UIKit/UIKit.h>
#import "AUIVideoPlayProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoPlayProgressView : UIView

@property (nonatomic, strong, readonly) UIButton *playButton;
@property (nonatomic, strong, readonly) UILabel *timeLabel;
//@property (nonatomic, strong, readonly) UISlider *progressView;
@property (nonatomic, strong, readonly) UILabel *durationLabel;
@property (nonatomic, strong, readonly) UIButton *fullScreenBtn;

@property (nonatomic, weak, nullable) id<AUIVideoPlayProtocol> player;
@property (nonatomic, copy) void(^onFullScreenBtnClicked)(BOOL fullScreen);

@end

NS_ASSUME_NONNULL_END
