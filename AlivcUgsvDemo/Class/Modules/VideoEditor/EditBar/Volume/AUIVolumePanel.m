//
//  AUIVolumePanel.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/22.
//

#import "AUIVolumePanel.h"
#import "AUIFoundation.h"
#import "Masonry.h"
#import "AUIUgsvMacro.h"
#import "AUIEditorActionManager.h"
#import "AUIEditorAudioActionItem.h"
#import "AUIVideoEditorUtils.h"
#import "AUIAepHelper.h"

typedef void(^OnVolumeDidChanged)(float progress);
@interface AUIVolumeSliderView : UIView
@property (nonatomic, assign) BOOL disabled;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) float progress;
@property (nonatomic, copy) OnVolumeDidChanged onVolumeDidChanged;
@property (nonatomic, readonly) BOOL isChanging;
@end

@interface AUIVolumePanel()<AUIVideoPlayObserver>
@property (nonatomic, strong) AUIVolumeSliderView *originVolumeView;
@property (nonatomic, strong) AUIVolumeSliderView *musicVolumeView;

@property (nonatomic, strong) AUIVideoEditorHelperSettingForAll *settingForAll;
@property (nonatomic, assign) float originVolumeInUI;
@property (nonatomic, assign) float musicVolumeInUI;
@property (nonatomic, assign) float originVolumeInModel;
@property (nonatomic, assign) float musicVolumeInModel;
@end

@implementation AUIVolumePanel

- (void)dealloc {
    [self.actionManager.currentOperator.currentPlayer removeObserver:self];
}

// MARK: - Sync
- (void)syncToModel {
    self.originVolumeInModel = self.originVolumeInUI;
    self.musicVolumeInModel = self.musicVolumeInUI;
}

- (void)syncToUI {
    self.originVolumeInUI = self.originVolumeInModel;
    self.musicVolumeInUI = self.musicVolumeInModel;
    self.musicVolumeView.disabled = ([self currentMusicStreamsForAll:self.settingForAll.isOn].count == 0);
}

- (void)doActionWithVolume:(float)volume streamIds:(NSArray<NSNumber *> *)streamIds {
    if (streamIds.count == 0) {
        return;
    }
    
    AUIEditorAudioUpdateVolumeActionItem *action = [AUIEditorAudioUpdateVolumeActionItem new];
    action.volume = volume;
    action.forStreamIds = streamIds;
    [self.actionManager doAction:action];
}

// MARK: - AUIVideoPlayObserver
- (void)playProgress:(double)progress {
    [self syncToUI];
}

// MARK: - model
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

- (void)setOriginVolumeInModel:(float)originVolumeInModel {
    NSArray<AEPVideoTrackClip *> *clips = [self currentOriginStreamsForAll:self.settingForAll.isOn];
    NSMutableArray<NSNumber *> *ids = @[].mutableCopy;
    for (AEPVideoTrackClip *clip in clips) {
        [ids addObject:@(clip.editorClip.streamId)];
    }
    [self doActionWithVolume:originVolumeInModel streamIds:ids];
}
- (float)originVolumeInModel {
    NSArray<AEPVideoTrackClip *> *clips = [self currentOriginStreamsForAll:NO];
    if (clips.count == 0) {
        return 0.0;
    }
    return clips.firstObject.mixWeight / 100.0;
}

- (void)setMusicVolumeInModel:(float)musicVolumeInModel {
    NSArray<AEPAudioTrackClip *> *clips = [self currentMusicStreamsForAll:self.settingForAll.isOn];
    NSMutableArray<NSNumber *> *ids = @[].mutableCopy;
    for (AEPAudioTrackClip *clip in clips) {
        [ids addObject:@(clip.editorClip.effectVid)];
    }
    [self doActionWithVolume:musicVolumeInModel streamIds:ids];
}
- (float)musicVolumeInModel {
    NSArray<AEPAudioTrackClip *> *clips = [self currentMusicStreamsForAll:NO];
    if (clips.count == 0) {
        return 0.0;
    }
    return clips.firstObject.mixWeight / 100.0;
}

