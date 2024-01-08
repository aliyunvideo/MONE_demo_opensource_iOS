//
//  AUILiveCameraPublishView.m
//  AlivcLiveCaptureDev
//
//  Created by TripleL on 17/7/10.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import "AUILiveCameraPublishView.h"
#import "AUILiveDebugChartView.h"
#import "AUILiveDebugTextView.h"
#import "AUILiveGuidePageView.h"
#import "AUILiveMoreSettingView.h"
#import "AlivcLiveSettingManager.h"
#import "AUILiveBgMusicSettingView.h"
#import "AUILiveAnswerGameView.h"
#import "AlivcLivePushViewsProtocol.h"
#import "AUILiveSegmentPanel.h"

#define topHeight (44 + AVSafeTop)
#define viewWidth AlivcSizeWidth(80)
#define viewHeight viewWidth/4*3
#define topViewButtonSize CGSizeMake(AlivcSizeWidth(85), AlivcSizeWidth(50))
#define kTopViewButtonTag 10

static const int maxDynamicWatermarkCount = 3;

@interface AUILiveCameraPublishView () <UIGestureRecognizerDelegate>{
    NSMutableArray * dynamicWatermarkArr;
}

@property (nonatomic, weak) id<AUILiveCameraPublishViewDelegate> delegate;

@property (nonatomic, strong) AUILiveGuidePageView *guideView;

@property (nonatomic, strong) UIScrollView *topView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIView *audioEffectsItem;
@property (nonatomic, strong) UIView *snapshotItem;
@property (nonatomic, strong) UIView *switchItem;
@property (nonatomic, strong) UIView *flashItem;
@property (nonatomic, strong) UIView *musicItem;
@property (nonatomic, strong) UIButton *muteButton;
@property (nonatomic, strong) UIButton *answerGameButton;
@property (nonatomic, strong) UIView *beautySettingItem;

@property (nonatomic, strong) UIScrollView *bottomView;
@property (nonatomic, strong) UIButton *previewButton;
@property (nonatomic, strong) UIButton *pushButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *restartButton;
@property (nonatomic, strong) UIButton *moreSettingButton;
@property (nonatomic, strong) UIButton *dataMonitorButton;
@property (nonatomic, strong) UIButton *waterMarkButton;
@property (nonatomic, strong) UIButton *removeWaterMarkButton;

@property (nonatomic, strong) UISwitch *previewMirrorSwitch;
@property (nonatomic, strong) UISwitch *pushMirrorSwitch;

@property (nonatomic, strong) AUILiveMoreSettingView *moreSettingView;
@property (nonatomic, strong) AUILiveBgMusicSettingView *musicSettingView;
@property (nonatomic, strong) AUILiveAnswerGameView *answerGameView;

@property (nonatomic, strong) AUILiveSegmentPanel *audioEffectsPanel;

@property (nonatomic, strong) AUILiveDebugChartView *debugChartView;
@property (nonatomic, strong) AUILiveDebugTextView *debugTextView;

@property (nonatomic, assign) BOOL isMusicSettingShow;
@property (nonatomic, assign) BOOL isAnswerGameViewShow;
@property (nonatomic, assign) BOOL isKeyboardEdit;
@property (nonatomic, assign) BOOL isHiddenBtns;
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, strong) UILabel *infoLabel;

@property (nonatomic, strong) AlivcLivePushConfig *config;

@end

@implementation AUILiveCameraPublishView


- (instancetype)initWithFrame:(CGRect)frame config:(AlivcLivePushConfig *)config {
    
    self = [super initWithFrame:frame];
    if (self) {
        _config = config;
        [self setupSubviews];
        [self addNotifications];
        dynamicWatermarkArr = [[NSMutableArray alloc]init];
    }
    return self;
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)setPushViewsDelegate:(id)delegate {
    
    self.delegate = delegate;
    self.musicSettingView.delegate = delegate;
    // [self.musicSettingView setMusicDelegate:delegate];
    [self.answerGameView setAnswerDelegate:delegate];

}

#pragma mark - UI

- (void)setupSubviews {
    
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:AlivcUserDefaultsIndentifierFirst]) {
//        [self setupGuideView];
//    }
    
    [self setupTopViews];
    
    [self setupBottomViews];
    
    [self setupInfoLabel];
    
//    [self setupDebugViews];
    
    [self addGesture];
    
    if (self.config.audioOnly) {
        [self hiddenVideoViews];
    }
    
    self.currentIndex = 1;
}


- (void)setupGuideView {
    
    self.guideView = [[AUILiveGuidePageView alloc] initWithFrame:CGRectMake(20, 0, self.bounds.size.width - 40, self.bounds.size.height/6)];
    self.guideView.center = self.center;
    [self addSubview:self.guideView];
}


