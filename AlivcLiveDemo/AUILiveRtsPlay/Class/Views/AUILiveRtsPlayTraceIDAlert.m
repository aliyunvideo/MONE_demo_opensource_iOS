//
//  AUILiveRtsPlayTraceIDAlert.m
//  AUILiveRtsPlay
//
//  Created by ISS013602000846 on 2022/8/2.
//

#import "AUILiveRtsPlayTraceIDAlert.h"
#import "AVToastView.h"

@interface AUILiveRtsPlayTraceIDAlert ()<UITextFieldDelegate>

@property (nonatomic, strong) NSString *traceID;
@property (nonatomic, strong) NSString *playUrl;
@property (nonatomic, strong) UIView *sourceView;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *traceIDView;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, copy) void(^copyHandle)(void);

@end

@implementation AUILiveRtsPlayTraceIDAlert

- (instancetype)init {
    if (self = [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = AUILiveRtsPlayColor(@"rp_toast_bg");
    }
    return self;
}

+ (void)show:(NSString *)traceID playUrl:(NSString *)playUrl view:(UIView *)view copyHandle:(void(^)(void))copyHandle {
    AUILiveRtsPlayTraceIDAlert *alertView = [[AUILiveRtsPlayTraceIDAlert alloc] init];
    alertView.sourceView = view;
    alertView.traceID = traceID;
    alertView.playUrl = playUrl;
    alertView.copyHandle = copyHandle;
    [view addSubview:alertView];
    [alertView show];
}

- (void)show {
    [self showAnimation];
}

- (void)showAnimation {
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.25;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2f, 1.2f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05f, 1.05f, 1.05f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.0f, @0.2f, @0.4f, @1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.contentView.layer addAnimation:popAnimation forKey:nil];
}
   
- (void)hide {
    [self hideAnimation];
}

- (void)hideAnimation {
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    }];
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.toValue = [NSNumber numberWithFloat:0.4];
    scaleAnimation.duration = 0.3f;
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.contentView.layer addAnimation:scaleAnimation forKey:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });
}

- (void)pressCopy {
    NSString *textCopyInfo = [NSString stringWithFormat:@"requestid:%@;url:%@", self.traceID, self.playUrl];
    UIPasteboard *systemBoard = [UIPasteboard generalPasteboard];
    systemBoard.string = textCopyInfo;
    [self hide];
    if (self.copyHandle) {
        self.copyHandle();
    }
}

- (void)pressClose {
    [self hide];
}

#pragma mark -- lazy load

- (UILabel *)traceIDView {
    if (!_traceIDView) {
        
        UILabel *traceIDTipLabel = [[UILabel alloc] init];
        traceIDTipLabel.text = AUILiveRtsPlayString(@"若您在体验Demo时碰到问题，请将以下信息通过工单的形式提交给售后");
        traceIDTipLabel.textColor = AUIFoundationColor(@"text_strong");
        traceIDTipLabel.font = AVGetRegularFont(16);
        traceIDTipLabel.numberOfLines = 0;
        CGFloat tipHeight = [traceIDTipLabel sizeThatFits:CGSizeMake(self.contentView.av_width - 24 * 2, MAXFLOAT)].height + 5;
        traceIDTipLabel.frame = CGRectMake(24, 15, self.contentView.av_width - 24 * 2, tipHeight);
        [self.contentView addSubview:traceIDTipLabel];
        
        _traceIDView = [[UILabel alloc] init];
        _traceIDView.text = self.traceID;
        _traceIDView.textColor = AUIFoundationColor(@"text_weak");
        _traceIDView.font = AVGetRegularFont(14);
        _traceIDView.numberOfLines = 0;
        CGFloat height = [_traceIDView sizeThatFits:CGSizeMake(self.contentView.av_width - 24 * 2, MAXFLOAT)].height + 5;
        _traceIDView.frame = CGRectMake(24, traceIDTipLabel.av_bottom + 8, self.contentView.av_width - 24 * 2, height);
        
        UILabel *copyLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, _traceIDView.av_bottom + 8, self.contentView.av_width - 24 * 2, 22)];
        copyLabel.text = AUILiveRtsPlayString(@"复制");
        copyLabel.textColor = AUILiveRtsPlayColor(@"rp_startbtn_select");
        copyLabel.font = AVGetRegularFont(14);
        copyLabel.userInteractionEnabled = YES;
        [self.contentView addSubview:copyLabel];
        
        UITapGestureRecognizer *copyTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressCopy)];
        [copyLabel addGestureRecognizer:copyTap];
    
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, copyLabel.av_bottom + 24, self.contentView.av_width, 1)];
        topLine.backgroundColor = AUIFoundationColor(@"border_weak");
        [self.contentView addSubview:topLine];
        
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(0, topLine.av_bottom + 10, self.contentView.av_width, 24);
        [_closeButton setTitle:AUILiveRtsPlayString(@"关闭") forState:UIControlStateNormal];
        [_closeButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
        _closeButton.titleLabel.font = AVGetRegularFont(16);
        [_closeButton addTarget:self action:@selector(pressClose) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_closeButton];
    }
    return _traceIDView;
}

- (UIView *)contentView {
    if (!_contentView) {
        
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(32, 0, self.av_width - 32 * 2, 0)];
        _contentView.backgroundColor = AUIFoundationColor(@"fg_strong");
        _contentView.layer.cornerRadius = 16;
        _contentView.layer.masksToBounds = YES;
        [self addSubview:_contentView];
        
        [_contentView addSubview:self.traceIDView];
        CGFloat contentHeight = self.closeButton.av_bottom + 15;
        _contentView.av_top = (self.av_height - contentHeight) / 2.0;
        _contentView.av_height = contentHeight;
    }
    return _contentView;
}

@end
