//
//  AUIPlayerFlowAutoProgress.m
//  AUIVideoCustom
//
//  Created by ISS013602000846 on 2022/6/13.
//

#import "AUIPlayerFlowAutoProgress.h"

static const CGFloat AUIPlayerFlowAutoProgressViewLoadtimeViewLeft      = 2 ;  //loadtimeView 左侧距离父视图距离

@interface AUIPlayerFlowAutoProgress ()

// @property (nonatomic, strong) UIProgressView *loadtimeView; //缓冲条，loadTime
@property (nonatomic, strong) UIProgressView *timeView; //进度条

@end

@implementation AUIPlayerFlowAutoProgress

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        // [self addSubview:self.loadtimeView];
        [self addSubview:self.timeView];
    }
    return self;
}

//- (UIProgressView *)loadtimeView{
//    if (!_loadtimeView) {
//        _loadtimeView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
//        _loadtimeView.progress = 0.0;
//        //设置它的风格，为默认的
//        _loadtimeView.trackTintColor= AUIVideoFlowColor(@"vf_progress_track");
//        //设置轨道的颜色
//        _loadtimeView.progressTintColor= AUIVideoFlowColor(@"vf_progress");
//    }
//    return _loadtimeView;
//}

- (UIProgressView *)timeView{
    if (!_timeView) {
        _timeView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _timeView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"bomFlowAutoProgress_timeView");
        _timeView.progress = 0.0;
        //设置它的风格，为默认的
        _timeView.trackTintColor= AUIVideoFlowColor(@"vf_progress_track");
        //设置轨道的颜色
        _timeView.progressTintColor= AUIVideoFlowColor(@"vf_slider");
    }
    return _timeView;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    //self.loadtimeView.frame = CGRectMake(AUIPlayerFlowAutoProgressViewLoadtimeViewLeft, 0, self.av_width - AUIPlayerFlowAutoProgressViewLoadtimeViewLeft * 2, self.av_height);
    self.timeView.frame = CGRectMake(AUIPlayerFlowAutoProgressViewLoadtimeViewLeft, 0, self.av_width - AUIPlayerFlowAutoProgressViewLoadtimeViewLeft * 2, self.av_height);
    //self.timeView.frame = self.loadtimeView.frame;
}

#pragma mark - 重写setter方法
- (void)setProgress:(float)progress{
    _progress = progress;
    self.timeView.progress = progress;
}

- (void)setLoadTimeProgress:(float)loadTimeProgress{
    _loadTimeProgress = loadTimeProgress;
    // [self.loadtimeView setProgress:loadTimeProgress];
}

@end