- (void)setupTopViews {
    
    self.topView = [[UIScrollView alloc] init];
    CGFloat retractX = 20;

    if (_config.orientation == AlivcLivePushOrientationLandscapeLeft || _config.orientation == AlivcLivePushOrientationLandscapeRight ) {
        self.topView.frame = CGRectMake(self.av_width - topViewButtonSize.width, 50, topViewButtonSize.width, self.av_height-100);
    }else{
        self.topView.frame = CGRectMake(self.av_width - topViewButtonSize.width, self.av_height - 600, topViewButtonSize.width, 420);
    }
    self.topView.backgroundColor = [UIColor clearColor];
    [self addSubview: self.topView];
    
    self.backButton = [self setupButtonWithFrame:CGRectMake(retractX, (topHeight - AVSafeTop - 26) / 2.0 + AVSafeTop, 26, 26)
                                     normalImage:AUIFoundationImage(@"ic_back")
                                     selectImage:nil
                                          action:@selector(backButtonAction:)];
    [self addSubview: self.backButton];
    
    self.audioEffectsItem = [self setupRightItemWithFrame:CGRectMake(0, 0, topViewButtonSize.width, topViewButtonSize.height)
                                                   title:AUILiveCameraPushString(@"音效")
                                             normalImage:[AUILiveCameraPushImage(@"alivc_audio_effects") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                             selectImage:[AUILiveCameraPushImage(@"alivc_audio_effects") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                                  action:@selector(audioEffectsButtonAction:)
                                             customImage:YES];
    [self.topView addSubview:self.audioEffectsItem];
    
    self.beautySettingItem = [self setupRightItemWithFrame:CGRectMake(0, 70, topViewButtonSize.width, topViewButtonSize.height)
                                                    title: AUILiveCameraPushString(@"美颜")
                                              normalImage:AUILiveCommonImage(@"alivc_beauty")
                                              selectImage:nil
                                                   action:@selector(beautySettingButtonAction:)
                                              customImage:NO];
    //[self.beautySettingItem setEnabled:self.config.beautyOn];
    [self.topView addSubview: self.beautySettingItem];
    
    self.musicItem = [self setupRightItemWithFrame:CGRectMake(0, 140, topViewButtonSize.width, topViewButtonSize.height)
                                            title: AUILiveCameraPushString(@"背景音乐")
                                      normalImage:AUILiveCameraPushImage(@"alivc_back_music")
                                      selectImage:nil
                                           action:@selector(musicButtonAction:)
                                      customImage:NO];
    [self.topView addSubview: self.musicItem];
    if (self.config.videoOnly) {
        [self.musicItem setHidden:YES];
    }
    
    self.flashItem = [self setupRightItemWithFrame:CGRectMake(0, self.config.videoOnly ? 140 : 210, topViewButtonSize.width, topViewButtonSize.height)
                                            title: AUILiveCommonString(@"闪光灯")
                                      normalImage:AUILiveCameraPushImage(@"alivc_flash")
                                      selectImage:AUILiveCameraPushImage(@"alivc_flash_selected")
                                           action:@selector(flashButtonAction:)
                                      customImage:NO];
    UIButton *flashItemButton = [self.flashItem viewWithTag:kTopViewButtonTag];
    [flashItemButton setSelected:self.config.flash];
    [flashItemButton setEnabled:self.config.cameraType==AlivcLivePushCameraTypeFront?NO:YES];
    [self.topView addSubview:self.flashItem];
    
    self.switchItem = [self setupRightItemWithFrame:CGRectMake(0, self.config.videoOnly ? 210 : 280, topViewButtonSize.width, topViewButtonSize.height)
                                             title: AUILiveCameraPushString(@"摄像头")
                                       normalImage:AUILiveCameraPushImage(@"alivc_camera_switch")
                                       selectImage:AUILiveCameraPushImage(@"alivc_camera_switch")
                                            action:@selector(switchButtonAction:)
                                       customImage:NO];
    [self.topView addSubview:self.switchItem];
    
    self.snapshotItem = [self setupRightItemWithFrame:CGRectMake(0, self.config.videoOnly ? 280 : 350, topViewButtonSize.width, topViewButtonSize.height)
                                               title: AUILiveCameraPushString(@"截图")
                                         normalImage:AUILiveCameraPushImage(@"alivc_capture")
                                         selectImage:nil
                                              action:@selector(snapshotButtonAction:)
                                         customImage:NO];
    [self.topView addSubview:self.snapshotItem];
    
    self.topView.showsVerticalScrollIndicator = NO;
    [self.topView setContentSize:CGSizeMake(topViewButtonSize.width, topViewButtonSize.height * 7)];
    //[self setupMusicSettingView];
    self.isMusicSettingShow = NO;
    self.isAnswerGameViewShow = NO;
}


- (void)setupBottomViews {
    
    self.bottomView = [[UIScrollView alloc] init];
    if (_config.orientation == AlivcLivePushOrientationLandscapeLeft || _config.orientation == AlivcLivePushOrientationLandscapeRight ) {
        self.bottomView.frame = CGRectMake(10,
                                           CGRectGetHeight(self.frame) -80,
                                           CGRectGetWidth(self.frame)  - 20,
                                           viewHeight);
        self.bottomView.contentSize = CGSizeMake((self.av_height / 6)*15, viewHeight);
        self.bottomView.alwaysBounceHorizontal = YES;

    }else{
        self.bottomView.frame = CGRectMake(10,
                                           CGRectGetHeight(self.frame) - viewHeight-80,
                                           CGRectGetWidth(self.frame) - 20,
                                           viewHeight);
        self.bottomView.contentSize = CGSizeMake(80*8, viewHeight);

    }
    
    self.bottomView.showsHorizontalScrollIndicator = NO;
    self.bottomView.backgroundColor = [UIColor clearColor];
    [self addSubview: self.bottomView];
    
    CGFloat buttonCount = 8;
    CGFloat retractX = (CGRectGetWidth(self.bottomView.frame) - viewWidth * 7) / (buttonCount + 1) + 10;
    
    self.previewButton = [self setupButtonWithFrame:(CGRectMake(retractX, 0, viewWidth, viewHeight))
                                        normalTitle:AUILiveCameraPushString(@"开始预览")
                                        selectTitle:AUILiveCameraPushString(@"停止预览")
                                          normalImg:AUILiveCameraPushImage(@"alivc_start_pre") selectImage:AUILiveCameraPushImage(@"alivc_stop_pre")
                                             action:@selector(previewButtonAction:)];
    [self.bottomView addSubview: self.previewButton];
    [self.previewButton setSelected:YES];
    
    self.pushButton = [self setupButtonWithFrame:(CGRectMake(retractX * 2 + viewWidth, 0, viewWidth, viewHeight))
                                     normalTitle:AUILiveCommonString(@"开始推流")
                                     selectTitle:AUILiveCommonString(@"停止推流")
                                       normalImg:AUILiveCameraPushImage(@"alivc_start_push") selectImage:AUILiveCameraPushImage(@"alivc_stop_push")
                                          action:@selector(pushButtonAction:)];
    [self.bottomView addSubview: self.pushButton];
    
    self.pauseButton = [self setupButtonWithFrame:(CGRectMake(retractX * 3 + viewWidth * 2, 0, viewWidth, viewHeight))
                                      normalTitle:AUILiveCameraPushString(@"暂停推图")
                                      selectTitle:AUILiveCameraPushString(@"继续推图")
                                        normalImg:AUILiveCameraPushImage(@"alivc_pause_push") selectImage:AUILiveCameraPushImage(@"alivc_resume_push")
                                           action:@selector(pauseButtonAction:)];
    [self.bottomView addSubview:self.pauseButton];
    
    self.restartButton = [self setupButtonWithFrame:(CGRectMake(retractX * 4 + viewWidth * 3, 0, viewWidth, viewHeight))
                                      normalTitle:AUILiveCameraPushString(@"重新推流")
                                      selectTitle:nil
                                          normalImg:AUILiveCameraPushImage(@"alivc_strop_push") selectImage:AUILiveCameraPushImage(@"alivc_strop_push_selected")
                                           action:@selector(restartButtonAction:)];
    [self.bottomView addSubview:self.restartButton];

    
    self.moreSettingButton = [self setupButtonWithFrame:(CGRectMake(retractX * 5 + viewWidth * 4, 0, viewWidth, viewHeight))
                                              normalTitle:AUILiveCameraPushString(@"更多设置")
                                              selectTitle:nil
                                              normalImg:AUILiveCameraPushImage(@"alivc_more_setting") selectImage:AUILiveCameraPushImage(@"alivc_more_setting")
                                                   action:@selector(moreSettingButtonAction:)];
    [self.bottomView addSubview: self.moreSettingButton];
    
    self.dataMonitorButton = [self setupButtonWithFrame:(CGRectMake(retractX * 6 + viewWidth * 5, 0, viewWidth, viewHeight))
                                              normalTitle:AUILiveCameraPushString(@"数据指标")
                                              selectTitle:nil
                                              normalImg:AUILiveCameraPushImage(@"alivc_data_show") selectImage:AUILiveCameraPushImage(@"alivc_data_show")
                                                   action:@selector(publisherDataMonitorView)];
    [self.bottomView addSubview: self.dataMonitorButton];
    
//    self.waterMarkButton = [self setupButtonWithFrame:(CGRectMake(retractX * 7 + viewWidth * 6, 0, viewWidth, viewHeight)) normalTitle:AUILiveCameraPushString(@"添加水印") selectTitle:nil normalImg:AUILiveCameraPushImage(@"alivc_pause") selectImage:AUILiveCameraPushImage(@"alivc_pause") action:@selector(publisherWaterMarkButtonAction:)];
//    [self.bottomView addSubview:self.waterMarkButton];
    
//    self.removeWaterMarkButton = [self setupButtonWithFrame:(CGRectMake(retractX * 8 + viewWidth * 7, 0, viewWidth, viewHeight)) normalTitle:AUILiveCameraPushString(@"水印显隐") selectTitle:nil normalImg:AUILiveCameraPushImage(@"alivc_pause") selectImage:AUILiveCameraPushImage(@"alivc_pause") action:@selector(publisherRemoveWaterMarkButtonAction:)];
//    [self.bottomView addSubview:self.removeWaterMarkButton];
    
}


- (void)setupInfoLabel {
    
    self.infoLabel = [[UILabel alloc] init];
    self.infoLabel.frame = CGRectMake(self.backButton.av_right, AVSafeTop, self.av_width - self.backButton.av_right * 2, topHeight - AVSafeTop);
    self.infoLabel.textColor = AUIFoundationColor(@"text_strong");
    self.infoLabel.font = AVGetMediumFont(18);
//    self.infoLabel.layer.masksToBounds = YES;
//    self.infoLabel.layer.cornerRadius = 10;
    self.infoLabel.textAlignment = NSTextAlignmentCenter;
    self.infoLabel.adjustsFontSizeToFitWidth = YES;
    self.infoLabel.minimumScaleFactor = 12;
    [self addSubview:self.infoLabel];
    self.infoLabel.hidden = YES;
}

- (void)setupMoreSettingView {
    self.moreSettingView = [[AUILiveMoreSettingView alloc] init];
    
    AlivcLiveSettingManager *manager = [AlivcLiveSettingManager manager];
    __weak typeof(self) weakSelf = self;
    self.moreSettingView.newConfigAction = ^(AlivcLiveSettingConfig * _Nonnull config) {
        __strong typeof(self) strongSelf = weakSelf;
        if (manager.moreSettingConfig.targetVideoBitrate != config.targetVideoBitrate) {
            manager.moreSettingConfig.targetVideoBitrate = config.targetVideoBitrate;
            [strongSelf maxBitrateValueChanged:config.targetVideoBitrate];
        }
        
        if (manager.moreSettingConfig.minVideoBitrate != config.minVideoBitrate) {
            manager.moreSettingConfig.minVideoBitrate = config.minVideoBitrate;
            [strongSelf minBitrateValueChanged:config.minVideoBitrate];
        }

        if (manager.moreSettingConfig.pushMirror != config.pushMirror) {
            manager.moreSettingConfig.pushMirror = config.pushMirror;
            [strongSelf pushMirrorSwitchAction:config.pushMirror];
        }
        
        if (manager.moreSettingConfig.previewMirror != config.previewMirror) {
            manager.moreSettingConfig.previewMirror = config.previewMirror;
            [strongSelf previewMirrorSwitchAction:config.previewMirror];
        }
        
        if (manager.moreSettingConfig.previewDisplayMode != config.previewDisplayMode) {
            manager.moreSettingConfig.previewDisplayMode = config.previewDisplayMode;
            [strongSelf previewDisplayModeChange:(int)config.previewDisplayMode];
        }
    };
    [self addSubview:self.moreSettingView];
}

- (void)setupMusicSettingView {
    self.musicSettingView = [[AUILiveBgMusicSettingView alloc] init];
    self.musicSettingView.delegate = (id)self.delegate;
    [self addSubview:self.musicSettingView];
}

- (void)setupAudioEffectsPanel {
    NSData *audioEffectsConfig = [[NSData alloc] initWithContentsOfFile:AUILiveAudioEffectsConfig];
    NSArray<NSDictionary *> *sourceData = [NSJSONSerialization JSONObjectWithData:audioEffectsConfig options:0 error:nil];
    
    NSMutableArray *items = [NSMutableArray array];
    NSMutableArray *contents = [NSMutableArray array];
    [sourceData enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [items addObject:obj[@"name"]];
        [contents addObject:obj[@"content"]];
    }];
    
    self.audioEffectsPanel = [[AUILiveSegmentPanel alloc] initWithView:self items:items.copy animation:YES];
    self.audioEffectsPanel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
    self.audioEffectsPanel.contentImagePath = AUILiveAudioEffectsImage;
    self.audioEffectsPanel.contentTitlePath = AUILiveAudioEffectsString;
    
    self.audioEffectsPanel.contents = contents;
    
    __weak typeof(self) weakSelf = self;
    self.audioEffectsPanel.selectContent = ^(NSInteger itemIndex, NSInteger contentIndex) {
        __strong typeof(self) strongSelf = weakSelf;
        if (itemIndex == 0) {  // 变声
            if ([strongSelf.delegate respondsToSelector:@selector(publisherOnSelectAudioEffectsVoiceChangeMode:)]) {
                [strongSelf.delegate publisherOnSelectAudioEffectsVoiceChangeMode:contentIndex];
            }
        } else { // 混响
            if ([strongSelf.delegate respondsToSelector:@selector(publisherOnSelectAudioEffectsReverbMode:)]) {
                [strongSelf.delegate publisherOnSelectAudioEffectsReverbMode:contentIndex];
            }
        }
    };
}

- (void)setupAnswerGameView {
    
    CGRect frame = CGRectMake(20, self.frame.size.height/4, self.frame.size.width-40, self.frame.size.height/2);
    if (self.bounds.size.width > self.bounds.size.height) {
        frame = CGRectMake(self.frame.size.width/4, self.frame.size.height/3, self.frame.size.width/2, self.frame.size.height/3*2);
    }
    self.answerGameView = [[AUILiveAnswerGameView alloc] initWithFrame:frame];
    self.answerGameView.center = self.center;
    [self.answerGameView setAnswerDelegate:(id)self.delegate];

}

- (void)setupDebugViews {
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    self.debugChartView = [[AUILiveDebugChartView alloc] initWithFrame:(CGRectMake(width, 0, width, height))];
    self.debugChartView.backgroundColor = AUILiveCameraPushColor(@"ir_debugchart_bg");
    [self addSubview:self.debugChartView];
    
    
    self.debugTextView = [[AUILiveDebugTextView alloc] initWithFrame:(CGRectMake(-width, 0, width, height))];
    self.debugTextView.backgroundColor = AUILiveCameraPushColor(@"ir_debugchart_bg");
    [self addSubview:self.debugTextView];
}


- (void)addGesture {
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    tap.numberOfTapsRequired = 1;
    tap.delegate = self;
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    
    UISwipeGestureRecognizer *leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)];
    leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;

    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipe:)];
    rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self addGestureRecognizer:pinch];
    [self addGestureRecognizer:tap];
    
    UITapGestureRecognizer *doubleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleRecognizer.delegate = self;
    doubleRecognizer.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleRecognizer];

    // 双击手势确定监测失败才会触发单击手势的相应操作
    [tap requireGestureRecognizerToFail:doubleRecognizer];

