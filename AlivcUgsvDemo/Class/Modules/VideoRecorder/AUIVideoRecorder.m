//
//  AUIVideoRecorder.m
//  AlivcUGC_Demo
//
//  Created by Bingo on 2022/5/23.
//

#import "AUIVideoRecorder.h"
#import "AUIUgsvMacro.h"
#import "AUIRecorderSliderButtonsView.h"
#import "AUIRecorderHeaderButtonsView.h"
#import "AUIRecorderRateSelectView.h"
#import "AUIRecorderBottomButtonsView.h"
#import "AUIRecorderControlView.h"
#import "AUIRecorderCountDownView.h"
#import "AVToastView.h"
#import "AUIRecorderWrapper.h"
#import "Masonry.h"
#import "AVBaseButton.h"
#import "AUIRecorderFaceStickerPanel.h"
#import "AUIRecorderFilterPanel.h"
#import "AUIMusicPicker.h"
#import "AUIRecorderMixLayoutPanel.h"
#import "AVProgressHUD.h"
#import "AlivcUgsvSDKHeader.h"
#import "AUIAssetPlay.h"

typedef NS_ENUM(NSUInteger, __RecorderState) {
    __RecorderStateIdle,
    __RecorderStateCountDown,
    __RecorderStateRecording,
    __RecorderStateStop,
};

@interface AUIVideoRecorder()<
AUIRecorderSliderButtonsViewDelegate,
AUIRecorderHeaderButtonsViewDelegate,
AUIRecorderRateSelectViewDelegate,
AUIRecorderBottomButtonsViewDelegate,
AUIRecorderControlViewDelegate,
AUIRecorderWrapperDelegate,
AUIRecorderCameraWrapperDelegate>
// state
@property (nonatomic, strong) AUIRecorderConfig *recorderConfig;
@property (nonatomic, strong) AUIRecorderWrapper *recorder;
@property (nonatomic, assign) __RecorderState recorderState;

// UI
@property (nonatomic, strong) AVBaseButton *backBtn;
@property (nonatomic, strong) AUIRecorderSliderButtonsView *sliderView;
@property (nonatomic, strong) AUIRecorderHeaderButtonsView *headerButtons;
@property (nonatomic, strong) AUIRecorderRateSelectView *rateView;
@property (nonatomic, strong) AUIRecorderBottomButtonsView *bottomButtons;
@property (nonatomic, strong) AUIRecorderControlView *controlView;

// panel
@property (nonatomic, strong) AUIRecorderFaceStickerPanel *faceStickerPanel;
@property (nonatomic, strong) AUIRecorderFilterPanel *filterPanel;
@property (nonatomic, strong) AUIRecorderFilterPanel *animationEffectsPanel;
@property (nonatomic, strong) AUIMusicSelectedModel *selectedMusic;
@end

@implementation AUIVideoRecorder

- (void) loadView {
    self.view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.view.backgroundColor = AUIFoundationColor(@"bg_medium");
}

- (instancetype) initWithConfig:(AUIRecorderConfig *)config onCompletion:(OnRecordCompletion)completion {
    self = [super init];
    if (self) {
        if (!config) {
            config = [AUIRecorderConfig new];
        }
        _recorderConfig = config;
        _onCompletion = completion;
    }
    return self;
}

- (instancetype) initWithCompletion:(OnRecordCompletion)completion {
    return [self initWithConfig:[AUIRecorderConfig new] onCompletion:completion];
}

- (void) viewDidLoad {
    [super viewDidLoad];

    [self setupRecorder];
    [self setupHeaderButtons];
    [self setupSliderView];
    [self setupControlView];
    [self setupRateView];
    [self setupBottomButtons];
    [self.view bringSubviewToFront:_controlView];
    
#ifdef ENABLE_BEAUTY
    [_recorder selectedDefaultBeautyPanel];
#endif // ENABLE_BEAUTY

    [self syncRecorderState];
    [self syncPartCountAndDuration];
}

- (void) setRecorderState:(__RecorderState)recorderState {
    BOOL fromCountDown = (_recorderState == __RecorderStateCountDown);
    _recorderState = recorderState;
    [self updateUIForRecordState:fromCountDown];
}

