//
//  AUIRecorderSliderButtonsView.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/1.
//

#import "AUIRecorderSliderButtonsView.h"
#import "AVBaseStateButton.h"
#import "AUIUgsvMacro.h"
#import "Masonry.h"

@interface AUIRecorderSliderButtonsView ()
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, AVBaseStateButton *> *buttons;
@end

@implementation AUIRecorderSliderButtonsView

- (instancetype)initWithMix:(BOOL)isMix withDelegate:(id<AUIRecorderSliderButtonsViewDelegate>)delegate {
    NSArray *showTypes = @[@(AUIRecorderSlidBtnTypeMusic),
                           @(AUIRecorderSlidBtnTypeFilter),
                           @(AUIRecorderSlidBtnTypeResolution),
                           @(AUIRecorderSlidBtnTypeSpecialEffects),
                           @(AUIRecorderSlidBtnTypeTakePhoto)];
    if (isMix) {
        showTypes = @[@(AUIRecorderSlidBtnTypeFilter),
                      @(AUIRecorderSlidBtnTypeSpecialEffects),
                      @(AUIRecorderSlidBtnTypeMixLayout)];
    }
    return [self initWithShowTypes:showTypes delegate:delegate];
}

- (instancetype) initWithShowTypes:(NSArray<NSNumber *> *)showTypes
                          delegate:(id<AUIRecorderSliderButtonsViewDelegate>)delegate {
    self = [super init];
    if (self) {
        _showTypes = showTypes.copy;
        _delegate = delegate;
        _buttons = @{}.mutableCopy;
        [self setupButtons];
    }
    return self;
}

- (void) setMusicDisabled:(BOOL)musicDisabled {
    _musicDisabled = musicDisabled;
    [self updateMusicBtnUI];
}

- (void) setResolution:(AUIRecorderResolutionRatio)resolution {
    _resolution = resolution;
    [self updateResolutionBtnUI];
}

- (void) setResolutionDisabled:(BOOL)resolutionDisabled {
    _resolutionDisabled = resolutionDisabled;
    [self updateResolutionBtnUI];
}

- (void) setMixType:(AUIRecorderMixType)mixType {
    _mixType = mixType;
    [self updateMixLayoutBtnUI];
}

- (void) setMixLayoutDisabled:(BOOL)mixLayoutDisabled {
    _mixLayoutDisabled = mixLayoutDisabled;
    [self updateMixLayoutBtnUI];
}

// MARK: - Actions
- (void) onBtnDidPressed:(AUIRecorderSlidBtnType)type {
    if ([_delegate respondsToSelector:@selector(onAUIRecorderSliderButtonsView:btnDidPressed:)]) {
        [_delegate onAUIRecorderSliderButtonsView:self btnDidPressed:type];
    }
}

// MARK: - UI
- (void) setupButtons {
    // clear
    [_stackView removeFromSuperview];
    [_buttons removeAllObjects];
    
    // create
    _stackView = [UIStackView new];
    _stackView.axis = UILayoutConstraintAxisVertical;
    _stackView.alignment = UIStackViewAlignmentCenter;
    _stackView.spacing = 20.0;
    [self addSubview:_stackView];
    [_stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    const NSDictionary<NSNumber *, NSDictionary<NSNumber *, AVBaseStateButtonInfo *> *> *StateInfos = @{
        @(AUIRecorderSlidBtnTypeMusic): @{
            @0: [AVBaseStateButtonInfo InfoWithTitle:AUIUgsvGetString(@"剪音乐") image:AUIUgsvRecorderImage(@"ic_music") disabledImage:AUIUgsvRecorderImage(@"ic_music_disabled")]
        },
        @(AUIRecorderSlidBtnTypeFilter): @{
            @0: [AVBaseStateButtonInfo InfoWithTitle:AUIUgsvGetString(@"滤镜") image:AUIUgsvRecorderImage(@"ic_filter")]
        },
        @(AUIRecorderSlidBtnTypeResolution): @{
            @(AUIRecorderResolutionRatio_9_16): [AVBaseStateButtonInfo InfoWithTitle:AUIUgsvGetString(@"切画稿") image:AUIUgsvRecorderImage(@"ic_resolution_9_16") disabledImage:AUIUgsvRecorderImage(@"ic_resolution_9_16_disabled")],
            @(AUIRecorderResolutionRatio_3_4): [AVBaseStateButtonInfo InfoWithImage:AUIUgsvRecorderImage(@"ic_resolution_3_4") disabledImage:AUIUgsvRecorderImage(@"ic_resolution_3_4_disabled")],
            @(AUIRecorderResolutionRatio_1_1): [AVBaseStateButtonInfo InfoWithImage:AUIUgsvRecorderImage(@"ic_resolution_1_1") disabledImage:AUIUgsvRecorderImage(@"ic_resolution_1_1_disabled")],
        },
        @(AUIRecorderSlidBtnTypeSpecialEffects): @{
            @0: [AVBaseStateButtonInfo InfoWithTitle:AUIUgsvGetString(@"特效") image:AUIUgsvRecorderImage(@"ic_special_effects")]
        },
        @(AUIRecorderSlidBtnTypeTakePhoto): @{
            @0: [AVBaseStateButtonInfo InfoWithTitle:AUIUgsvGetString(@"拍照") image:AUIUgsvRecorderImage(@"ic_take_photo")]
        },
        @(AUIRecorderSlidBtnTypeMixLayout): @{
            @(0): [AVBaseStateButtonInfo InfoWithTitle:AUIUgsvGetString(@"布局") image:AUIUgsvRecorderImage(@"ic_mix_layout1") disabledImage:AUIUgsvRecorderImage(@"ic_mix_layout1_disabled")],
            @(1): [AVBaseStateButtonInfo InfoWithImage:AUIUgsvRecorderImage(@"ic_mix_layout2") disabledImage:AUIUgsvRecorderImage(@"ic_mix_layout2_disabled")],
            @(2): [AVBaseStateButtonInfo InfoWithImage:AUIUgsvRecorderImage(@"ic_mix_layout3") disabledImage:AUIUgsvRecorderImage(@"ic_mix_layout3_disabled")],
        },
    };
    
    __weak typeof(self) weakSelf = self;
    for (NSNumber *type in _showTypes) {
        AVBaseStateButton *btn = [[AVBaseStateButton alloc] initWithStateInfos:StateInfos[type]
                                                             imageTextTitlePos:AVBaseButtonTitlePosBottom];
        [btn setAction:^(AVBaseButton *_) {
            [weakSelf onBtnDidPressed:(AUIRecorderSlidBtnType)type.intValue];
        }];
        [_stackView addArrangedSubview:btn];
        _buttons[type] = btn;
    }
    
    [self updateMusicBtnUI];
    [self updateResolutionBtnUI];
    [self updateMixLayoutBtnUI];
}

- (void) updateMusicBtnUI {
    _buttons[@(AUIRecorderSlidBtnTypeMusic)].disabled = _musicDisabled;
}

- (void) updateResolutionBtnUI {
    AVBaseStateButton *btn = _buttons[@(AUIRecorderSlidBtnTypeResolution)];
    btn.customState = (int)_resolution;
    btn.disabled = _resolutionDisabled;
}

- (void) updateMixLayoutBtnUI {
    AVBaseStateButton *btn = _buttons[@(AUIRecorderSlidBtnTypeMixLayout)];
    btn.customState = (int)_mixType / 2;
    btn.disabled = _mixLayoutDisabled;
}

@end