//    [self addGestureRecognizer:leftSwipeGestureRecognizer];
//    [self addGestureRecognizer:rightSwipeGestureRecognizer];
}



- (UIButton *)setupButtonWithFrame:(CGRect)rect
                       normalTitle:(NSString *)normal selectTitle:(NSString *)select
                            action:(SEL)action {
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    button.frame = rect;
    [button addTarget:self action:action forControlEvents:(UIControlEventTouchUpInside)];
    [button setTitle:normal forState:(UIControlStateNormal)];
    [button setTitle:select forState:(UIControlStateSelected)];
    [button setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    button.titleLabel.font = [UIFont systemFontOfSize:13.f];
    button.backgroundColor = [UIColor whiteColor];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = rect.size.height / 5;
    
    return button;
}

- (UIButton *)setupButtonWithFrame:(CGRect)rect
                       normalTitle:(NSString *)normal selectTitle:(NSString *)select
                         normalImg:(UIImage *)normalImg
                       selectImage:(UIImage *)selImg
                            action:(SEL)action {
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    button.frame = rect;
    [button addTarget:self action:action forControlEvents:(UIControlEventTouchUpInside)];
    [button setTitle:normal forState:(UIControlStateNormal)];
    [button setTitle:select forState:(UIControlStateSelected)];
    [button setTitleColor:AUILiveCameraPushColor(@"ir_pushbutton_title") forState:(UIControlStateNormal)];
    [button setTitleColor:AUILiveCommonColor(@"ir_sheet_button") forState:(UIControlStateSelected)];
    button.titleLabel.font = AVGetRegularFont(10);
    button.backgroundColor = [UIColor clearColor];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
//    button.titleLabel.backgroundColor = [UIColor redColor];
//    button.layer.masksToBounds = YES;
//    button.layer.cornerRadius = rect.size.height / 5;
    
    [button setImage:normalImg forState:UIControlStateNormal];
    [button setImage:selImg forState:UIControlStateSelected];

    CGSize imageSize = button.imageView.frame.size;
    CGSize titleSize = button.titleLabel.frame.size;
    
    // get the height they will take up as a unit
    CGFloat totalHeight = (imageSize.height + titleSize.height + 5);
    
    // raise the image and push it right to center it
    button.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0.0 , 0.0, - titleSize.width);
    
    // lower the text and push it left to center it
    button.titleEdgeInsets = UIEdgeInsetsMake(
                                                  0.0, - imageSize.width, - (totalHeight - titleSize.height), 0.0);
    
//    button.backgroundColor = [UIColor redColor];
//    [button setImageEdgeInsets:UIEdgeInsetsMake(16, 35, 30, 35)];
//    [button setTitleEdgeInsets:UIEdgeInsetsMake(40, -  (rect.size.width - (rect.size.width - 70/2)) / 2, 0, 10)];

    return button;
}




