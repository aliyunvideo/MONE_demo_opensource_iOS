//
//  AUIRecorderCameraForceView.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/15.
//

#import "AUIRecorderCameraForceView.h"
#import "AVTimer.h"
#import "AUIUgsvMacro.h"

@interface AUIRecorderCameraForceView ()<AVTimerDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) NSTimeInterval hiddenTime;
@property (nonatomic, strong) UIImageView *sunImageView;
@property (nonatomic, strong) UIView *sunUpLineView;
@property (nonatomic, strong) UIView *sunDownLineView;
@end

@implementation AUIRecorderCameraForceView

- (instancetype) init {
    self = [super initWithFrame:CGRectMake(0, 0, 84.0, 84.0)];
    if (self) {
        [self setup];
        self.alpha = 0.0;
        [AVTimer.Shared startTimer:0.1 withTarget:self];
    }
    return self;
}

static UIView * s_createLineView() {
    UIView *view = [UIView new];
    view.backgroundColor = AUIFoundationColor(@"fill_infrared");
    view.layer.shadowColor = AUIFoundationColor(@"tsp_fill_medium").CGColor;
    view.layer.shadowOpacity = 0.7;
    view.layer.shadowRadius = 1.0;
    view.layer.shadowOffset = CGSizeMake(1.0, 1.0);
    return view;
}

- (void) setup {
    // clear
    [_imageView removeFromSuperview];
    [_sunUpLineView removeFromSuperview];
    [_sunDownLineView removeFromSuperview];
    [_sunImageView removeFromSuperview];
    
    // create
    _imageView = [[UIImageView alloc] initWithImage:AUIUgsvRecorderImage(@"ic_recorder_focus")];
    [self addSubview:_imageView];
    _sunImageView = [[UIImageView alloc] initWithImage:AUIUgsvRecorderImage(@"ic_light")];
    [self addSubview:_sunImageView];
    
    _sunUpLineView = s_createLineView();
    [self addSubview:_sunUpLineView];
    
    _sunDownLineView = s_createLineView();
    [self addSubview:_sunDownLineView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    _imageView.frame = self.bounds;
    
    const CGFloat kSunIconSize = 24.0;
    const CGFloat kSunIconSpace = 2.0;
    const CGFloat kSunLinWidth = 1.0;
    
    CGRect frame = CGRectMake(0, 0, kSunIconSize, kSunIconSize);
    frame.origin.x = size.width + 6.0;
    CGFloat centerY = size.height * 0.5 * (1.0 - self.currentExposure);
    frame.origin.y = centerY - kSunIconSize * 0.5;
    _sunImageView.frame = frame;
    
    CGFloat outHeight = kSunIconSize*0.5+kSunIconSpace;
    frame.origin.x = frame.origin.x + kSunIconSize * 0.5 - kSunLinWidth * 0.5;
    frame.origin.y = -outHeight;
    frame.size.width = kSunLinWidth;
    frame.size.height = _sunImageView.frame.origin.y - kSunIconSpace - frame.origin.y;
    _sunUpLineView.frame = frame;
    
    frame.origin.y = _sunImageView.frame.origin.y + kSunIconSize + kSunIconSpace;
    frame.size.height = size.height + outHeight - frame.origin.y;
    _sunDownLineView.frame = frame;
}

- (CGFloat) addExposure:(CGFloat)exposure {
    _currentExposure -= exposure;
    _currentExposure = MIN(1, MAX(-1, _currentExposure));
    _hiddenTime = NSDate.date.timeIntervalSince1970 + 2.0;
    self.isShowing = YES;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    return _currentExposure;
}

- (void) showOnPosition:(CGPoint)position {
    self.center = position;
    _hiddenTime = NSDate.date.timeIntervalSince1970 + 1.0;
    _currentExposure = 0.0;
    self.isShowing = YES;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setIsShowing:(BOOL)isShowing {
    if (_isShowing == isShowing) {
        return;
    }
    _isShowing = isShowing;
    if (isShowing) {
        self.alpha = 1.0;
        [self.superview bringSubviewToFront:self];
    }
    else {
        NSTimeInterval duration = 0.2;
        if (_currentExposure != 0) {
            duration = 1.0;
        }
        [UIView animateWithDuration:duration animations:^{
            self.alpha = 0.0;
        }];
    }
}

// MARK: - AVTimerDelegate
- (void)onAVTimerStepWithDuration:(NSTimeInterval)duration settingInterval:(NSTimeInterval)interval {
    if (self.isShowing && NSDate.date.timeIntervalSince1970 > _hiddenTime) {
        self.isShowing = NO;
    }
}

@end
