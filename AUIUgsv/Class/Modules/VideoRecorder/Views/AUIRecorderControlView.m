//
//  AUIRecorderControlView.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/3.
//

#import "AUIRecorderControlView.h"
#import "AUIUgsvMacro.h"
#import "Masonry.h"
#import "AVBaseStateButton.h"
#import "AUIRecorderProgressView.h"
#import <AudioToolbox/AudioToolbox.h>

typedef NS_ENUM(NSUInteger, __RecordControlType) {
    __RecordControlTypeTap = 0,
    __RecordControlTypeLongPress,
};

@interface AUIRecorderControlView () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) AVBaseStateButton *controlBtn;
@property (nonatomic, assign) __RecordControlType controlType;
@property (nonatomic, assign) __RecordControlType currentControlType;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong) AUIRecorderProgressView *progressView;
// ControlTypeView
@property (nonatomic, assign) BOOL isShowControlTypeView;
@property (nonatomic, strong) UIView *controlTypeFlagView;
@property (nonatomic, strong) AVBaseButton *tapControlSelected;
@property (nonatomic, strong) AVBaseButton *longPressControlSelected;

@property (nonatomic, strong) MASConstraint *selectedTapConstraint;
@property (nonatomic, strong) MASConstraint *selectedLongPressConstraint;
@end

@implementation AUIRecorderControlView

- (instancetype) initWithDelegate:(id<AUIRecorderControlViewDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _isShowControlTypeView = YES;
        [self setupControlBtn];
        [self setupDurationView];
        [self setupControlTypeView];
    }
    return self;
}

- (void) setIsRecording:(BOOL)isRecording {
    if (_isRecording == isRecording) {
        return;
    }
    _isRecording = isRecording;
    if (_isRecording) {
        if (_longPressGesture.state == UIGestureRecognizerStatePossible) {
            self.currentControlType = __RecordControlTypeTap;
        }
    }
    else {
        self.currentControlType = self.controlType;
    }
    _controlBtn.disabled = _isRecording;
    [self updateControlTypeShow];
}

- (void) setIsShowControlTypeView:(BOOL)isShowControlTypeView {
    if (_isShowControlTypeView == isShowControlTypeView) {
        return;
    }
    _isShowControlTypeView = isShowControlTypeView;
    [self updateControlTypeView:YES];
}

- (void) setControlType:(__RecordControlType)controlType {
    if (_controlType == controlType) {
        return;
    }
    _controlType = controlType;
    self.currentControlType = controlType;
    [self updateControlTypeView:YES];
}

- (void) setCurrentControlType:(__RecordControlType)currentControlType {
    if (_currentControlType == currentControlType) {
        return;
    }
    _currentControlType = currentControlType;
    _controlBtn.customState = (int)currentControlType;
}

// MARK: - Actions
- (void) onWantChangeRecordState:(BOOL)isRecord fromLongPress:(BOOL)isFromLongPress {
    if (isRecord == _isRecording) {
        return;
    }
    
    if (self.totalDuration >= self.maxDuration) {
        return;
    }
    
    if (isRecord) {
        self.controlType = isFromLongPress ? __RecordControlTypeLongPress : __RecordControlTypeTap;
        AudioServicesPlaySystemSound(1520); // 普通短震 （类似3D Touch Pop 反馈）
        if ([_delegate respondsToSelector:@selector(onAUIRecorderControlViewWantStart:)]) {
            [_delegate onAUIRecorderControlViewWantStart:self];
        }
    }
    else {
        if ([_delegate respondsToSelector:@selector(onAUIRecorderControlViewWantStop:)]) {
            [_delegate onAUIRecorderControlViewWantStop:self];
        }
    }
}

- (void) onControlLongPress:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateEnded || longPress.state == UIGestureRecognizerStateCancelled) {
        [self onWantChangeRecordState:NO fromLongPress:YES];
    }
    else if (longPress.state == UIGestureRecognizerStateBegan) {
        [self onWantChangeRecordState:YES fromLongPress:YES];
    }
}

// MARK: - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.controlType != __RecordControlTypeLongPress) {
        return NO; // 不自动选择，统一切换按钮确定
    }
    return YES;
}

// MARK: - UI
- (void) setupDurationView {
    // clear
    [_durationLabel removeFromSuperview];
    
    _durationLabel = [UILabel new];
    _durationLabel.text = @"";
    _durationLabel.font = AVGetRegularFont(12);
    _durationLabel.textColor = AUIFoundationColor(@"text_strong");
    [self addSubview:_durationLabel];
    [_durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).inset(10);
        make.bottom.equalTo(_controlBtn.mas_top).inset(10);
    }];
    
    [self updateDuration];
}

- (UIView *) controlView {
    return _controlBtn;
}

- (void) setupControlBtn {
    // clear
    [_controlBtn removeFromSuperview];
    [_longPressGesture removeTarget:self action:@selector(onControlLongPress:)];
    
    // create
    NSDictionary<NSNumber *, AVBaseStateButtonInfo *> *StateInfo = @{
        @(__RecordControlTypeTap): [AVBaseStateButtonInfo InfoWithImage:AUIUgsvRecorderImage(@"btn_record")
                                                          disabledImage:AUIUgsvRecorderImage(@"btn_recording")],
        @(__RecordControlTypeLongPress): [AVBaseStateButtonInfo InfoWithImage:AUIUgsvRecorderImage(@"btn_record_long_press")
                                                                disabledImage:AUIUgsvRecorderImage(@"btn_recording_long_press")]
    };
    _controlBtn = [[AVBaseStateButton alloc] initWithStateInfos:StateInfo buttonType:AVBaseButtonTypeOnlyImage];
    __weak typeof(self) weakSelf = self;
    [_controlBtn setAction:^(AVBaseButton *btn) {
        BOOL wantStart = !btn.disabled;
        if (wantStart && weakSelf.controlType != __RecordControlTypeTap) {
            return; // 不自动选择，统一切换按钮确定
        }
        [weakSelf onWantChangeRecordState:wantStart fromLongPress:NO];
    }];
    [self addSubview:_controlBtn];
    [_controlBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).inset(50.0);
    }];
    
    _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onControlLongPress:)];
    _longPressGesture.minimumPressDuration = 0.1;
    _longPressGesture.delegate = self;
    [_controlBtn addGestureRecognizer:_longPressGesture];
    
    _progressView = [AUIRecorderProgressView new];
    [_controlBtn addSubview:_progressView];
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_controlBtn);
    }];
}

