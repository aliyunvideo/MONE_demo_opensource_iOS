//
//  AUIPlayerBomProgressView.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/20.
//

#import "AUIPlayerBomProgressView.h"
#import "AlivcPlayerAsset.h"
#import <SDWebImage/UIImage+Transform.h>
#import "AUIPlayerProgressView.h"

const static CGFloat kPadding = 12;
const static CGFloat kTimeLabelWidth = 38;

@interface AUIPlayerBomProgressView()
@property (nonatomic) bool draging;
@end


@implementation AUIPlayerBomProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.leftTimeLabel.frame = CGRectMake(kPadding, 0, kTimeLabelWidth, self.av_height);
    self.rightTimeLabel.frame = CGRectMake(self.av_width - kTimeLabelWidth - kPadding, 0, kTimeLabelWidth, self.av_height);
    
    CGFloat contentWidth = self.rightTimeLabel.av_left - self.leftTimeLabel.av_right - kPadding;
    CGRect rect = CGRectMake(self.leftTimeLabel.av_right + kPadding /2, 0, contentWidth, self.av_height);
    self.progressView.frame = self.slider.frame = rect;
    self.progressView.av_height = 1;
    self.progressView.av_left -= 2;
    self.progressView.av_width -= 4;
    
    self.progressView.center = self.slider.center;
    self.slider.transform = CGAffineTransformMakeScale(0.5, 0.5);



}

- (void)setupUI
{
    [self addSubview:self.progressView];
    [self addSubview:self.slider];
    
    [self addSubview:self.leftTimeLabel];
    [self addSubview:self.rightTimeLabel];

}

- (AUIPlayerProgressView *)progressView
{
    if (!_progressView) {
        _progressView = [[AUIPlayerProgressView alloc] init];
        _progressView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"bom_progressView");
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _progressView.trackTintColor = APGetColor(APColorTypeWhiteBg20);
        _progressView.progressTintColor = APGetColor(APColorTypeWhiteBg70);
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
        _slider.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"bom_slider");
        [_slider setThumbTintColor:APGetColor(APColorTypeCyanBg)];
        [_slider setTintColor:APGetColor(APColorTypeCyanBg)];
        UIImage *image = [UIImage av_imageWithColor:APGetColor(APColorTypeCyanBg) size:CGSizeMake(28, 28)];
        image = [image sd_resizedImageWithSize:CGSizeMake(28, 28) scaleMode:0];
        image = [image sd_roundedCornerImageWithRadius:14 corners:UIRectCornerAllCorners borderWidth:0 borderColor:nil];
        [_slider setThumbImage:image forState:UIControlStateNormal];
        [_slider setThumbImage:image forState:UIControlStateHighlighted];
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

- (UILabel *)leftTimeLabel
{
    if(!_leftTimeLabel) {
        _leftTimeLabel = [[UILabel alloc] init];
        _leftTimeLabel.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"bom_leftTimeLabel");
        _leftTimeLabel.textColor = UIColor.whiteColor;
        _leftTimeLabel.font = AVGetRegularFont(14);
        _leftTimeLabel.text  =@"00:00";
    }
    return _leftTimeLabel;
}

- (UILabel *)rightTimeLabel
{
    if(!_rightTimeLabel) {
        _rightTimeLabel = [[UILabel alloc] init];
        _rightTimeLabel.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"bom_rightTimeLabel");
        _rightTimeLabel.textColor = UIColor.whiteColor;
        _rightTimeLabel.font = AVGetRegularFont(14);
        _rightTimeLabel.text  =@"00:00";

    }
    return _rightTimeLabel;
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
    self.leftTimeLabel.text =  [self.class timeformatFromMilSeconds:position];
    self.rightTimeLabel.text =  [self.class timeformatFromMilSeconds:duration];

}

- (void)updateCacheProgressValue:(int64_t)position duration:(int64_t)duration
{
    if (duration <= 0) {
        return;
    }
    
    self.progressView.progress = position/(float)duration;
}

+ (NSString *)timeformatFromMilSeconds:(NSInteger)seconds {
    //s
    seconds = seconds/1000;
    
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld", (long) (seconds / 60) % 60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld", (long) seconds % 60];
    //format of time
    NSString *format_time = nil;

    format_time = [NSString stringWithFormat:@"%@:%@", str_minute, str_second];
    
    return format_time;
}


@end