- (UIButton *)setupButtonWithFrame:(CGRect)rect normalImage:(UIImage *)normal selectImage:(UIImage *)select action:(SEL)action {
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    button.frame = rect;
    [button addTarget:self action:action forControlEvents:(UIControlEventTouchUpInside)];
    [button setImage:normal forState:(UIControlStateNormal)];
    [button setImage:select forState:(UIControlStateSelected)];
    return button;
}

- (UIView *)setupRightItemWithFrame:(CGRect)rect title:(NSString *)title normalImage:(UIImage *)normal selectImage:(UIImage *)select action:(SEL)action customImage:(BOOL)customImage {
    UIView *itemView = [[UIView alloc] initWithFrame:rect];
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    button.frame = CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect) - 15 - 10);
    button.tag = kTopViewButtonTag;
    [button addTarget:self action:action forControlEvents:(UIControlEventTouchUpInside)];
    [button setImage:normal forState:(UIControlStateNormal)];
    [button setImage:select forState:(UIControlStateSelected)];
    [itemView addSubview:button];
    
    if (customImage) {
        button.imageView.tintColor = [UIColor colorWithRed:38/255.0 green:38/255.0 blue:38/255.0 alpha:1];
        button.imageView.backgroundColor = [UIColor colorWithRed:218/255.0 green:218/255.0 blue:218/255.0 alpha:1];
        button.imageView.layer.cornerRadius = 16;
        button.imageView.layer.masksToBounds = YES;
    }
    
    UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(rect) - 15, CGRectGetWidth(rect), 15)];
    itemLabel.textColor = [UIColor blackColor];
    itemLabel.font = AVGetRegularFont(10);
    itemLabel.text = title;
    itemLabel.textAlignment = NSTextAlignmentCenter;
    [itemView addSubview:itemLabel];
    
    return itemView;
}