// MARK: - Actions
- (void) doFinish {
    AVProgressHUD *hud = [AVProgressHUD ShowHUDAddedTo:self.view animated:YES];
    void(^finish)(NSError *) = ^(NSError *error){
        if (error) {
            hud.iconType = AVProgressHUDIconTypeWarn;
            hud.labelText = AUIUgsvGetString(@"录制出错");
            [hud hideAnimated:YES afterDelay:2.0];
            return;
        }
        hud.iconType = AVProgressHUDIconTypeSuccess;
        hud.labelText = AUIUgsvGetString(@"已完成录制");
        [hud hideAnimated:YES afterDelay:2.0];
    };
    
    __weak typeof(self) weakSelf = self;
    if (_recorderConfig.mergeOnFinish) {
        [_recorder finishRecord:^(NSString * _Nonnull taskPath, NSString * _Nonnull outputPath, NSError * _Nonnull error) {
            finish(error);
            if (weakSelf.onCompletion) {
                weakSelf.onCompletion(weakSelf, taskPath, outputPath, error);
            }
        }];
    }
    else {
        [_recorder finishRecordSkipMerge:^(NSString * _Nonnull taskPath, NSError * _Nonnull error) {
            finish(error);
            if (weakSelf.onCompletion) {
                weakSelf.onCompletion(weakSelf, taskPath, nil, error);
            }
        }];
    }
}

// MARK: - Recorder
- (void) setupRecorder {
    if (!_recorderConfig) {
        _recorderConfig = [AUIRecorderConfig new];
    }
    _recorder = [[AUIRecorderWrapper alloc] initWithConfig:_recorderConfig containerView:self.view];
    _recorder.delegate = self;
    _recorder.camera.delegate = self;
}

// MARK: - AUIRecorderWrapperDelegate
- (void) onAUIRecorderWrapper:(AUIRecorderWrapper *)recorderWrapper stateDidChange:(AliyunRecorderState)state {
    [self syncRecorderState];
    if (state == AliyunRecorderState_Stop) {
        [self syncPartCountAndDuration];
    }
}

- (void) onAUIRecorderWrapper:(AUIRecorderWrapper *)recorderWrapper progressWithDuration:(NSTimeInterval)duration {
    [self syncDuration:duration];
}

- (void) onAUIRecorderWrapperWantFinish:(AUIRecorderWrapper *)recorderWrapper {
    [self doFinish];
}

- (void) onAUIRecorderWrapperDidCancel:(AUIRecorderWrapper *)recorderWrapper {
    [self syncPartCountAndDuration];
}

- (void) syncRecorderState {
    switch (_recorder.recorderState) {
        case AliyunRecorderState_Idle:
            self.recorderState = __RecorderStateIdle;
            break;
        case AliyunRecorderState_LoadingForRecord:
        case AliyunRecorderState_Recording:
            self.recorderState = __RecorderStateRecording;
            break;
        case AliyunRecorderState_Stopping:
        case AliyunRecorderState_Stop:
            self.recorderState = __RecorderStateStop;
            break;
        default:
            NSLog(@"RecorderState is invalid!");
            break;
    }
}

- (void) syncPartCountAndDuration {
    self.controlView.maxDuration = _recorderConfig.maxDuration;
    self.bottomButtons.minDuration = _recorderConfig.minDuration;
    
    self.controlView.partDurations = _recorder.partDurations;
    self.controlView.currentPartDuration = 0;
    self.bottomButtons.partCount = _recorder.partDurations.count;
    self.bottomButtons.duration = _recorder.duration;
}

- (void) syncDuration:(NSTimeInterval)duration {
    self.headerButtons.countDownDisabled = (duration >= _recorderConfig.maxDuration);
    self.controlView.currentPartDuration = duration - _recorder.duration;
    self.bottomButtons.duration = duration;
}

// MARK: - AUIRecorderCameraWrapperDelegate
- (void) onAUIRecorderCameraWrapper:(AUIRecorderCameraWrapper *)camera torchEnabled:(BOOL)torchEnabled {
    self.headerButtons.torchDisabled = !torchEnabled;
}

