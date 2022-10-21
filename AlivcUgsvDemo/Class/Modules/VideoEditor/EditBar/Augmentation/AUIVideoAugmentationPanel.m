//
//  AUIVideoAugmentationPanel.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/23.
//

#import "AUIVideoAugmentationPanel.h"
#import "AUIVideoEditorUtils.h"
#import "AUIEditorActionManager.h"
#import "AUIVideoAugmentationView.h"
#import "AUIUgsvMacro.h"
#import "Masonry.h"
#import "AUIEditorVideoActionItem.h"
#import "AUIAepHelper.h"

@interface AUIVideoAugmentationPanel ()<AUIVideoPlayObserver>
@property (nonatomic, strong) AVBaseButton *resetBtn;
@property (nonatomic, strong) AUIVideoAugmentationView *augmentationView;
@property (nonatomic, strong) AVSliderView *sliderView;

@property (nonatomic, strong) AUIVideoEditorHelperSettingForAll *settingForAll;
@property (nonatomic, assign) AliyunVideoAugmentationType currentType;
@property (nonatomic, readonly) NSDictionary<NSNumber *, AUIVideoAugmentationInfo *> *currentInfosInModel;
@property (nonatomic, copy) NSDictionary<NSNumber *, AUIVideoAugmentationInfo *> *currentInfosInUI;
@end

@implementation AUIVideoAugmentationPanel

- (void)dealloc {
    [self.actionManager.currentOperator.currentPlayer removeObserver:self];
}

// MARK: - Sync
- (void)syncToUI {
    self.currentInfosInUI = self.currentInfosInModel;
    [self updateCurrentSlider];
}

- (void)doResetAction {
    AUIEditorVideoAugmentationResetActionItem *action = [AUIEditorVideoAugmentationResetActionItem new];
    action.values = self.currentValues;
    action.streamIds = self.currentStreamIds;
    [self.actionManager doAction:action];
}

- (void)doUpdateActionWithType:(AliyunVideoAugmentationType)type value:(float)value {
    AUIEditorVideoAugmentationActionItem *action = [AUIEditorVideoAugmentationActionItem new];
    action.values = @{@(type): @(value)};
    action.streamIds = self.currentStreamIds;
    [self.actionManager doAction:action];
}

- (void)doSyncAction {
    AUIEditorVideoAugmentationActionItem *action = [AUIEditorVideoAugmentationActionItem new];
    action.values = self.currentValues;
    action.streamIds = self.currentStreamIds;
    [self.actionManager doAction:action];
}

- (NSMutableDictionary<NSNumber *, NSNumber *> *)currentValues {
    NSDictionary<NSNumber *, AUIVideoAugmentationInfo *> *uiValues = self.currentInfosInUI;
    NSMutableDictionary<NSNumber *, NSNumber *> *values = @{}.mutableCopy;
    for (NSNumber *type in uiValues) {
        values[type] = @(uiValues[type].value);
    }
    return values;
}

- (id)currentStreamIds {
    NSArray<AEPVideoTrackClip *> *streams = [self currentStreams:self.settingForAll.isOn];
    NSMutableArray<NSNumber *> *streamIds = @[].mutableCopy;
    for (AEPVideoTrackClip *clip in streams) {
        [streamIds addObject:@(clip.editorClip.streamId)];
    }
    return streamIds;
}

// MARK: - Model
- (void)setActionManager:(AUIEditorActionManager *)actionManager {
    if (_actionManager == actionManager) {
        return;
    }
    [_actionManager.currentOperator.currentPlayer removeObserver:self];
    _actionManager = actionManager;
    [_actionManager.currentOperator.currentPlayer addObserver:self];
    [self syncToUI];
    self.settingForAll.actionOperator = _actionManager.currentOperator;
}

- (void)setCurrentType:(AliyunVideoAugmentationType)currentType {
    _currentType = currentType;
    [self updateCurrentSlider];
}

- (NSArray<AUIVideoAugmentationInfo *> *)currentInfosForUI {
    NSArray<NSNumber *> *types = @[ // 列表顺序
        @(AliyunVideoAugmentationTypeBrightness),
        @(AliyunVideoAugmentationTypeContrast),
        @(AliyunVideoAugmentationTypeSaturation),
        @(AliyunVideoAugmentationTypeVignette),
        @(AliyunVideoAugmentationTypeSharpness)
    ];
    NSMutableArray<AUIVideoAugmentationInfo *> *infos = @[].mutableCopy;
    for (NSNumber *type in types) {
        [infos addObject:self.currentInfosInUI[type]];
    }
    return infos;
}

