//
//  AUIRecorderHeaderButtonsView.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/2.
//

#import "AUIRecorderHeaderButtonsView.h"
#import "AVBaseStateButton.h"
#import "Masonry.h"
#import "AUIUgsvMacro.h"

@interface AUIRecorderHeaderButtonsView ()
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, AVBaseButton *> *buttons;
@end

@implementation AUIRecorderHeaderButtonsView

- (instancetype) initWithDelegate:(id<AUIRecorderHeaderButtonsViewDelegate>)delegate {
    NSArray *showTypes = @[@(AUIRecorderHeaderBtnTypeCountDown),
                           @(AUIRecorderHeaderBtnTypeCameraTorch),
                           @(AUIRecorderHeaderBtnTypeCameraPosition)];
    return [self initWithShowTypes:showTypes delegate:delegate];
}

- (instancetype) initWithShowTypes:(NSArray<NSNumber *> *)showTypes
                          delegate:(id<AUIRecorderHeaderButtonsViewDelegate>)delegate {
    self = [super init];
    if (self) {
        _showTypes = showTypes.copy;
        _delegate = delegate;
        _buttons = @{}.mutableCopy;
        [self setupButtons];
    }
    return self;
}

- (void) setCountDownDisabled:(BOOL)countDownDisabled {
    _countDownDisabled = countDownDisabled;
    [self updateCountDownUI];
}

- (void) setTorchDisabled:(BOOL)torchDisabled {
    _torchDisabled = torchDisabled;
    if (torchDisabled && _torchOpened) {
        _torchOpened = NO;
    }
    [self updateTorchBtnUI];
}

- (void) setTorchOpened:(BOOL)torchOpened {
    _torchOpened = torchOpened;
    [self updateTorchBtnUI];
}

- (void) setIsRecording:(BOOL)isRecording {
    _isRecording = isRecording;
    [self updateUIForRecordState:YES];
}

// MARK: - Actions
- (void) onBtnDidPressed:(AUIRecorderHeaderBtnType)type {
    if ([_delegate respondsToSelector:@selector(onAUIRecorderHeaderButtonsView:btnDidPressed:)]) {
        [_delegate onAUIRecorderHeaderButtonsView:self btnDidPressed:type];
    }
}

// MARK: - UI
- (void) setupButtons {
    // clear
    [_stackView removeFromSuperview];
    [_buttons removeAllObjects];
    
    // create
    _stackView = [UIStackView new];
    _stackView.axis = UILayoutConstraintAxisHorizontal;
    _stackView.alignment = UIStackViewAlignmentCenter;
    _stackView.spacing = 42.0;
    [self addSubview:_stackView];
    [_stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    const NSDictionary<NSNumber *, AVBaseStateButtonInfo *> *StateInfos = @{
        @(AUIRecorderHeaderBtnTypeCountDown): [AVBaseStateButtonInfo InfoWithImage:AUIUgsvRecorderImage(@"ic_countdown")],
        @(AUIRecorderHeaderBtnTypeCameraTorch): [AVBaseStateButtonInfo InfoWithImage:AUIUgsvRecorderImage(@"ic_torch_off")
                                                                       selectedImage:AUIUgsvRecorderImage(@"ic_torch_on")
                                                                       disabledImage:AUIUgsvRecorderImage(@"ic_torch_off")],
        @(AUIRecorderHeaderBtnTypeCameraPosition): [AVBaseStateButtonInfo InfoWithImage:AUIUgsvRecorderImage(@"ic_camera_pos")]
    };
    
    __weak typeof(self) weakSelf = self;
    for (NSNumber *type in _showTypes) {
        AVBaseButton *btn = [AVBaseButton ImageButton];
        btn.image = StateInfos[type].image;
        btn.disabledImage = StateInfos[type].disabledImage;
        btn.selectedImage = StateInfos[type].selectedImage;
        [btn setAction:^(AVBaseButton *_) {
            [weakSelf onBtnDidPressed:type.intValue];
        }];
        [_stackView addArrangedSubview:btn];
        _buttons[type] = btn;
    }
    
    [self updateTorchBtnUI];
    [self updateCountDownUI];
    [self updateUIForRecordState:NO];
}

- (void) updateCountDownUI {
    _buttons[@(AUIRecorderHeaderBtnTypeCountDown)].hidden = self.countDownDisabled;
}

- (void) updateTorchBtnUI {
    AVBaseButton *btn = _buttons[@(AUIRecorderHeaderBtnTypeCameraTorch)];
    if (!btn) {
        return;
    }
    
    if (_torchDisabled) {
        btn.state = AVBaseButtonStateDisabled;
    } else if (_torchOpened) {
        btn.state = AVBaseButtonStateSelected;
    } else {
        btn.state = AVBaseButtonStateNormal;
    }
}

- (void) updateUIForRecordState:(BOOL)animation {
    void(^change)(void) = ^{
        CGFloat targetAlpha = (self.isRecording ? 0.0 : 1.0);
        for (NSNumber *type in self.buttons) {
            if (type.intValue != AUIRecorderHeaderBtnTypeCameraPosition &&
                type.intValue != AUIRecorderHeaderBtnTypeCameraTorch) {
                self.buttons[type].alpha = targetAlpha;
            }
        }
    };
    
    if (animation) {
        [UIView animateWithDuration:0.2 animations:change];
    } else {
        change();
    }
}

@end