// MARK: - AUIRecorderSliderButtonsViewDelegate
- (void) onAUIRecorderSliderButtonsView:(AUIRecorderSliderButtonsView *)slider btnDidPressed:(AUIRecorderSlidBtnType)btnType {
    switch (btnType) {
        case AUIRecorderSlidBtnTypeMusic:
            [self onMusicDidPressed];
            break;
        case AUIRecorderSlidBtnTypeResolution:
            [self onResolutionDidPressed];
            break;
        case AUIRecorderSlidBtnTypeTakePhoto:
            [_recorder.camera takePhoto];
            break;
        case AUIRecorderSlidBtnTypeFilter:
            [self openFilterPanel];
            break;
        case AUIRecorderSlidBtnTypeSpecialEffects:
            [self openAnimationEffectsPanel];
            break;
        case AUIRecorderSlidBtnTypeMixLayout:
            [self openMixLayoutPanel];
            break;
        default:
            break;
    }
}

- (void) onMusicDidPressed {
    if (_sliderView.musicDisabled) {
        [AVToastView show:AUIUgsvGetString(@"开始拍摄后剪音乐不可使用")
                     view:self.view
                 position:AVToastViewPositionTop];
        return;
    }
    
    [self openMusicPanel];
}

- (void) onResolutionDidPressed {
    if (_sliderView.resolutionDisabled) {
        [AVToastView show:AUIUgsvGetString(@"开始拍摄后切画稿不可使用")
                     view:self.view
                 position:AVToastViewPositionTop];
        return;
    }
    
    AUIRecorderResolutionRatio next = (_sliderView.resolution + 1)%AUIRecorderResolutionRatioMax;
    if ([_recorder changeResolutionRatio:next]) {
        [self updateResolutionUI];
    }
}

// MARK: - AUIRecorderRateSelectViewDelegate
- (void) onAUIRecorderRateSelectView:(AUIRecorderRateSelectView *)view rate:(CGFloat)rate {
    _recorder.recorder.rate = rate;
}

// MARK: - AUIRecorderControlViewDelegate
- (void) onAUIRecorderControlViewWantStart:(AUIRecorderControlView *)recordCtr {
    [_recorder startRecord];
}

- (void) onAUIRecorderControlViewWantStop:(AUIRecorderControlView *)recordCtr {
    [_recorder stopRecord];
}

// MARK: - AUIRecorderBottomButtonsViewDelegate
- (void) onAUIRecorderBottomButtonsView:(AUIRecorderBottomButtonsView *)bottom btnDidPressed:(AUIRecorderBottomBtnType)btnType {
    switch (btnType) {
        case AUIRecorderBottomBtnTypeBeauty:
#ifdef ENABLE_BEAUTY
            [_recorder showBeautyPanel];
#endif // ENABLE_BEAUTY
            break;
        case AUIRecorderBottomBtnTypeProps:
            [self openPropsPanel];
            break;
    }
}

- (void) onAUIRecorderBottomButtonsViewWantDelete:(AUIRecorderBottomButtonsView *)bottom {
    [_recorder deleteLastPart];
    [self syncPartCountAndDuration];
}

- (void) onAUIRecorderBottomButtonsViewWantFinish:(AUIRecorderBottomButtonsView *)bottom {
    [self doFinish];
}

// MARK: - AUIRecorderHeaderButtonsViewDelegate
- (void) onAUIRecorderHeaderButtonsView:(AUIRecorderHeaderButtonsView *)header btnDidPressed:(AUIRecorderHeaderBtnType)btnType {
    switch (btnType) {
        case AUIRecorderHeaderBtnTypeCountDown:
            [self onCountDownloadDidPressed];
            break;
        case AUIRecorderHeaderBtnTypeCameraTorch:
            [self onCameraTorchDidPressed];
            break;
        case AUIRecorderHeaderBtnTypeCameraPosition:
            [self onCameraPositionDidPressed];
            break;
    }
}

- (void) onCountDownloadDidPressed {
    __weak typeof(self) weakSelf = self;
    self.recorderState = __RecorderStateCountDown;
    [AUIRecorderCountDownView ShowInView:self.view complete:^(BOOL isCanceled) {
        if (isCanceled) {
            [weakSelf syncRecorderState];
        } else {
            [weakSelf.recorder startRecord];
        }
    }];
}