static BOOL s_isSameInfos(NSDictionary<NSNumber *, AUIVideoAugmentationInfo *> *a, NSDictionary<NSNumber *, AUIVideoAugmentationInfo *> *b) {
    if (a.count != b.count) {
        return NO;
    }
    for (NSNumber *type in a) {
        AUIVideoAugmentationInfo *aInfo = a[type];
        AUIVideoAugmentationInfo *bInfo = b[type];
        if (![aInfo isEqual:bInfo]) {
            return NO;
        }
    }
    return YES;
}

- (void)setCurrentInfosInUI:(NSDictionary<NSNumber *, AUIVideoAugmentationInfo *> *)currentInfosInUI {
    if (self.sliderView.isChanging) {
        AUIVideoAugmentationInfo *originCurrent = _currentInfosInUI[@(self.currentType)];
        AUIVideoAugmentationInfo *targetCurrent = currentInfosInUI[@(self.currentType)];
        if (![originCurrent isEqual:targetCurrent]) {
            // 反向设置
            targetCurrent.value = originCurrent.value;
            [self doUpdateActionWithType:originCurrent.type value:originCurrent.value];
        }
    }
    
    if (s_isSameInfos(_currentInfosInUI, currentInfosInUI)) {
        return;
    }
    _currentInfosInUI = currentInfosInUI.copy;
    self.augmentationView.infos = self.currentInfosForUI;
    [self.augmentationView selectWithType:self.currentType];
}

- (NSDictionary<NSNumber *, AUIVideoAugmentationInfo *> *)currentInfosInModel {
    NSDictionary<NSNumber *, AUIVideoAugmentationInfo *> *result = @{
        @(AliyunVideoAugmentationTypeBrightness): [AUIVideoAugmentationInfo InfoWithType:AliyunVideoAugmentationTypeBrightness],
        @(AliyunVideoAugmentationTypeContrast): [AUIVideoAugmentationInfo InfoWithType:AliyunVideoAugmentationTypeContrast],
        @(AliyunVideoAugmentationTypeSaturation): [AUIVideoAugmentationInfo InfoWithType:AliyunVideoAugmentationTypeSaturation],
        @(AliyunVideoAugmentationTypeVignette): [AUIVideoAugmentationInfo InfoWithType:AliyunVideoAugmentationTypeVignette],
        @(AliyunVideoAugmentationTypeSharpness): [AUIVideoAugmentationInfo InfoWithType:AliyunVideoAugmentationTypeSharpness]
    };
    
    NSArray<AEPVideoTrackClip *> *streams = [self currentStreams:NO];
    if (streams.count == 0) {
        NSAssert(streams.count > 0, @"Main track for current time is not exist!!");
        return result;
    }
    AEPVideoTrackClip *stream = streams.firstObject;
    result[@(AliyunVideoAugmentationTypeBrightness)].value = stream.brightnessValue;
    result[@(AliyunVideoAugmentationTypeContrast)].value = stream.contrastValue;
    result[@(AliyunVideoAugmentationTypeSaturation)].value = stream.saturationValue;
    result[@(AliyunVideoAugmentationTypeVignette)].value = stream.vignetteValue;
    result[@(AliyunVideoAugmentationTypeSharpness)].value = stream.sharpnessValue;
    return result;
}

- (NSArray<AEPVideoTrackClip *> *)currentStreams:(BOOL)isForAll {
    AliyunEditor *editor = self.actionManager.currentOperator.currentEditor;
    if (isForAll) {
        return editor.getEditorProject.timeline.mainVideoTrack.clipList;
    }
    
    NSTimeInterval playTime = self.actionManager.currentOperator.currentPlayer.currentTime;
    return @[[AUIAepHelper aepVideo:editor playTime:playTime]];
}