#pragma mark - Button Actions
- (void)backButtonAction:(UIButton *)sender {
    
    if (self.delegate) {
        [self.delegate publisherOnClickedBackButton];
    }
}


- (void)previewButtonAction:(UIButton *)sender {
    
    [sender setSelected:!sender.selected];
    
    if (self.delegate) {
        if([self.delegate publisherOnClickedPreviewButton:sender.selected button:sender] == 0 && sender.selected) {
            
            NSUInteger count = [dynamicWatermarkArr count];
            while(count > 0) {
                
                [dynamicWatermarkArr removeObjectAtIndex:0];
                count = [dynamicWatermarkArr count];
            }
        }
    }
    
    self.pushMirrorSwitch.enabled = sender.selected;
    self.previewMirrorSwitch.enabled = sender.selected;
}


- (void)pushButtonAction:(UIButton *)sender {
    
    [sender setSelected:!sender.selected];
    if (self.delegate) {
        BOOL ret = [self.delegate publisherOnClickedPushButton:sender.selected button:sender];
        if (ret) {
            [self.pauseButton setSelected:NO];
        }
    }
}


- (void)musicButtonAction:(UIButton *)sender {
    if (!self.musicSettingView) {
        [self setupMusicSettingView];
    }
    [self.musicSettingView show:self.config];
    self.isMusicSettingShow = YES;
    
    [self hideAudioEffects];
}