- (void) onCameraTorchDidPressed {
    if (_headerButtons.torchDisabled) {
        [AVToastView show:AUIUgsvGetString(@"当前摄像头不支持闪光灯")
                     view:self.view
                 position:AVToastViewPositionTop];
        return;
    }
    _recorder.camera.torchOpened = !_recorder.camera.torchOpened;
    _headerButtons.torchOpened = _recorder.camera.torchOpened;
}

- (void) onCameraPositionDidPressed {
    [_recorder.camera switchCameraPosition];
}

// MARK: - UI
const static CGFloat HeaderHeight = 44.0;
- (void) setupSliderView {
    // clear
    [_sliderView removeFromSuperview];

    // create
    _sliderView = [[AUIRecorderSliderButtonsView alloc] initWithMix:_recorderConfig.isMixRecord withDelegate:self];
    [self.view addSubview:_sliderView];
    
    [_sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).inset(20.0);
        make.top.equalTo(self.view).inset(20.0 + HeaderHeight + AVSafeTop);
    }];
    [self updateResolutionUI];
    [self updateMixLayoutUI];
}

- (void) setupHeaderButtons {
    // clear
    [_headerButtons removeFromSuperview];
    [_backBtn removeFromSuperview];

    // create
    _backBtn = [AVBaseButton ImageButton];
    _backBtn.image = AUIFoundationImage(@"ic_back");
    __weak typeof(self) weakSelf = self;
    [_backBtn setAction:^(AVBaseButton *_) {
        if (weakSelf.navigationController) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        else {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    [self.view addSubview:_backBtn];
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).inset(20.0);
        make.centerY.equalTo(self.view.mas_top).offset(HeaderHeight * 0.5 + AVSafeTop);
    }];
    
    _headerButtons = [[AUIRecorderHeaderButtonsView alloc] initWithDelegate:self];
    [self.view addSubview:_headerButtons];
    
    [_headerButtons mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).inset(20);
        make.centerY.equalTo(_backBtn);
    }];
    
    _headerButtons.torchDisabled = !_recorder.camera.torchEnabled;
}

- (void) setupRateView {
    // clear
    [_rateView removeFromSuperview];
    
    // create
    _rateView = [[AUIRecorderRateSelectView alloc] initWithDelegate:self];
    [self.view addSubview:_rateView];
    [_rateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).inset(40);
        make.bottom.equalTo(_controlView.mas_top).inset(10);
    }];
    
    _rateView.rate = _recorder.recorder.rate;
}

- (void) setupControlView {
    // clear
    [_controlView removeFromSuperview];
    
    // create
    _controlView = [[AUIRecorderControlView alloc] initWithDelegate:self];
    [self.view addSubview:_controlView];
    
    [_controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).inset(AVSafeBottom);
    }];
    
    _controlView.maxDuration = _recorderConfig.maxDuration;
}

- (void) setupBottomButtons {
    // clear
    [_bottomButtons removeFromSuperview];
    
    // create
    _bottomButtons = [[AUIRecorderBottomButtonsView alloc] initWithDelegate:self];
    [self.view addSubview:_bottomButtons];
    
    [_bottomButtons mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.centerY.equalTo(_controlView.controlView);
    }];
    
    _bottomButtons.minDuration = _recorderConfig.minDuration;
}

- (void) updateUIForRecordState:(BOOL)fromCountDown {
    BOOL isRecording = (_recorderState == __RecorderStateRecording);
    if (fromCountDown) {
        [UIView setAnimationsEnabled:NO];
    }
    self.headerButtons.isRecording = isRecording;
    self.controlView.isRecording = isRecording;
    if (fromCountDown) {
        [UIView setAnimationsEnabled:YES];
    }
    
    BOOL isWaiting = (_recorderState == __RecorderStateIdle || _recorderState == __RecorderStateStop);
    CGFloat waitingAlpha = isWaiting ? 1.0 : 0.0;

    BOOL isIdle = (_recorderState == __RecorderStateIdle);
    self.sliderView.musicDisabled = !isIdle;
    self.sliderView.resolutionDisabled = !isIdle;
    self.sliderView.mixLayoutDisabled = !isIdle;
    
    BOOL isCountDown = (_recorderState == __RecorderStateCountDown);
    CGFloat countDownAlpha = isCountDown ? 0.0 : 1.0;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.backBtn.alpha = waitingAlpha;
        self.sliderView.alpha = waitingAlpha;
        self.rateView.alpha = waitingAlpha;
        self.bottomButtons.alpha = waitingAlpha;
        
        self.headerButtons.alpha = countDownAlpha;
        self.controlView.alpha = countDownAlpha;
    }];
}

