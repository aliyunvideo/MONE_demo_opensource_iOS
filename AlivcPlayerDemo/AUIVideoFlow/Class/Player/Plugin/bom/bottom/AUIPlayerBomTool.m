//
//  AUIPlayerBomTool.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/20.
//

#import "AUIPlayerBomTool.h"

@interface AUIPlayerBomTool()
@property (nonatomic, strong)  CAGradientLayer *gradientLayer;
@end

@implementation AUIPlayerBomTool

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
    [self.layer addSublayer:self.gradientLayer];
    [self addSubview:self.portraitButtonView];
    [self addSubview:self.progressView];
    [self addSubview:self.buttonView];
    [self.progressView addSubview:self.watchPointContainer];
}

- (void)setFullScreen:(BOOL)fullScreen
{
    if (_fullScreen != fullScreen) {
        _fullScreen = fullScreen;
        [self setNeedsLayout];
    }
}

- (AUIPlayerBomProgressView *)progressView
{
    if (!_progressView) {
        _progressView = [[AUIPlayerBomProgressView alloc] init];
        _progressView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"bomTool_progressView");
        _progressView.frame = CGRectMake(0, 0, self.buttonView.av_left, 42);
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        __weak typeof (self) weakSelf = self;

        _progressView.onSliderValueChanged = ^(float progress) {
            if ([weakSelf.delegate respondsToSelector:@selector(apBomSlideValueChanged:)]) {
                [weakSelf.delegate apBomSlideValueChanged:progress];
            }
        };
        _progressView.onSliderTouchBegin = ^(float progress) {
            if ([weakSelf.delegate respondsToSelector:@selector(apBomSlideTouchBegin:)]) {
                [weakSelf.delegate apBomSlideTouchBegin:progress];
            }
        };
        _progressView.onSliderTouchEnd = ^(float progress) {
            if ([weakSelf.delegate respondsToSelector:@selector(apBomSlideTouchEnd:)]) {
                [weakSelf.delegate apBomSlideTouchEnd:progress];
            }
        };
        
    }
    return _progressView;
    
}

- (CAGradientLayer *)gradientLayer
{
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        UIColor *color1 = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        UIColor *color2 = [UIColor clearColor];
        _gradientLayer.colors = @[ (__bridge id) color2.CGColor, (__bridge id) color1.CGColor,  ];
    }
    return _gradientLayer;
}

- (AUIPlayerBomButtonView *)buttonView
{
    if (!_buttonView) {
        _buttonView = [[AUIPlayerBomButtonView alloc] init];
        _buttonView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"bomTool_buttonView");
        _buttonView.frame = CGRectMake(0, self.progressView.av_bottom, self.av_width,  self.av_height - self.progressView.av_bottom);

    }
    return _buttonView;
}

- (UIView *)watchPointContainer
{
    if (!_watchPointContainer) {
        _watchPointContainer = [[AUIPlayerWatchPointContainer alloc] init];
        _watchPointContainer.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"bomTool_watchPointContainer");
        _watchPointContainer.hidden = YES;
    }
    return _watchPointContainer;
}

- (AUIPlayerBomPortraitButtons *)portraitButtonView
{
    if (!_portraitButtonView) {
        _portraitButtonView = [[AUIPlayerBomPortraitButtons alloc] initWithFrame:CGRectMake(self.av_width - 30, 0, 30, 42)];
        _portraitButtonView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"bomTool_portraitButtonView");
        __weak typeof (self) weakSelf = self;
        _portraitButtonView.onFullScreenBlock = ^{
            if ([weakSelf.delegate respondsToSelector:@selector(bomToolOnFullScreenClick)]) {
                [weakSelf.delegate bomToolOnFullScreenClick];
            }
        };

    }
    
    return _portraitButtonView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat pButonWidth = self.fullScreen ? 0: 60;
    
    if (!self.fullScreen) {
        pButonWidth = 30;
    }
    
    _portraitButtonView.hidden = self.fullScreen;
    _buttonView.hidden = !self.fullScreen;
    
    _watchPointContainer.hidden = !self.fullScreen;
    
    _portraitButtonView.frame = CGRectMake(self.av_width - pButonWidth, 0, pButonWidth, 42);
    if (self.fullScreen) {
        _progressView.frame = CGRectMake(24, 0, self.portraitButtonView.av_left - 24 *2, 42);

    } else {
        _progressView.frame = CGRectMake(0, 0, self.portraitButtonView.av_left, 42);

    }
    _buttonView.frame = CGRectMake(0, self.progressView.av_bottom, self.av_width,  self.av_height - self.progressView.av_bottom);

    
    _gradientLayer.frame = self.bounds;
    
    _watchPointContainer.frame = CGRectMake(0, 0, self.progressView.progressView.av_width, 20);
    _watchPointContainer.center = self.progressView.progressView.center;

}

@end