- (void)answerGameButtonAction:(UIButton *)sender {
    
    if (!self.answerGameView) {
        [self setupAnswerGameView];
    }
    [self addSubview:self.answerGameView];
    self.isAnswerGameViewShow = YES;
    
    [self hideAudioEffects];
}


- (void)beautySettingButtonAction:(UIButton *)sender {
    if (self.delegate) {
        [self.delegate publisherOnClickedBeautyButton:YES];
    }
    
    [self hideAudioEffects];
}

- (void)moreSettingButtonAction:(UIButton *)sender {
    if (!self.moreSettingView) {
        [self setupMoreSettingView];
    }
    [self.moreSettingView show];
    
    [self hideAudioEffects];
}

- (void)publisherDataMonitorView{
    if (self.delegate) {
        [self.delegate publisherDataMonitorView];
    }
}

- (void)publisherWaterMarkButtonAction:(UIButton *)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(publisherOnClickedWaterMarkButton)])
    {
        [self.delegate publisherOnClickedWaterMarkButton];
    }
}

- (void)publisherRemoveWaterMarkButtonAction:(UIButton *)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(publisherOnClickedRemoveWaterMarkButton)])
    {
        [self.delegate publisherOnClickedRemoveWaterMarkButton];
    }
}

- (void)switchButtonAction:(UIButton *)sender {
    
    if (self.delegate) {
        [self.delegate publisherOnClickedSwitchCameraButton];
    }
    
    [sender setEnabled:!sender.enabled];
    
    [self hideAudioEffects];
}

- (void)audioEffectsButtonAction:(UIButton *)sender {
    if (!self.audioEffectsPanel) {
        [self setupAudioEffectsPanel];
    }
    
    if ([self.audioEffectsPanel isShow]) {
        [self.audioEffectsPanel hide];
    } else {
        [self.audioEffectsPanel show];
    }
}

- (void)hideAudioEffects {
    if ([self.audioEffectsPanel isShow]) {
        [self.audioEffectsPanel hide];
    }
}

- (void)snapshotButtonAction:(UIButton *)sender {
    
    if (self.delegate) {
        [self.delegate publisherOnClickedSnapshotButton];
    }
    
    [self hideAudioEffects];
}


- (void)flashButtonAction:(UIButton *)sender {
    
    [sender setSelected:!sender.selected];
    if (self.delegate) {
        [self.delegate publisherOnClickedFlashButton:sender.selected button:sender];
    }
    
    [self hideAudioEffects];
}


- (void)pauseButtonAction:(UIButton *)sender {
    
    [sender setSelected:!sender.selected];
    if (self.delegate) {
        [self.delegate publisherOnClickedPauseButton:sender.selected button:sender];
    }
}


