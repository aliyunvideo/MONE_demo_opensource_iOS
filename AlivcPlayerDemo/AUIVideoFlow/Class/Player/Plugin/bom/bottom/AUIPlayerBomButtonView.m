//
//  AUIPlayerBomButtonView.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/20.
//

#import "AUIPlayerBomButtonView.h"
#import "AlivcPlayerAsset.h"
#import <Masonry/Masonry.h>
#import "AlivcPlayerManager.h"
#import "AUIPlayerCustomImageButton.h"


typedef NS_ENUM(NSInteger, APBomRightButtonType) {
    APBomRightButtonTypeSubtitle, //中字
    APBomRightButtonTypeSpeed,  //倍速
    APBomRightButtonTypeBitrate, //码率
    APBomRightButtonTypeDebug  //开发者
};


const static CGFloat kContentTop= 5;
const static CGFloat kContentHeight = 24;
const static CGFloat kMargrnX = 64;
const static CGFloat kPaddingX = 24;






@interface AUIPlayerBomButtonView()

@property (nonatomic, strong) UIView *leftContainer;
@property (nonatomic, strong) UIView *rightContainer;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) AUIPlayerCustomImageButton *halfScreenButton;

@end


@implementation AUIPlayerBomButtonView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI
{
    [self addSubview:self.leftContainer];
    [self addSubview:self.rightContainer];
    [self addSubview:self.halfScreenButton];
    
    [self.leftContainer addSubview:self.playButton];
    
    [self.leftContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(kContentTop);
        make.left.equalTo(self.mas_left).offset(kMargrnX);
        make.height.equalTo(@(kContentHeight));
        make.width.equalTo(self).multipliedBy(0.5).offset(-kMargrnX);
    }];
    
    [self.rightContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(kContentTop);
        make.right.mas_equalTo(self.halfScreenButton.mas_left).offset(-6);
        make.height.equalTo(@(kContentHeight));
        make.width.equalTo(self).multipliedBy(0.5).offset(-kMargrnX);
    }];
    
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.top.bottom.equalTo(self.leftContainer);
        make.width.equalTo(@(kContentHeight));
    }];
    
    [self.halfScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).mas_offset(-kPaddingX);
        make.centerY.equalTo(self.rightContainer);
        make.size.mas_equalTo(CGSizeMake(30, 42));
    }];
    
    [self addNormalRightTitles];

}

- (void)addNormalRightTitles
{
    
    for (UIButton *button in self.rightContainer.subviews) {
        [button removeFromSuperview];
    }
    // zzy 20220630 暂时注释功能
    // NSArray * rightTitles = @[@"中字",@"选集",@"倍速",@"自动",@"开发者模式"];
    NSArray * rightTitles = @[AUIVideoFlowString(@"倍速"), AUIVideoFlowString(@"自动")];
    // zzy 20220630 暂时注释功能
    

    for (int i = 0; i < rightTitles.count; i++) {
        UIButton *button = [[UIButton alloc] init];
        NSString *buttonId = [NSString stringWithFormat:@"rightTitles_%d", i];
        button.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(buttonId);
        button.tag = i;
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [button setTitleColor:APGetColor(APColorTypeWhiteBg40) forState:UIControlStateDisabled];

        [button setTitle:rightTitles[i] forState:UIControlStateNormal];
        button.titleLabel.font = AVGetRegularFont(12);
        [self.rightContainer addSubview:button];
        [button addTarget:self action:@selector(onRightContainButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 0) {
            button.tag = APBomRightButtonTypeSpeed;
            // zzy 20220630 暂时注释功能
            // button.enabled = NO;
            // zzy 20220630 暂时注释功能
        }
        if (i == 1) {
            button.tag = APBomRightButtonTypeBitrate;
            button.hidden = YES;
            // button.enabled = NO;
        }
        if (i == 3) {
            button.enabled = NO;
        }
        
    }
    [self addSubViewConstraints];
}

- (void)addSubViewConstraints
{
    for (int i = self.rightContainer.subviews.count - 1; i >= 0; i--) {
        UIView *view = self.rightContainer.subviews[i];
    
        if (i == self.rightContainer.subviews.count - 1) {
             [view mas_makeConstraints:^(MASConstraintMaker *make) {
                 make.top.bottom.equalTo(self.rightContainer);
                 make.right.equalTo(self.rightContainer).offset(-14);
             }];
        } else {
            
            UIView *preView = self.rightContainer.subviews[i + 1];

            CGFloat padding  = 22;
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(self.rightContainer);
                make.right.equalTo(preView.mas_left).offset(-padding);
            }];
        }
    }
    
}

- (UIView *)leftContainer
{
    if (!_leftContainer) {
        _leftContainer = [UIView new];
        _leftContainer.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"bomButton_leftContainer");
    }
    return _leftContainer;
}