- (void)setOriginVolumeInUI:(float)originVolumeInUI {
    if (self.originVolumeInUI == originVolumeInUI) {
        return;
    }
    
    if (_originVolumeView.isChanging) {
        // 反向设置
        self.originVolumeInModel = self.originVolumeInUI;
        return;
    }
    
    _originVolumeView.progress = originVolumeInUI;
}
- (float)originVolumeInUI {
    return _originVolumeView.progress;
}

- (void)setMusicVolumeInUI:(float)musicVolumeInUI {
    if (self.musicVolumeInUI == musicVolumeInUI) {
        return;
    }
    
    if (_musicVolumeView.isChanging) {
        // 反向设置
        self.musicVolumeInModel = self.musicVolumeInUI;
        return;
    }
    
    _musicVolumeView.progress = musicVolumeInUI;
}
- (float)musicVolumeInUI {
    return _musicVolumeView.progress;
}

- (NSTimeInterval)currentPlayTime {
    return self.actionManager.currentOperator.currentPlayer.currentTime;
}

- (AEPTimeline *)currentTimeline {
    return self.actionManager.currentOperator.currentEditor.getEditorProject.timeline;
}

- (NSArray<AEPVideoTrackClip *> *)currentOriginStreamsForAll:(BOOL)isForAll {
    AEPTimeline *timeline = self.currentTimeline;
    if (isForAll) {
        return timeline.mainVideoTrack.clipList;
    }
    
    NSTimeInterval playTime = self.currentPlayTime;
    AliyunEditor *editor = self.actionManager.currentOperator.currentEditor;
    return @[[AUIAepHelper aepVideo:editor playTime:playTime]];
}

- (NSArray<AEPAudioTrackClip *> *)currentMusicStreamsForAll:(BOOL)isForAll {
    NSMutableArray<AEPAudioTrackClip *> *result = @[].mutableCopy;
    NSTimeInterval playTime = self.currentPlayTime;
    
    AEPTimeline *timeline = self.currentTimeline;
    for (AEPAudioTrack *track in timeline.audioTracks) {
        for (AEPAudioTrackClip *clip in track.clipList) {
            if (isForAll ||
                (clip.timelineIn <= playTime && playTime <= clip.timelineOut)) {
                [result addObject:clip];
            }
        }
    }
    return result;
}

// MARK: - UI
+ (CGFloat)panelHeight
{
    return 240 + AVSafeBottom;
}

+ (AUIVolumePanel *)presentOnView:(UIView *)onView
                withActionManager:(AUIEditorActionManager *)actionManager
                           bgType:(AVControllPanelBackgroundType)bgType {
    CGRect frame = CGRectMake(0, 0, onView.av_width, self.panelHeight);
    AUIVolumePanel *panel = [[AUIVolumePanel alloc] initWithFrame:frame];
    panel.actionManager = actionManager;
    [panel showOnView:onView withBackgroundType:bgType];
    return panel;
}

+ (AUIVolumePanel *)presentOnView:(UIView *)onView
                withActionManager:(AUIEditorActionManager *)actionManager {
    return [self presentOnView:onView withActionManager:actionManager bgType:AVControllPanelBackgroundTypeNone];
}