- (void) setupControlTypeView {
    // clear
    [_controlTypeFlagView removeFromSuperview];
    [_tapControlSelected removeFromSuperview];
    [_longPressControlSelected removeFromSuperview];
    
    // create
    _controlTypeFlagView = [UIView new];
    _controlTypeFlagView.backgroundColor = AUIFoundationColor(@"colourful_fill_strong");
    _controlTypeFlagView.layer.cornerRadius = 2.0;
    _controlTypeFlagView.layer.masksToBounds = YES;
    [self addSubview:_controlTypeFlagView];
    [_controlTypeFlagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(4.0);
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).inset(6.0);
    }];
    
    __weak typeof(self) weakSelf = self;
    _tapControlSelected = [AVBaseButton TextButton];
    _tapControlSelected.insets = UIEdgeInsetsMake(8, 8, 8, 8);
    _tapControlSelected.title = AUIUgsvGetString(@"单击拍摄");
    _tapControlSelected.font = AVGetRegularFont(12.0);
    _tapControlSelected.disabledColor = AUIFoundationColor(@"text_medium");
    [_tapControlSelected setAction:^(AVBaseButton *_) {
        weakSelf.controlType = __RecordControlTypeTap;
    }];
    [self addSubview:_tapControlSelected];
    [_tapControlSelected mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_controlTypeFlagView.mas_top).inset(2.0);
        _selectedTapConstraint = make.centerX.equalTo(self);
    }];
    [_selectedTapConstraint uninstall];

    _longPressControlSelected = [AVBaseButton TextButton];
    _longPressControlSelected.insets = UIEdgeInsetsMake(8, 8, 8, 8);
    _longPressControlSelected.title = AUIUgsvGetString(@"长按拍摄");
    _longPressControlSelected.font = AVGetRegularFont(12.0);
    _longPressControlSelected.disabledColor = AUIFoundationColor(@"text_medium");
    [_longPressControlSelected setAction:^(AVBaseButton * _Nonnull btn) {
        weakSelf.controlType = __RecordControlTypeLongPress;
    }];
    [self addSubview:_longPressControlSelected];
    [_longPressControlSelected mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_controlTypeFlagView.mas_top).inset(2.0);
        make.left.equalTo(_tapControlSelected.mas_right).inset(8.0);
        _selectedLongPressConstraint = make.centerX.equalTo(self);
    }];
    [_selectedLongPressConstraint uninstall];
    
    [self updateControlTypeView:NO];
}

- (void) updateControlTypeView:(BOOL)animation {
    CGFloat showAlpha = _isShowControlTypeView ? 1.0 : 0.0;
    _controlTypeFlagView.alpha = showAlpha;
    _tapControlSelected.alpha = showAlpha;
    _longPressControlSelected.alpha = showAlpha;
    
    BOOL isTap = (_controlType == __RecordControlTypeTap);
    _tapControlSelected.disabled = !isTap;
    _longPressControlSelected.disabled = isTap;
    
    if (isTap) {
        [_selectedLongPressConstraint uninstall];
        [_selectedTapConstraint install];
    }
    else {
        [_selectedTapConstraint uninstall];
        [_selectedLongPressConstraint install];
    }
    
    [_tapControlSelected updateConstraintsIfNeeded];
    [_longPressControlSelected updateConstraintsIfNeeded];
    
    if (animation) {
        [UIView animateWithDuration:0.2 animations:^{
            [self layoutIfNeeded];
        }];
    }
}

- (void) updateControlTypeShow {
    self.isShowControlTypeView = !_isRecording && self.totalDuration == 0.0;
}

- (void) updateDuration {
    [self updateTotalDurationLabel];
    [self updateControlTypeShow];
}

- (void) updateTotalDurationLabel {
    int duration = self.totalDuration;
    _durationLabel.alpha = (duration == 0 && !_isRecording) ? 0.0 : 1.0;
    int sec = duration % 60;
    int min = duration / 60;
    _durationLabel.text = [NSString stringWithFormat:@"%02d:%02d", min, sec];
}

- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
        return nil;
    }
    return view;
}

// MARK: - passthrough
- (void) setMaxDuration:(NSTimeInterval)maxDuration {
    _progressView.maxDuration = maxDuration;
}
- (NSTimeInterval) maxDuration {
    return _progressView.maxDuration;
}

- (void) setPartDurations:(NSArray<NSNumber *> *)partDurations {
    _progressView.partDurations = partDurations;
    [self updateDuration];
}
- (NSArray<NSNumber *> *) partDurations {
    return _progressView.partDurations;
}

- (void) setCurrentPartDuration:(NSTimeInterval)currentPartDuration {
    _progressView.currentPartDuration = currentPartDuration;
    [self updateDuration];
}
- (NSTimeInterval) currentPartDuration {
    return _progressView.currentPartDuration;
}

- (NSTimeInterval) totalDuration {
    return _progressView.totalDuration;
}

@end