- (UIView *)rightContainer
{
    if (!_rightContainer) {
        _rightContainer = [UIView new];
        _rightContainer.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"bomButton_rightContainer");
    }
    return _rightContainer;
}

- (UIButton *)playButton
{
    if (!_playButton) {
        _playButton = [[UIButton alloc] init];
        _playButton.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"bomButton_playButton");
        [_playButton addTarget:self action:@selector(onPlayButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_playButton setImage:AUIVideoFlowImage(@"player_paused") forState:UIControlStateNormal];
        [_playButton setImage:AUIVideoFlowImage(@"player_play") forState:UIControlStateSelected];
        _playButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _playButton;
}

- (AUIPlayerCustomImageButton *)halfScreenButton
{
    if (!_halfScreenButton) {
        _halfScreenButton = [[AUIPlayerCustomImageButton alloc] initWithFrame:CGRectMake(12, 0, self.av_height, self.av_height)];
        _halfScreenButton.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"bomButton_halfScreenButton");
        _halfScreenButton.customSize = CGSizeMake(14, 14);

        [_halfScreenButton setImage:AUIVideoFlowImage(@"player_halfscreen") forState:UIControlStateNormal];
        
        [_halfScreenButton addTarget:self action:@selector(onHalfScreenButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _halfScreenButton;
}


- (void)onTextInputClick:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(bomButtonViewDidClickInput)]) {
        [self.delegate bomButtonViewDidClickInput];
    }
}

- (void)setPlayStatus:(NSUInteger)playStatus {
    AVPStatus status = [AlivcPlayerManager manager].playerStatus;
    if (status == AVPStatusPaused || status == AVPStatusStopped) {
        self.playButton.selected = YES;
    } else if (status == AVPStatusCompletion) {
        self.playButton.selected = YES;
    } else {
        self.playButton.selected = NO;
    }
}

- (void)onPlayButtonClick:(UIButton *)button
{
    AVPStatus status = [AlivcPlayerManager manager].playerStatus;
    if (status == AVPStatusPaused || status == AVPStatusStopped) {
        [[AlivcPlayerManager manager] resume];
    } else if (status == AVPStatusCompletion) {
        [[AlivcPlayerManager manager] seekToTimeProgress:0 seekMode:AVP_SEEKMODE_ACCURATE];
        [[AlivcPlayerManager manager] resume];
    } else {
        [[AlivcPlayerManager manager] pause];
    }
    
}

- (void)onNextButtonClick:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(bomButtonViewDidClickPlayNext)]) {
        [self.delegate bomButtonViewDidClickPlayNext];
    }
}

- (void)onRightContainButtonClick:(UIButton *)button
{
    switch (button.tag) {
        case APBomRightButtonTypeSubtitle:
        {
            if ([self.delegate respondsToSelector:@selector(bomButtonViewDidClickSubtitle)]) {
                [self.delegate bomButtonViewDidClickSubtitle];
            }
        }
            break;
        case APBomRightButtonTypeSpeed:
        {
            if ([self.delegate respondsToSelector:@selector(bomButtonViewDidClickSpeed)]) {
                [self.delegate bomButtonViewDidClickSpeed];
            }
        }
            break;
        case APBomRightButtonTypeBitrate:
        {
            if ([self.delegate respondsToSelector:@selector(bomButtonViewDidClickBitrate)]) {
                [self.delegate bomButtonViewDidClickBitrate];
            }
        }
            break;
        case APBomRightButtonTypeDebug:
        {
            if ([self.delegate respondsToSelector:@selector(bomButtonViewDidClickDebug)]) {
                [self.delegate bomButtonViewDidClickDebug];
            }
        }
            break;
        default:
            break;
    }
}

- (void)onHalfScreenButtonClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(bomButtonViewDidClickHalfScreen)]) {
        [self.delegate bomButtonViewDidClickHalfScreen];
    }
}

- (void)updateBitrateTitle:(NSString *)title
{
    for (UIButton *button in self.rightContainer.subviews) {
        if (button.tag == APBomRightButtonTypeBitrate) {
            [button setTitle:title forState:UIControlStateNormal];
        }
    }
}

- (void)updateSpeedTitle:(NSString *)title
{
    for (UIButton *button in self.rightContainer.subviews) {
        if (button.tag == APBomRightButtonTypeSpeed) {
            [button setTitle:title forState:UIControlStateNormal];
        }
    }
}

- (void)setMode:(AUIPlayerBomButtonViewMode)mode
{
    if (_mode == mode) {
        return;
    }
    
    _mode = mode;
    
    
    switch (mode) {
        case AUIPlayerBomButtonViewModeNormal:
            [self addNormalRightTitles];
            break;
        case AUIPlayerBomButtonViewModeListen:
            [self addNormalRightTitles];
            break;
    }

}

@end
