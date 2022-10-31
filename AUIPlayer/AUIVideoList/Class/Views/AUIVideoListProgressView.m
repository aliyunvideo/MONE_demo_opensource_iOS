//
//  AUIVideoListProgressView.m
//  AUIVideoList
//
//  Created by ISS013602000846 on 2022/6/7.
//

#import "AUIVideoListProgressView.h"

#pragma mark -- AUIVideoProgress
@interface AUIVideoProgress : UIView

@property (nonatomic, strong) UIView *trackView;
@property (nonatomic, assign) float progress;
@property (nonatomic, strong) UIColor *trackTintColor;
@property (nonatomic, strong) UIColor *progressTintColor;

@end

@implementation AUIVideoProgress

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.trackView];
    }
    return self;
}

- (UIView *)trackView
{
    if (!_trackView) {
        _trackView = [[UIView alloc]init];
        _trackView.accessibilityIdentifier = AUIVideoListAccessibilityStr(@"trackView");
    }
    return _trackView;
}

- (void)setProgress:(float)progress
{
    NSLog(@"progress:%f",progress);
    progress = MAX(0, progress);
    progress = MIN(1, progress);

    if (_progress != progress) {
        _progress = progress;
        [self setNeedsLayout];
    }
}

- (void)setTrackTintColor:(UIColor *)trackTintColor
{
    self.backgroundColor = trackTintColor;
}

- (void)setProgressTintColor:(UIColor *)progressTintColor
{
    self.trackView.backgroundColor = progressTintColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.trackView.frame = CGRectMake(0, 0, self.av_width * self.progress, self.av_height);
}

@end

#pragma mark -- AUIVideoListProgressView
@interface AUIVideoListProgressView ()

@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) AUIVideoProgress *progressView;
@property (nonatomic, assign) bool draging;

@end

@implementation AUIVideoListProgressView

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
    self.slider.transform = CGAffineTransformMakeScale(0.7, 0.7);
    [self addSubview:self.progressView];
    [self addSubview:self.slider];
    
    CGRect rect = CGRectMake(0, 0, self.av_width, self.av_height);
    self.progressView.frame = self.slider.frame = rect;
    self.progressView.av_height = 1;
    self.progressView.av_left -= 2;
    self.progressView.av_width -= 4;
    
    self.progressView.center = self.slider.center;
    
}

- (AUIVideoProgress *)progressView
{
    if (!_progressView) {
        _progressView = [[AUIVideoProgress alloc] init];
        _progressView.accessibilityIdentifier = AUIVideoListAccessibilityStr(@"videoProgressView");
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _progressView.trackTintColor = AUIVideoListColor(@"vl_progress_track");
        _progressView.progressTintColor = AUIVideoListColor(@"vl_progress");
        _progressView.progress = 0.0;

        
    }
    return _progressView;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
   UIView *view = [super hitTest:point withEvent:event];
    return view;
    
}


- (UISlider *)slider
{
    if (!_slider) {
        _slider = [[UISlider alloc] init];
        _slider.accessibilityIdentifier = AUIVideoListAccessibilityStr(@"slider");
        [_slider setThumbTintColor:AUIVideoListColor(@"vl_slider_bg")];
        [_slider setTintColor:AUIVideoListColor(@"vl_slider_bg")];
//        UIImage *image = [UIImage av_imageWithColor:APGetColor(APColorTypeCyanBg)];
//        image = [image sd_resizedImageWithSize:CGSizeMake(28, 28) scaleMode:0];
//        image = [image sd_roundedCornerImageWithRadius:14 corners:UIRectCornerAllCorners borderWidth:0 borderColor:nil];
//        [_slider setThumbImage:image forState:UIControlStateNormal];
//        [_slider setThumbImage:image forState:UIControlStateHighlighted];
        _slider.continuous = NO;
        
        [_slider addTarget:self action:@selector(onEndSlide:) forControlEvents:UIControlEventTouchUpInside];

        [_slider addTarget:self action:@selector(onSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        [_slider addTarget:self action:@selector(onBeginSlide:) forControlEvents:UIControlEventTouchDragInside];
        
        [_slider addTarget:self action:@selector(onEndSlide:) forControlEvents:UIControlEventTouchDragOutside];
    }
    return _slider;
}

- (void)onEndSlide:(UISlider *)slider
{
    self.draging = NO;

    if (self.onSliderTouchEnd) {
        self.onSliderTouchEnd(slider.value);
    }
    
}

- (void)onBeginSlide:(UISlider *)slider
{
    self.draging = YES;
    
    if (self.onSliderTouchBegin) {
        self.onSliderTouchBegin(slider.value);
    }
}

- (void)onSliderValueChanged:(UISlider *)slider
{
    if (self.onSliderValueChanged) {
        self.onSliderValueChanged(slider.value);
    }
}

- (void)updateSliderValue:(int64_t)position duration:(int64_t)duration
{
    if (duration <= 0) {
        return;
    }
    
    if (self.draging ) {
        return;;
    }

    self.slider.value = position/(float)duration;
}

- (void)updateCacheProgressValue:(int64_t)position duration:(int64_t)duration
{
    if (duration <= 0) {
        return;
    }
    
    self.progressView.progress = position/(float)duration;
}

@end