- (void)restartButtonAction:(UIButton *)sender {
    
    if (self.delegate) {
        if([self.delegate publisherOnClickedRestartButton] == 0) {
            
            NSUInteger count = [dynamicWatermarkArr count];
            while(count > 0) {
                
                [dynamicWatermarkArr removeObjectAtIndex:0];
                count = [dynamicWatermarkArr count];
            }
        }
    }
}

- (void)sharedButtonAction:(UIButton *)sender {
    
    if (self.delegate) {
        [self.delegate publisherOnClickSharedButon];
    }
}

- (int)addButtonAction:(UIButton *)sender {
    
    if (self.delegate) {
        
        NSString *resourceBundle = [[NSBundle mainBundle] pathForResource:@"AlivcLibDynamicWaterMark" ofType:@"bundle"];

        char filePath[188] = {0};
        const char *doc_path = 0;
        {
            NSString *docPath = [resourceBundle stringByAppendingFormat:@"/Resources"];
            doc_path = [docPath UTF8String];
            strncpy((char*)filePath, doc_path, 187);
        }

        NSString * bundleAddOnPath = [NSString stringWithUTF8String:filePath];
        
        int count = [dynamicWatermarkArr count];
        
        if(count >= maxDynamicWatermarkCount) {
            return -1;
        }
        
        int index = [self.delegate publisherOnClickAddDynamically:bundleAddOnPath  x:0.3+count*0.1 y:0.3+count*0.1 w:0.5 h:0.5];
        if(index <= 0)
        {
            return -1;
        }
        NSNumber *num = [NSNumber numberWithInt:index];
        [dynamicWatermarkArr addObject: num];
        return index;
        
    }
    return -1;
}

-(void)previewDisplayModeChange:(int)previewDisplayMode {
   
    if (self.delegate) {
        if (_config.orientation == AlivcLivePushOrientationLandscapeLeft || _config.orientation == AlivcLivePushOrientationLandscapeRight ) {
            if (previewDisplayMode == 1) {
                self.bottomView.av_left = 0;
                self.bottomView.av_top = self.av_height - 80;
            }else{
                self.bottomView.av_left = 0;
                self.bottomView.av_top = self.av_height - 50;
            }

        }else{
            if (previewDisplayMode == 1) {
                self.bottomView.av_left = 0;
                self.bottomView.av_top = self.av_height - viewHeight - 80;
            }else{
                self.bottomView.av_left = 0;
                self.bottomView.av_top = self.av_height - viewHeight - 50;
            }

        }
        [self.delegate publisherOnSelectPreviewDisplayMode:previewDisplayMode];
    }
  
}

- (void)removeButtonAction:(UIButton *)sender {
    
    if (self.delegate) {
    
        int count = [dynamicWatermarkArr count];
        
        if(count > 0) {
            NSNumber *num = [dynamicWatermarkArr objectAtIndex:count - 1];
            
            int index = [num intValue];
            
            [dynamicWatermarkArr removeObjectAtIndex:count - 1];
            
            [self.delegate publisherOnClickRemoveDynamically:index];
        }
       
    }
}

- (void)autoFocusSwitchAction:(UISwitch *)sender {
    
    if (self.delegate) {
        [self.delegate publisherOnClickAutoFocusButton:sender.on];
    }
}

- (void)pushMirrorSwitchAction:(BOOL)on {
    
    if (self.delegate) {
        [self.delegate publisherOnClickPushMirrorButton:on];
    }
}

- (void)previewMirrorSwitchAction:(BOOL)on {
    
    if (self.delegate) {
        [self.delegate publisherOnClickPreviewMirrorButton:on];
    }
}


#pragma mark - Gesture

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([[touch.view class] isEqual:[self class]]) {
        return YES;
    }
    return  NO;
}