- (void) updateResolutionUI {
    _sliderView.resolution = _recorderConfig.resolutionRatio;
}

- (void) updateMixLayoutUI {
    _sliderView.mixType = _recorderConfig.mixType;
}

// MARK: - Panel
- (void) openPropsPanel {
    if (_faceStickerPanel) {
        [_faceStickerPanel showOnView:self.view];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    _faceStickerPanel = [AUIRecorderFaceStickerPanel present:self.view onSelectedChange:^(AUIStickerModel *model) {
        if (model.isEmpty) {
            [weakSelf.recorder.camera.cameraController deleteFaceSticker];
        }
        else {
            [weakSelf.recorder.camera.cameraController applyFaceSticker:model.resourcePath];
        }
    }];
}

- (void) openFilterPanel {
    if (_filterPanel) {
        [_filterPanel showOnView:self.view];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    _filterPanel = [AUIRecorderFilterPanel present:self.view onSelectedChanged:^(AUIFilterModel *model) {
        if (model.isEmpty) {
            [weakSelf.recorder.camera.cameraController deleteFilter];
        }
        else {
            AliyunEffectFilter *filter = [[AliyunEffectFilter alloc] initWithFile:model.resourcePath];
            [weakSelf.recorder.camera.cameraController applyFilter:filter];
        }
    } forType:AUIRecorderFilterPanelTypeFilter];
}

- (void) openAnimationEffectsPanel {
    if (_animationEffectsPanel) {
        [_animationEffectsPanel showOnView:self.view];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    _animationEffectsPanel = [AUIRecorderFilterPanel present:self.view onSelectedChanged:^(AUIFilterModel *model) {
        if (model.isEmpty) {
            [weakSelf.recorder.camera.cameraController deleteAnimationFilter];
        }
        else {
            AliyunEffectFilter *filter = [[AliyunEffectFilter alloc] initWithFile:model.resourcePath];
            // 暂不考虑参数设置
            [weakSelf.recorder.camera.cameraController applyAnimationFilter:filter];
        }
    } forType:AUIRecorderFilterPanelTypeAnimationEffects];
}

- (void) openMusicPanel {
    AUIMusicPicker *musicPanel = [AUIMusicPicker present:self.view
                                           selectedModel:_selectedMusic
                                           limitDuration:_recorderConfig.maxDuration
                                            showCropView:YES
                                        onSelectedChange:nil onShowChanged:nil];
    __weak AUIMusicPicker *weakMusicSelf = musicPanel;
    __weak typeof(self) weakSelf = self;
    musicPanel.onShowChanged = ^(AVBaseControllPanel *sender) {
        if (sender.isShowing) {
            return;
        }
        
        AUIVideoRecorder *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        AUIMusicSelectedModel *model = weakMusicSelf.currentSelected;
        weakSelf.selectedMusic = model;
        if (model) {
            [strongSelf.recorder applyBGMWithPath:model.localPath beginTime:model.beginTime duration:model.duration];
        }
        else {
            [strongSelf.recorder removeBGM];
        }
    };
}

- (void) openMixLayoutPanel {
    if (self.sliderView.mixLayoutDisabled) {
        [AVToastView show:AUIUgsvGetString(@"开始拍摄后不可调整布局")
                     view:self.view
                 position:AVToastViewPositionTop];
        return;
    }
    AUIRecorderMixLayoutPanel *panel = [[AUIRecorderMixLayoutPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.av_width, 0) mixType:_recorderConfig.mixType];
    __weak typeof(self) weakSelf = self;
    panel.onMixTypeChanged = ^(AUIRecorderMixType mixType) {
        [weakSelf.recorder changeMixLayout:mixType];
        [weakSelf updateMixLayoutUI];
    };
    [panel showOnView:self.view];
}

// MARK: - ViewController
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _recorder.enabledPreview = YES;
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _recorder.enabledPreview = NO;
}

// MARK: - 屏幕旋转
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}
@end