#define kAugmentation_IsSettingForAll @""
- (void)setIsSettingForAllByDefault:(BOOL)isSettingForAllByDefault {
    [self.actionManager.currentOperator setAssociatedObject:@(isSettingForAllByDefault)
                                                     forKey:kAugmentation_IsSettingForAll];
}
- (BOOL)isSettingForAllByDefault {
    return ((NSNumber *)[self.actionManager.currentOperator associatedObjectForKey:kAugmentation_IsSettingForAll]).boolValue;
}

// MARK: - AUIVideoPlayObserver
- (void)playProgress:(double)progress {
    [self syncToUI];
}

// MARK: - UI
+ (CGFloat)panelHeight {
    return 240 + AVSafeBottom;
}

+ (AUIVideoAugmentationPanel *)presentOnView:(UIView *)onView withActionManager:(AUIEditorActionManager *)actionManager {
    CGRect frame = CGRectMake(0, 0, onView.av_width, self.panelHeight);
    AUIVideoAugmentationPanel *panel = [[AUIVideoAugmentationPanel alloc] initWithFrame:frame];
    panel.actionManager = actionManager;
    [panel showOnView:onView withBackgroundType:AVControllPanelBackgroundTypeNone];
    return panel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    // clear
    [_settingForAll.button removeFromSuperview];
    [_resetBtn removeFromSuperview];
    [_augmentationView removeFromSuperview];
    [_sliderView removeFromSuperview];
    
    __weak typeof(self) weakSelf = self;
    _currentType = AliyunVideoAugmentationTypeBrightness;
    
    // create
    _resetBtn = [AVBaseButton ImageTextWithTitlePos:AVBaseButtonTitlePosBottom];
    _resetBtn.image = AUIUgsvEditorImage(@"ic_panel_reset");
    _resetBtn.title = AUIUgsvGetString(@"重置");
    _resetBtn.font = AVGetRegularFont(12.0);
    _resetBtn.spacing = 12.0;
    _resetBtn.action = ^(AVBaseButton * _Nonnull btn) {
        [weakSelf doResetAction];
        [weakSelf syncToUI];
    };
    [self.contentView addSubview:_resetBtn];
    [_resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(52.0);
        make.height.mas_equalTo(54.0);
        make.left.equalTo(self.contentView).inset(6.0);
        make.top.equalTo(self.contentView).inset(21.0);
    }];

    _augmentationView = [AUIVideoAugmentationView new];
    _augmentationView.onSelectedDidChanged = ^(AUIVideoAugmentationInfo * _Nonnull info) {
        weakSelf.currentType = info.type;
    };
    [self.contentView addSubview:_augmentationView];
    [_augmentationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_resetBtn.mas_right);
        make.top.equalTo(_resetBtn);
        make.right.equalTo(self.contentView);
        make.height.mas_equalTo(64.0);
    }];
    
    _sliderView = [AVSliderView new];
    _sliderView.sensitivity = 0.005;
    _sliderView.onValueChanged = ^(float value) {
        [weakSelf onSliderValueDidChange:value];
    };
    _sliderView.onValueChangedByGesture = ^(float value, UIGestureRecognizer * _Nonnull gesture) {
        [weakSelf onSliderValueDidChange:value];
    };
    [self.contentView addSubview:_sliderView];
    [_sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_augmentationView.mas_bottom).inset(4.0);
        make.left.right.equalTo(self.contentView).inset(48.0);
        make.height.mas_equalTo(30.0);
    }];
    
    _settingForAll = [AUIVideoEditorHelperSettingForAll SettingForKey:@"Augmentation_IsSettingForAll" onChanged:^(BOOL isSettingForAll) {
        if (isSettingForAll) {
            [weakSelf doSyncAction];
        }
    }];
    [self.contentView addSubview:_settingForAll.button];
    [_settingForAll.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(_sliderView.mas_bottom).inset(10.0);
    }];
    
    // update
    self.titleView.text = AUIUgsvGetString(@"增强");
    self.showBackButton = YES;
    if (self.actionManager) {
        [self syncToUI];
    }
}

- (void)updateCurrentSlider {
    AUIVideoAugmentationInfo *info = self.currentInfosInUI[@(self.currentType)];
    NSAssert(info, @"current selected augmentation info is nil");
    if (info) {
        self.sliderView.value = info.value;
    }
}

- (void)onSliderValueDidChange:(float)value {
    [self doUpdateActionWithType:self.currentType value:value];
    self.currentInfosInUI[@(self.currentType)].value = value;
}

@end