-(void)doubleTap:(UITapGestureRecognizer *)gesture{
    _isHiddenBtns = !_isHiddenBtns;
    self.topView.hidden = _isHiddenBtns;
    self.bottomView.hidden = _isHiddenBtns;
    self.backButton.hidden = _isHiddenBtns;
    self.infoLabel.hidden = _isHiddenBtns;
    
#ifdef DEBUG
    if (_isHiddenBtns) {
        [AlivcLivePusher hideDebugView];
    }else{
        [AlivcLivePusher showDebugView];
    }
#endif
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture{

    if (self.isKeyboardEdit) {
        
        [self endEditing:YES];
    } else if (self.isAnswerGameViewShow) {
        
        [self.answerGameView removeFromSuperview];
        self.isAnswerGameViewShow = NO;
    } else {
        
        CGPoint point = [gesture locationInView:self];
        CGPoint percentPoint = CGPointZero;
        percentPoint.x = point.x / CGRectGetWidth(self.bounds);
        percentPoint.y = point.y / CGRectGetHeight(self.bounds);
//        NSLog(@"聚焦点  - x:%f y:%f", percentPoint.x, percentPoint.y);
        if (self.delegate) {
            [self.delegate publisherOnClickedFocus:percentPoint];
        }
    }
    
    [self hideAudioEffects];
}

static CGFloat lastPinchDistance = 0;
- (void)pinchGesture:(UIPinchGestureRecognizer *)gesture {
    
    if (gesture.numberOfTouches != 2) {
        return;
    }
    CGPoint p1 = [gesture locationOfTouch:0 inView:self];
    CGPoint p2 = [gesture locationOfTouch:1 inView:self];
    CGFloat dx = (p2.x - p1.x);
    CGFloat dy = (p2.y - p1.y);
    CGFloat dist = sqrt(dx*dx + dy*dy);
    if (gesture.state == UIGestureRecognizerStateBegan) {
        lastPinchDistance = dist;
    }
    
    CGFloat change = dist - lastPinchDistance;

    NSLog(@"zoom - %f", change);

    if (self.delegate) {
        [self.delegate publisherOnClickedZoom:change/3000];
    }
}


- (void)leftSwipe:(UISwipeGestureRecognizer *)swipe {
    
    if (self.guideView) {
        [self.guideView removeFromSuperview];
        self.guideView = nil;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:AlivcUserDefaultsIndentifierFirst];
    }
    
    if (self.currentIndex == 0) {
        if (self.delegate) {
            [self.delegate publisherOnClickedShowDebugTextInfo:NO];
            [self animationWithView:self.debugTextView x:-self.bounds.size.width];
        }
        self.currentIndex++;
        return;
    }
    
    if (self.currentIndex == 1) {
        if (self.delegate) {
            [self.delegate publisherOnClickedShowDebugChartInfo:YES];
            [self animationWithView:self.debugChartView x:0];
        }
        self.currentIndex++;
        return;
    }
    
    if (self.currentIndex == 2) {
        // 无效
        return;
    }
}


- (void)rightSwipe:(UISwipeGestureRecognizer *)swipe {
    
    if (self.guideView) {
        [self.guideView removeFromSuperview];
        self.guideView = nil;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:AlivcUserDefaultsIndentifierFirst];
    }
    
    if (self.currentIndex == 0) {
        // 无效
        return;
    }
    
    if (self.currentIndex == 1) {
        if (self.delegate) {
            [self.delegate publisherOnClickedShowDebugTextInfo:YES];
            [self animationWithView:self.debugTextView x:0];
        }
        self.currentIndex--;
        return;
    }
    
    if (self.currentIndex == 2) {
        if (self.delegate) {
            [self.delegate publisherOnClickedShowDebugChartInfo:NO];
            [self animationWithView:self.debugChartView x:self.bounds.size.width];
        }
        self.currentIndex--;
        return;
    }

}

#pragma mark - Animation

- (void)animationWithView:(UIView *)view x:(CGFloat)x {
    
    [UIView animateWithDuration:0.5 animations:^{
       
        CGRect frame = view.frame;
        frame.origin.x = x;
        view.frame = frame;
    }];
    
}


#pragma mark - TextField Actions

- (void)maxBitrateValueChanged:(int)targetBitrate {
    if (self.delegate) {
        [self.delegate publisherOnBitrateChangedTargetBitrate:targetBitrate];
    }
}

- (void)minBitrateValueChanged:(int)minBitrate {
    if (self.delegate) {
        [self.delegate publisherOnBitrateChangedMinBitrate:minBitrate];
    }
}


#pragma mark - Public

- (void)updateInfoText:(NSString *)text {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!_isHiddenBtns){
            [self.infoLabel setHidden:NO];
        }
        self.infoLabel.text = text;
//        [NSObject cancelPreviousPerformRequestsWithTarget:self];
//        [self performSelector:@selector(hiddenInfoLabel) withObject:nil afterDelay:0];
    });
}

- (void)hiddenInfoLabel {
    
    [self.infoLabel setHidden:YES];
}


- (void)updateDebugChartData:(AlivcLivePushStatsInfo *)info {
    
    [self.debugChartView updateData:info];
}

- (void)updateDebugTextData:(AlivcLivePushStatsInfo *)info {
    
    [self.debugTextView updateData:info];
}


- (void)hiddenVideoViews {
    
    self.beautySettingItem.hidden = YES;
    self.flashItem.hidden = YES;
    self.switchItem.hidden = YES;
    self.moreSettingButton.hidden = YES;
}

- (void)updateMusicDuration:(long)currentTime totalTime:(long)totalTime {
    [self.musicSettingView updateMusicPlayProgressTime:currentTime durationTime:totalTime];
}

- (void)resetMusicButtonTypeWithPlayError {
    [self.musicSettingView resetMusicPlayStatusWithError];
}


- (BOOL)getPushButtonType {
    
    return self.pushButton.selected;
}

#pragma mark - Notification

- (void)addNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackGround:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)sender {
    
    if(self.isKeyboardEdit){
        return;
    }
    self.isKeyboardEdit = YES;
}

- (void)keyboardWillHide:(NSNotification *)sender {
    self.isKeyboardEdit = NO;
}

- (void)onAppDidEnterBackGround:(NSNotification *)notification
{
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
    }];

}


@end
