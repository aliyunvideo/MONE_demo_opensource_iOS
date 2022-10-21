//
//  AUIAudioEffectPanel.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/23.
//

#import "AUIAudioEffectPanel.h"
#import "AUIUgsvMacro.h"
#import "AUIEditorActionManager.h"
#import "AUIAudioEffectView.h"
#import "AUIVideoEditorUtils.h"
#import "AUIEditorAudioActionItem.h"
#import "Masonry.h"
#import "AUIAepHelper.h"

@interface AliyunAudioEffect(AUIAudioEffectParam)
+ (AliyunAudioEffect *) AudioEffectWithType:(AliyunAudioEffectType)type weight:(int)weight;
@end

@implementation AliyunAudioEffect(AUIAudioEffectParam)
+ (AliyunAudioEffect *) AudioEffectWithType:(AliyunAudioEffectType)type weight:(int)weight {
    AliyunAudioEffect *param = [AliyunAudioEffect new];
    param.type = type;
    param.weight = weight;
    return param;
}
@end

@interface AUIAudioEffectPanel()<AUIVideoPlayObserver>
@property (nonatomic, strong) AVBaseButton *setForAllBtn;
@property (nonatomic, strong) AUIAudioEffectView *effectView;
@property (nonatomic, strong) AVSliderView *sliderView;

@property (nonatomic, strong) AUIVideoEditorHelperSettingForAll *settingForAll;
@property (nonatomic, strong) AliyunAudioEffect *currentAudioEffectInUI;
@property (nonatomic, readonly) AliyunAudioEffect *currentAudioEffectInModel;
@end

@implementation AUIAudioEffectPanel

- (void)dealloc {
    [self.actionManager.currentOperator.currentPlayer removeObserver:self];
}

- (void)syncToUI {
    self.currentAudioEffectInUI = self.currentAudioEffectInModel;
    [self updateCurrentSlider];
}

// MARK: - action
- (void)doClearAction {
    AUIEditorAudioClearEffectActionItem *actionItem = [AUIEditorAudioClearEffectActionItem new];
    actionItem.forStreamIds = self.currentStreamIds;
    [self.actionManager doAction:actionItem];
}

- (void)doUpdateAction {
    AUIEditorAudioUpdateEffectActionItem *actionItem = [AUIEditorAudioUpdateEffectActionItem new];
    actionItem.forStreamIds = self.currentStreamIds;
    actionItem.audioEffect = self.currentAudioEffectInUI;
    [self.actionManager doAction:actionItem];
}

- (NSArray<NSNumber *> *)currentStreamIds {
    NSMutableArray<NSNumber *> *streamIds = @[].mutableCopy;
    NSArray<AEPVideoTrackClip *> *clips = [self currentStreams:self.settingForAll.isOn];
    for (AEPVideoTrackClip *clip in clips) {
        [streamIds addObject:@(clip.mediaId)];
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

- (AliyunAudioEffect *)currentAudioEffectInUI {
    return [AliyunAudioEffect AudioEffectWithType:self.effectView.current weight:self.sliderView.value];
}
- (void)setCurrentAudioEffectInUI:(AliyunAudioEffect *)currentAudioEffectInUI {
    _effectView.current = currentAudioEffectInUI.type;
    if (_sliderView.isChanging) {
        if ((int)_sliderView.value != currentAudioEffectInUI.weight) {
            // 反向设置
            [self doUpdateAction];
        }
    }
    else {
        [self updateCurrentSlider];
    }
}

- (AliyunAudioEffect *)currentAudioEffectInModel {
    NSArray<AEPVideoTrackClip *> *clips = [self currentStreams:NO];
    AEPAudioEffect *effect = nil;
    NSAssert(clips.count > 0, @"Must has main clip in current play time!");
    if (clips.count > 0) {
        effect = clips.firstObject.audioEffect;
    }
    if (effect) {
        return [AliyunAudioEffect AudioEffectWithType:effect.effectType weight:effect.effectParam];
    }
    return [AliyunAudioEffect AudioEffectWithType:AliyunAudioEffectDefault weight:0];
}

- (NSArray<AEPVideoTrackClip *> *)currentStreams:(BOOL)isForAll {
    AliyunEditor *editor = self.actionManager.currentOperator.currentEditor;
    if (isForAll) {
        return editor.getEditorProject.timeline.mainVideoTrack.clipList;
    }
    
    NSTimeInterval playTime = self.actionManager.currentOperator.currentPlayer.currentTime;
    return @[[AUIAepHelper aepVideo:editor playTime:playTime]];
}

// MARK: - AUIVideoPlayObserver
- (void)playProgress:(double)progress {
    [self syncToUI];
}

// MARK: - UI
+ (CGFloat)panelHeight {
    return 240 + AVSafeBottom;
}

+ (AUIAudioEffectPanel *)presentOnView:(UIView *)onView
                     withActionManager:(AUIEditorActionManager *)actionManager {
    CGRect frame = CGRectMake(0, 0, onView.av_width, self.panelHeight);
    AUIAudioEffectPanel *panel = [[AUIAudioEffectPanel alloc] initWithFrame:frame];
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
    [_sliderView removeFromSuperview];
    [_effectView removeFromSuperview];
    
    __weak typeof(self) weakSelf = self;
    // create
    _effectView = [AUIAudioEffectView new];
    _effectView.onSelectedChanged = ^(AliyunAudioEffectType type) {
        int defaultValue = (type == AliyunAudioEffectDefault ? 0 : 50);
        weakSelf.sliderView.value = defaultValue; // 默认值
        [weakSelf doUpdateAction];
        [weakSelf syncToUI];
    };
    [self.contentView addSubview:_effectView];
    [_effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).inset(20.0);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(64.0);
    }];
    
    _sliderView = [AVSliderView new];
    _sliderView.minimumValue = 0;
    _sliderView.maximumValue = 100;
    _sliderView.sensitivity = 1;
    _sliderView.onValueChanged = ^(float value) {
        [weakSelf doUpdateAction];
    };
    _sliderView.onValueChangedByGesture = ^(float value, UIGestureRecognizer * _Nonnull gesture) {
        [weakSelf doUpdateAction];
    };
    [self.contentView addSubview:_sliderView];
    [_sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_effectView.mas_bottom).inset(4.0);
        make.left.right.equalTo(self.contentView).inset(48.0);
        make.height.mas_equalTo(30.0);
    }];
    
    _settingForAll = [AUIVideoEditorHelperSettingForAll SettingForKey:@"AudioEffect_IsSettingForAll" onChanged:^(BOOL isSettingForAll) {
        if (isSettingForAll) {
            [weakSelf doUpdateAction];
        }
    }];
    [self.contentView addSubview:_settingForAll.button];
    [_settingForAll.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(_sliderView.mas_bottom).inset(10.0);
    }];

    // update
    self.titleView.text = AUIUgsvGetString(@"变声");
    self.showBackButton = YES;
    if (self.actionManager) {
        [self syncToUI];
    }
}

- (void)updateCurrentSlider {
    AliyunAudioEffect *model = self.currentAudioEffectInModel;
    if (!model || model.type == AliyunAudioEffectDefault) {
        self.sliderView.disabled = YES;
        self.sliderView.value = 0;
    }
    else {
        self.sliderView.disabled = NO;
        self.sliderView.value = model.weight;
    }
}

@end