+ (AUIVolumePanel *)presentWithActionManager:(AUIEditorActionManager *)actionManager {
    return [self presentOnView:actionManager.currentOperator.currentVC.view
             withActionManager:actionManager
                        bgType:AVControllPanelBackgroundTypeClickToClose];
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
    [_originVolumeView removeFromSuperview];
    [_musicVolumeView removeFromSuperview];
    [_settingForAll.button removeFromSuperview];
    
    __weak typeof(self) weakSelf = self;
    // create
    _originVolumeView = [AUIVolumeSliderView new];
    _originVolumeView.title = AUIUgsvGetString(@"原声");
    _originVolumeView.onVolumeDidChanged = ^(float progress) {
        weakSelf.originVolumeInModel = progress;
    };
    [self.contentView addSubview:_originVolumeView];
    [_originVolumeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView).inset(20.0);
        make.top.equalTo(self.contentView).inset(40.0);
    }];
    
    _musicVolumeView = [AUIVolumeSliderView new];
    _musicVolumeView.title = AUIUgsvGetString(@"配乐");
    _musicVolumeView.onVolumeDidChanged = ^(float progress) {
        weakSelf.musicVolumeInModel = progress;
    };
    [self.contentView addSubview:_musicVolumeView];
    [_musicVolumeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView).inset(20.0);
        make.top.equalTo(_originVolumeView.mas_bottom).inset(24.0);
    }];
    
    _settingForAll = [AUIVideoEditorHelperSettingForAll SettingForKey:@"VolumeKey_IsSettingForAll" onChanged:^(BOOL isSettingForAll) {
        if (isSettingForAll) {
            [weakSelf syncToModel];
        }
    }];
    [self.contentView addSubview:_settingForAll.button];
    [_settingForAll.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_musicVolumeView.mas_bottom).inset(38.0);
        make.centerX.equalTo(self.contentView);
    }];
    
    // update
    self.titleView.text = AUIUgsvGetString(@"音量");
    self.showBackButton = YES;
}

@end

// MARK: - AUIVolumeSliderView
@interface AUIVolumeSliderView ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) AVSliderView *sliderView;
@end

@implementation AUIVolumeSliderView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    // clear
    [_titleLabel removeFromSuperview];
    [_progressLabel removeFromSuperview];
    [_sliderView removeFromSuperview];
    
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(18.0);
    }];
    
    // create
    _titleLabel = [UILabel new];
    _titleLabel.font = AVGetRegularFont(12.0);
    [self addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.equalTo(self);
    }];
    
    _progressLabel = [UILabel new];
    _progressLabel.font = AVGetRegularFont(12.0);
    [self addSubview:_progressLabel];
    [_progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.centerY.equalTo(self);
    }];
    
    __weak typeof(self) weakSelf = self;
    _sliderView = [[AVSliderView alloc] initWithFrame:CGRectZero];
    _sliderView.sensitivity = 0.05;
    _sliderView.onValueChanged = ^(float value) {
        [weakSelf setProgress:value needNotify:YES];
    };
    _sliderView.onValueChangedByGesture = ^(float value, UIGestureRecognizer * _Nonnull gesture) {
        [weakSelf setProgress:value needNotify:YES];
    };
    [self addSubview:_sliderView];
    [_sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.left.right.equalTo(self).inset(56.0);
    }];

    // update
    [self updateTitle];
    [self updateProgress];
    [self updateStateUI];
}

- (void)updateStateUI {
    _sliderView.disabled = _disabled;
    if (_disabled) {
        _titleLabel.textColor = AUIFoundationColor(@"text_ultraweak");
        _progressLabel.textColor = AUIFoundationColor(@"text_ultraweak");
    }
    else {
        _titleLabel.textColor = AUIFoundationColor(@"text_strong");
        _progressLabel.textColor = AUIFoundationColor(@"text_strong");
    }
}

- (void)updateTitle {
    _titleLabel.text = self.title;
}

- (void)updateProgress {
    _progressLabel.text = [NSString stringWithFormat:@"%d%%", (int)(self.progress * 100)];
    _sliderView.value = self.progress;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [self updateTitle];
}

- (void)setProgress:(float)progress needNotify:(BOOL)needNotify {
    if (_progress == progress) {
        return;
    }
    
    _progress = progress;
    [self updateProgress];
    if (needNotify && self.onVolumeDidChanged) {
        self.onVolumeDidChanged(_progress);
    }
}

- (void)setProgress:(float)progress {
    [self setProgress:progress needNotify:NO];
}

- (void)setDisabled:(BOOL)disabled {
    if (_disabled == disabled) {
        return;
    }
    _disabled = disabled;
    [self updateStateUI];
}

- (BOOL)isChanging {
    return _sliderView.isChanging;
}

@end
