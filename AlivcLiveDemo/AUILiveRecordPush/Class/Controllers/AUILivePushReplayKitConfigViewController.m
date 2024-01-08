//
//  AUILivePushReplayKitConfigViewController.m
//  AlivcLiveCaptureDev
//
//  Created by lyz on 2017/9/20.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import "AUILivePushReplayKitConfigViewController.h"
#import "AUILiveParamTableViewCell.h"
#import "AlivcLiveParamModel.h"
#import "AUILiveWatermarkSettingView.h"
#import "AUILiveQRCodeViewController.h"

#define kAPPGROUP @"group.com.aliyun.AlivcLivePusherDemo"

@interface AUILivePushReplayKitConfigViewController () <UITableViewDelegate, UITableViewDataSource, AlivcLivePusherInfoDelegate, AlivcLiveBaseObserver>

@property (nonatomic, strong) UITextField *publisherURLTextField;
@property (nonatomic, strong) UIButton *QRCodeButton;
@property (nonatomic, strong) UIButton *urlCopyButton;
@property (nonatomic, strong) UITableView *paramTableView;
@property (nonatomic, strong) UIButton *publisherButton;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) AUILiveWatermarkSettingDrawView *waterSettingView;

@property (nonatomic, assign) BOOL isUseAsync; // 是否使用异步接口
@property (nonatomic, assign) BOOL isUseWatermark; // 是否使用水印
@property (nonatomic, copy) NSString *authDuration; // 测试鉴权，过期时长
@property (nonatomic, copy) NSString *authKey; // 测试鉴权，账号key
@property (nonatomic, assign) BOOL isUseOriginResolution; // 是否使用原始分辨率


@property (nonatomic, strong) AlivcLivePushConfig *pushConfig;
@property (nonatomic, strong) AlivcLivePusher *livePusher;

@property (nonatomic, copy)NSString *pushUrl;


@property (nonatomic, assign) BOOL isUserMainStream;
@property (nonatomic, assign) BOOL isUserMixStream;

@property (nonatomic, assign) BOOL isKeyboardShow;
@property (nonatomic, assign) CGRect tableViewFrame;

@property (nonatomic, strong) UILabel *infoLabel;


@property (nonatomic, assign) BOOL isPushing;




@end

@implementation AUILivePushReplayKitConfigViewController

- (void)viewDidLoad {
    
    _isPushing = NO;
    [super viewDidLoad];
    self.hiddenMenuButton = YES;
    
    [self setupParamData];
    [self setupSubviews];
    [self addKeyboardNoti];
    [self registerSDK];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [AVToastView show:AUILiveRecordPushString(@"示例Demo不提供录屏推流演示过程，需要自行根据文档配置。") view:self.view position:AVToastViewPositionMid];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI
- (void)setupSubviews {
    
    UIView *inputContentView = [[UIView alloc] initWithFrame:CGRectMake(self.backButton.av_right + 18, 0, self.headerView.av_width - self.backButton.av_right - 18 - 24, 32)];
    inputContentView.av_centerY = self.backButton.av_centerY;
    inputContentView.backgroundColor = AUIFoundationColor(@"fill_weak");
    [self.headerView addSubview:inputContentView];
    
    self.QRCodeButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.QRCodeButton.frame = CGRectMake(12, (inputContentView.av_height - 30)/2.0, 30, 30);
    [self.QRCodeButton setImage:AUILiveCommonImage(@"ic_scan") forState:(UIControlStateNormal)];
    self.QRCodeButton.layer.masksToBounds = YES;
    self.QRCodeButton.layer.cornerRadius = 10;
    [self.QRCodeButton addTarget:self action:@selector(QRCodeButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [inputContentView addSubview:self.QRCodeButton];
    
    self.publisherURLTextField = [[UITextField alloc] init];
    self.publisherURLTextField.frame = CGRectMake(self.QRCodeButton.av_right + 8, (inputContentView.av_height - 30)/2.0, inputContentView.av_width - self.QRCodeButton.av_right - 8, 30);
//    self.publisherURLTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.publisherURLTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:AUILiveCommonString(@"请输入推流url") attributes:@{
        NSFontAttributeName: AVGetRegularFont(14),
        NSForegroundColorAttributeName: AUIFoundationColor(@"text_ultraweak"),
    }];
    self.publisherURLTextField.font = AVGetRegularFont(14);
    self.publisherURLTextField.textColor = AUIFoundationColor(@"text_strong");
    self.publisherURLTextField.clearsOnBeginEditing = NO;
    self.publisherURLTextField.backgroundColor = [UIColor clearColor];
    self.publisherURLTextField.clearButtonMode = UITextFieldViewModeAlways;
    [inputContentView addSubview:self.publisherURLTextField];
    
    self.publisherButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.publisherButton.frame = CGRectMake(20, self.contentView.av_height - AVSafeBottom - 8 - 48, self.contentView.av_width - 20 * 2, 48);
    self.publisherButton.backgroundColor = AUIFoundationColor(@"colourful_ic_strong");
    [self.publisherButton setTitle:AUILiveCommonString(@"开始推流") forState:(UIControlStateNormal)];
    [self.publisherButton setTitleColor:AUILiveRecordPushColor(@"ir_button_text") forState:UIControlStateNormal];
    [self.publisherButton av_setLayerBorderColor:AUIFoundationColor(@"colourful_ic_strong") borderWidth:0.5];
    self.publisherButton.layer.cornerRadius = 24;
    [self.publisherButton addTarget:self action:@selector(publiherButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.contentView addSubview:self.publisherButton];
    
    self.paramTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.av_width, self.publisherButton.av_top) style:UITableViewStyleGrouped];
    self.paramTableView.backgroundColor = AUIFoundationColor(@"bg_weak");
    self.paramTableView.userInteractionEnabled = YES;
    self.paramTableView.scrollEnabled = NO;
    self.paramTableView.delegate = (id)self;
    self.paramTableView.dataSource = (id)self;
    self.paramTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.contentView addSubview:self.paramTableView];
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.paramTableView reloadData];
        [self updateBitrateAndFPSCell];
    });

    
    //self.waterSettingView = [[AUILiveWatermarkSettingDrawView alloc] initWithFrame:(CGRectMake(0, AlivcScreenHeight - 330), AlivcScreenWidth, 330)))];

    self.isKeyboardShow = false;
    self.tableViewFrame = self.paramTableView.frame;
    
    [self.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchAction)]];
}

#pragma mark - Data
- (void)setupParamData {
    self.isUseWatermark = NO;
    self.isUseAsync = YES;
    self.isUseOriginResolution = NO;
    
    self.pushConfig = [[AlivcLivePushConfig alloc] init];
    
    AlivcLiveParamModel *resolutionTitleModel = [[AlivcLiveParamModel alloc] init];
    resolutionTitleModel.reuseId = AlivcLiveParamModelReuseCellSliderHeader;
    resolutionTitleModel.title = AUILiveCommonString(@"分辨率");
    
    AlivcLiveParamModel *resolutionModel = [[AlivcLiveParamModel alloc] init];
    resolutionModel.title = AUILiveCommonString(@"分辨率");
    resolutionModel.placeHolder = @"540P";
    resolutionModel.infoText = @"540P";
    resolutionModel.defaultValue = 4.0/6.0;
    resolutionModel.reuseId = AlivcLiveParamModelReuseCellSlider;
    resolutionModel.sliderBlock = ^(int value){
        self.pushConfig.resolution = value;
        [self updateBitrateAndFPSCell];
    };
    
    AlivcLiveParamModel *targetBitrateModel = [[AlivcLiveParamModel alloc] init];
    targetBitrateModel.title = AUILiveCommonString(@"视频目标码率");
    targetBitrateModel.defaultValue = 800;
    targetBitrateModel.infoText = @"Kbps";
    targetBitrateModel.reuseId = AlivcLiveParamModelReuseCellInput;
    targetBitrateModel.valueBlock = ^(int value) {
        self.pushConfig.targetVideoBitrate = value;
    };
    
    AlivcLiveParamModel *minBitrateModel = [[AlivcLiveParamModel alloc] init];
    minBitrateModel.title = AUILiveCommonString(@"视频最小码率");
    minBitrateModel.defaultValue = 200;
    minBitrateModel.infoText = @"Kbps";
    minBitrateModel.reuseId = AlivcLiveParamModelReuseCellInput;
    minBitrateModel.valueBlock = ^(int value) {
        self.pushConfig.minVideoBitrate = value;
    };
    
    AlivcLiveParamModel *initBitrateModel = [[AlivcLiveParamModel alloc] init];
    initBitrateModel.title = AUILiveCommonString(@"视频初始码率");
    initBitrateModel.defaultValue = 800;
    initBitrateModel.infoText = @"Kbps";
    initBitrateModel.reuseId = AlivcLiveParamModelReuseCellInput;
    initBitrateModel.valueBlock = ^(int value) {
        self.pushConfig.initialVideoBitrate = value;
    };
    
    AlivcLiveParamModel *audioBitrateModel = [[AlivcLiveParamModel alloc] init];
    audioBitrateModel.title = AUILiveCommonString(@"音频码率");
    audioBitrateModel.defaultValue = 64;
    audioBitrateModel.infoText = @"Kbps";
    audioBitrateModel.reuseId = AlivcLiveParamModelReuseCellInput;
    audioBitrateModel.valueBlock = ^(int value) {
        self.pushConfig.audioBitrate = value;
    };
    
    AlivcLiveParamModel *audioSampelModel = [[AlivcLiveParamModel alloc] init];
    audioSampelModel.title = AUILiveCommonString(@"音频采样率");
    audioSampelModel.placeHolder = @"32kHz";
    audioSampelModel.infoText = @"32kHz";
    audioSampelModel.defaultValue = 1.0/2.0;
    audioSampelModel.reuseId = AlivcLiveParamModelReuseCellSlider;
    audioSampelModel.sliderBlock = ^(int value) {
        self.pushConfig.audioSampleRate = value;
    };
    
    AlivcLiveParamModel *fpsModel = [[AlivcLiveParamModel alloc] init];
    fpsModel.title = AUILiveCommonString(@"采集帧率");
    fpsModel.pickerPanelTextArray = @[@"8",@"10",@"12",@"15",@"20",@"25",@"30"];
    fpsModel.defaultValue = 4;
    fpsModel.reuseId = AlivcLiveParamModelReuseCellPickerSelect;
    fpsModel.pickerSelectBlock = ^(int value) {
        self.pushConfig.fps = value;
    };
    
    AlivcLiveParamModel *minFPSModel = [[AlivcLiveParamModel alloc] init];
    minFPSModel.title = AUILiveCommonString(@"最小帧率");
    minFPSModel.pickerPanelTextArray = @[@"8",@"10",@"12",@"15",@"20",@"25",@"30"];
    minFPSModel.defaultValue = 0;
    minFPSModel.reuseId = AlivcLiveParamModelReuseCellPickerSelect;
    minFPSModel.pickerSelectBlock = ^(int value) {
        self.pushConfig.minFps = value;
    };
    
    AlivcLiveParamModel *gopModel = [[AlivcLiveParamModel alloc] init];
    gopModel.title = AUILiveCommonString(@"关键帧间隔");
    gopModel.pickerPanelTextArray = @[@"1s",@"2s",@"3s",@"4s",@"5s"];
    gopModel.defaultValue = 1.0;
    gopModel.reuseId = AlivcLiveParamModelReuseCellPickerSelect;
    gopModel.pickerSelectBlock = ^(int value) {
        self.pushConfig.videoEncodeGop = value;
    };
    
    AlivcLiveParamModel *reconnectDurationModel = [[AlivcLiveParamModel alloc] init];
    reconnectDurationModel.title = AUILiveCommonString(@"重连时长");
    reconnectDurationModel.defaultValue = 1000;
    reconnectDurationModel.infoText = AUILiveRecordPushString(@"/ms");
    reconnectDurationModel.reuseId = AlivcLiveParamModelReuseCellInput;
    reconnectDurationModel.valueBlock = ^(int value) {
        self.pushConfig.connectRetryInterval = value;
    };
    
    AlivcLiveParamModel *reconnectTimeModel = [[AlivcLiveParamModel alloc] init];
    reconnectTimeModel.title = AUILiveCommonString(@"重连次数");
    reconnectTimeModel.defaultValue = 5;
    reconnectTimeModel.infoText = AUILiveRecordPushString(@"/次");
    reconnectTimeModel.reuseId = AlivcLiveParamModelReuseCellInput;
    reconnectTimeModel.valueBlock = ^(int value) {
        self.pushConfig.connectRetryCount = value;
    };
    
    AlivcLiveParamModel *orientationModel = [[AlivcLiveParamModel alloc] init];
    orientationModel.title = AUILiveCommonString(@"推流方向");
    orientationModel.pickerPanelTextArray = @[AUILiveCommonString(@"竖屏"),AUILiveCommonString(@"横屏向左"),AUILiveCommonString(@"横屏向右")];
    orientationModel.defaultValue = 0;
    orientationModel.reuseId = AlivcLiveParamModelReuseCellPickerSelect;
    orientationModel.pickerSelectBlock = ^(int value) {
        self.pushConfig.orientation = value;
        
        if(self.pushConfig.pauseImg) {
            if(self.pushConfig.orientation == AlivcLivePushOrientationPortrait) {
                self.pushConfig.pauseImg = AUILiveCommonImage(@"background_push.png");
            } else{
                self.pushConfig.pauseImg = AUILiveCommonImage(@"background_push_land.png");
            }
        }
        
        if(self.pushConfig.networkPoorImg) {
            if(self.pushConfig.orientation == AlivcLivePushOrientationPortrait) {
                self.pushConfig.networkPoorImg = AUILiveCommonImage(@"poor_network.png");
            } else{
                self.pushConfig.networkPoorImg = AUILiveCommonImage(@"poor_network_land.png");
            }
        }

    };
    
    AlivcLiveParamModel *audioChannelModel = [[AlivcLiveParamModel alloc] init];
    audioChannelModel.title = AUILiveCommonString(@"声道数");
    audioChannelModel.segmentTitleArray = @[AUILiveCommonString(@"单声道"),AUILiveCommonString(@"双声道")];
    audioChannelModel.defaultValue = 0;
    audioChannelModel.reuseId = AlivcLiveParamModelReuseCellSegmentAtRecord;
    audioChannelModel.segmentBlock = ^(int value) {
        self.pushConfig.audioChannel = value;
    };
    
    AlivcLiveParamModel *audioProfileModel = [[AlivcLiveParamModel alloc] init];
    audioProfileModel.title = AUILiveCommonString(@"音频格式");
    audioProfileModel.segmentTitleArray = @[@"AAC_LC",@"HE_AAC",@"HEAAC_V2",@"AAC_LD"];
    audioProfileModel.defaultValue = 0;
    audioProfileModel.reuseId = AlivcLiveParamModelReuseCellSegmentAtRecord;
    audioProfileModel.segmentBlock = ^(int value) {
        self.pushConfig.audioEncoderProfile = value;
    };
    
    AlivcLiveParamModel *mirrorModel = [[AlivcLiveParamModel alloc] init];
    mirrorModel.title = AUILiveCommonString(@"推流镜像");
    mirrorModel.defaultValue = 0;
    mirrorModel.titleAppose = AUILiveCommonString(@"预览镜像");
    mirrorModel.defaultValueAppose = 0;
    mirrorModel.reuseId = AlivcLiveParamModelReuseCellSwitch;
    mirrorModel.switchBlock = ^(int index, BOOL open) {
        if (index == 0) {
            self.pushConfig.pushMirror = open?true:false;
        } else {
            self.pushConfig.previewMirror = open?true:false;
        }
    };
    
    
    AlivcLiveParamModel *audiOnly_encodeModeModel = [[AlivcLiveParamModel alloc] init];
    audiOnly_encodeModeModel.title = AUILiveCommonString(@"纯音频");
    audiOnly_encodeModeModel.defaultValue = 0;
//    audiOnly_encodeModeModel.titleAppose = AUILiveCommonString(@"视频硬编码");
    audiOnly_encodeModeModel.defaultValueAppose = 1.0;
    audiOnly_encodeModeModel.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    audiOnly_encodeModeModel.switchBlock = ^(int index, BOOL open) {
        if (index == 0) {
            self.pushConfig.audioOnly = open?true:false;
        } else {
            self.pushConfig.videoEncoderMode = open?AlivcLivePushVideoEncoderModeHard:AlivcLivePushVideoEncoderModeSoft;
        }
    };
    
    AlivcLiveParamModel *autoFocus_FlashModel = [[AlivcLiveParamModel alloc] init];
    autoFocus_FlashModel.title = AUILiveCommonString(@"自动对焦");
    autoFocus_FlashModel.defaultValue = 1.0;
    autoFocus_FlashModel.titleAppose = AUILiveCommonString(@"闪光灯");
    autoFocus_FlashModel.defaultValueAppose = 0;
    autoFocus_FlashModel.reuseId = AlivcLiveParamModelReuseCellSwitch;
    autoFocus_FlashModel.switchBlock = ^(int index, BOOL open) {
        if (index == 0) {
            self.pushConfig.autoFocus = open?true:false;
        } else {
            self.pushConfig.flash = open?true:false;
        }
    };
    
    AlivcLiveParamModel *beauty_cameraTypeModel = [[AlivcLiveParamModel alloc] init];
    beauty_cameraTypeModel.title = AUILiveCommonString(@"开启美颜");
    beauty_cameraTypeModel.defaultValue = 1.0;
//    beauty_cameraTypeModel.titleAppose = AUILiveCommonString(@"前置摄像头");
    beauty_cameraTypeModel.defaultValueAppose = 1.0;
    beauty_cameraTypeModel.reuseId = AlivcLiveParamModelReuseCellSwitch;
    beauty_cameraTypeModel.switchBlock = ^(int index, BOOL open) {
//        if (index == 0) {
            //self.pushConfig.beautyOn = open?true:false;
//        } else {
//            self.pushConfig.cameraType = open?AlivcLivePushCameraTypeFront:AlivcLivePushCameraTypeBack;
//        }
    };
    
    AlivcLiveParamModel *cameraTypeModel = [[AlivcLiveParamModel alloc] init];
    cameraTypeModel.title = AUILiveCommonString(@"前置摄像头");
    cameraTypeModel.defaultValue = 1.0;
//    cameraTypeModel.titleAppose = AUILiveCommonString(@"前置摄像头");
    cameraTypeModel.defaultValueAppose = 1.0;
    cameraTypeModel.reuseId = AlivcLiveParamModelReuseCellSwitch;
    cameraTypeModel.switchBlock = ^(int index, BOOL open) {
//        if (index == 0) {
//            self.pushConfig.beautyOn = open?true:false;
//        } else {
            self.pushConfig.cameraType = open?AlivcLivePushCameraTypeFront:AlivcLivePushCameraTypeBack;
//        }
    };

    
    AlivcLiveParamModel *autoBitrate_resolutionModel = [[AlivcLiveParamModel alloc] init];
    autoBitrate_resolutionModel.title = AUILiveCommonString(@"码率自适应");
    autoBitrate_resolutionModel.defaultValue = 1.0;
   // autoBitrate_resolutionModel.titleAppose = AUILiveRecordPushString(@"auto_resolution");
  //  autoBitrate_resolutionModel.defaultValueAppose = 0;
    autoBitrate_resolutionModel.reuseId = AlivcLiveParamModelReuseCellSwitch;
    autoBitrate_resolutionModel.switchBlock = ^(int index, BOOL open) {
        self.pushConfig.enableAutoBitrate = open?true:false;
        /*
        if (index == 0) {
            self.pushConfig.enableAutoBitrate = open?true:false;
        } else {
            self.pushConfig.enableAutoResolution = open?true:false;
        }
         */
    };
    
    AlivcLiveParamModel *userMainStream_userMixStreamModel = [[AlivcLiveParamModel alloc] init];
    userMainStream_userMixStreamModel.title = AUILiveCommonString(@"外部音视频");
    userMainStream_userMixStreamModel.reuseId = AlivcLiveParamModelReuseCellSwitch;
    userMainStream_userMixStreamModel.defaultValue = 0.0;
    //userMainStream_userMixStreamModel.titleAppose = AUILiveRecordPushString(@"user_mix_stream");
   // userMainStream_userMixStreamModel.defaultValueAppose = 0.0;
    //userMainStream_userMixStreamModel.reuseId = AlivcLiveParamModelReuseCellSwitch;
    userMainStream_userMixStreamModel.switchBlock = ^(int index, BOOL open) {
        if (index == 0) {
            self.isUserMainStream = open?true:false;
        }
        //else {
        //    self.isUserMixStream = open?true:false;
        //}
    };
    
    AlivcLiveParamModel *asyncModel = [[AlivcLiveParamModel alloc] init];
    asyncModel.title = AUILiveCommonString(@"异步接口");
    asyncModel.reuseId = AlivcLiveParamModelReuseCellSwitch;
    asyncModel.defaultValue = 1.0;
    asyncModel.switchBlock = ^(int index, BOOL open) {
        if (index == 0) {
            self.isUseAsync = open;
        }
    };
    
    AlivcLiveParamModel *watermarkModel = [[AlivcLiveParamModel alloc] init];
    watermarkModel.title = AUILiveCommonString(@"开启水印");
    watermarkModel.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    watermarkModel.defaultValue = 0;
    watermarkModel.infoText = AUILiveCommonString(@"水印设置");
    watermarkModel.switchBlock = ^(int index, BOOL open) {
        self.isUseWatermark = open;
    };
    watermarkModel.switchButtonBlock = ^(){
        //[self.view addSubview:self.waterSettingView];
    };
    
    AlivcLiveParamModel *videoOnly_audioHardwareEncodeModel = [[AlivcLiveParamModel alloc] init];
    videoOnly_audioHardwareEncodeModel.title = AUILiveCommonString(@"纯视频");
    videoOnly_audioHardwareEncodeModel.defaultValue = 0;
    videoOnly_audioHardwareEncodeModel.titleAppose = AUILiveCommonString(@"音频硬编码");
    videoOnly_audioHardwareEncodeModel.defaultValueAppose = 1.0;
    
    videoOnly_audioHardwareEncodeModel.reuseId = AlivcLiveParamModelReuseCellSwitch;
    videoOnly_audioHardwareEncodeModel.switchBlock = ^(int index, BOOL open) {
        if (index == 0) {
            self.pushConfig.videoOnly = open?true:false;
        } else {
            self.pushConfig.audioEncoderMode = open?AlivcLivePushAudioEncoderModeHard:AlivcLivePushAudioEncoderModeSoft;
        }
    };
    
    AlivcLiveParamModel *backgroundImage_networkWeakImageModel = [[AlivcLiveParamModel alloc] init];
    backgroundImage_networkWeakImageModel.title = AUILiveCommonString(@"暂停图片");
    backgroundImage_networkWeakImageModel.defaultValue = 1.0;
    backgroundImage_networkWeakImageModel.titleAppose = AUILiveCommonString(@"网络差图片");
    backgroundImage_networkWeakImageModel.defaultValueAppose = 1.0;
    
    backgroundImage_networkWeakImageModel.reuseId = AlivcLiveParamModelReuseCellSwitch;
    backgroundImage_networkWeakImageModel.switchBlock = ^(int index, BOOL open) {
        if (index == 0) {
            
            // 设置占位图片
            if(open) {
                if(self.pushConfig.orientation == AlivcLivePushOrientationPortrait) {
                    self.pushConfig.pauseImg = AUILiveCommonImage(@"background_push.png");
                } else{
                    self.pushConfig.pauseImg = AUILiveCommonImage(@"background_push_land.png");
                }
            }else {
                self.pushConfig.pauseImg = nil;
            }
            
        } else {
            if(open) {
                if(self.pushConfig.orientation == AlivcLivePushOrientationPortrait) {
                    self.pushConfig.networkPoorImg = AUILiveCommonImage(@"poor_network.png");
                } else{
                    self.pushConfig.networkPoorImg = AUILiveCommonImage(@"poor_network_land.png");
                }
            }else {
                self.pushConfig.networkPoorImg = nil;
            }
        }
    };
    
    AlivcLiveParamModel *qualityModeModel = [[AlivcLiveParamModel alloc] init];
    qualityModeModel.title = AUILiveCommonString(@"码率模式");
    qualityModeModel.segmentTitleArray = @[AUILiveCommonString(@"清晰度优先"),AUILiveCommonString(@"流畅度优先"),AUILiveCommonString(@"自定义")];
    qualityModeModel.defaultValue = 0;
    qualityModeModel.reuseId = AlivcLiveParamModelReuseCellSegmentAtRecord;
    qualityModeModel.segmentBlock = ^(int value) {
        self.pushConfig.qualityMode = value;
        [self updateBitrateAndFPSCell];
    };
    
    AlivcLiveParamModel *authTimeModel = [[AlivcLiveParamModel alloc] init];
    authTimeModel.title = AUILiveRecordPushString(@"AuthTime");
    authTimeModel.infoText = @"ms";
    authTimeModel.reuseId = AlivcLiveParamModelReuseCellInput;
    authTimeModel.stringBlock = ^(NSString *message) {
        self.authDuration = message;
    };
    
    AlivcLiveParamModel *authKeyModel = [[AlivcLiveParamModel alloc] init];
    authKeyModel.title = AUILiveRecordPushString(@"AuthKey");
    authKeyModel.infoText = @"";
    authKeyModel.reuseId = AlivcLiveParamModelReuseCellInput;
    authKeyModel.stringBlock = ^(NSString *message) {
        self.authKey = message;
    };
    
    AlivcLiveParamModel *audio_videoEncodeModeModel = [[AlivcLiveParamModel alloc] init];
    audio_videoEncodeModeModel.title = AUILiveCommonString(@"视频硬编码");
    audio_videoEncodeModeModel.defaultValue = 1.0;
    audio_videoEncodeModeModel.titleAppose = AUILiveCommonString(@"音频硬编码");
    audio_videoEncodeModeModel.defaultValueAppose = 1.0;
    audio_videoEncodeModeModel.reuseId = AlivcLiveParamModelReuseCellSwitch;
    audio_videoEncodeModeModel.switchBlock = ^(int index, BOOL open) {
        if (index == 0) {
            self.pushConfig.videoEncoderMode = open?AlivcLivePushVideoEncoderModeHard:AlivcLivePushVideoEncoderModeSoft;
        } else {
            self.pushConfig.audioEncoderMode = open?AlivcLivePushAudioEncoderModeHard:AlivcLivePushAudioEncoderModeSoft;
            
        }
    };
    
    AlivcLiveParamModel *originResolutionModel = [[AlivcLiveParamModel alloc] init];
    originResolutionModel.title = AUILiveRecordPushString(@"原始分辨率");
    originResolutionModel.reuseId = AlivcLiveParamModelReuseCellSwitch;
    originResolutionModel.defaultValue = 0.0;
    originResolutionModel.switchBlock = ^(int index, BOOL open) {
        if (index == 0) {
            self.isUseOriginResolution = open;
        }
    };
    
    AlivcLiveParamModel *narrowbandHDModel = [[AlivcLiveParamModel alloc] init];
    narrowbandHDModel.title = AUILiveRecordPushString(@"窄带高清");
    narrowbandHDModel.defaultValue = 1.0;
    narrowbandHDModel.reuseId = AlivcLiveParamModelReuseCellSwitch;
    narrowbandHDModel.switchBlock = ^(int index, BOOL open) {
        self.pushConfig.enableNarrowbandAndHDForScreenPusher = open?true:false;
    };

    AlivcLiveParamModel *pauseModel = [[AlivcLiveParamModel alloc] init];
    pauseModel.title = AUILiveRecordPushString(@"暂停推流");
    pauseModel.defaultValue = 0.0;
    pauseModel.reuseId = AlivcLiveParamModelReuseCellSwitch;
    pauseModel.switchBlock = ^(int index, BOOL open) {
        if(open)
        {
            [self.livePusher pause];
        }
        else
        {
            [self.livePusher resume];
        }
    };

    self.dataArray = [NSMutableArray arrayWithObjects:resolutionTitleModel, resolutionModel, orientationModel, nil];
  
    // Demo 中pushConfig初始值设置
    // 默认支持背景图片和弱网图片推流
    self.pushConfig.pauseImg = AUILiveCommonImage(@"background_push.png");
    self.pushConfig.networkPoorImg = AUILiveCommonImage(@"poor_network.png");
}


- (void)updateBitrateAndFPSCell {
    
    int targetBitrate = 0;
    int minBitrate = 0;
    int initBitrate = 0;
    BOOL enable = NO;
    
    if (self.pushConfig.qualityMode == AlivcLivePushQualityModeFluencyFirst) {
        // 流畅度优先模式，bitrate 固定值不可修改
        enable = NO;
        switch (self.pushConfig.resolution) {
            case AlivcLivePushResolution180P:
                targetBitrate = 250;
                minBitrate = 80;
                initBitrate = 200;
                break;
            case AlivcLivePushResolution240P:
                targetBitrate = 350;
                minBitrate = 120;
                initBitrate = 300;
                break;
            case AlivcLivePushResolution360P:
                targetBitrate = 600;
                minBitrate = 200;
                initBitrate = 400;
                break;
            case AlivcLivePushResolution480P:
                targetBitrate = 800;
                minBitrate = 300;
                initBitrate = 600;
                break;
            case AlivcLivePushResolution540P:
                targetBitrate = 1000;
                minBitrate = 300;
                initBitrate = 800;
                break;
            case AlivcLivePushResolution720P:
                targetBitrate = 1200;
                minBitrate = 300;
                initBitrate = 1000;
                break;
            default:
                break;
        }
    }
    
    if (self.pushConfig.qualityMode == AlivcLivePushQualityModeResolutionFirst) {
        // 清晰度优先模式，bitrate 固定值不可修改
        enable = NO;
        switch (self.pushConfig.resolution) {
            case AlivcLivePushResolution180P:
                targetBitrate = 550;
                minBitrate = 120;
                initBitrate = 300;
                break;
            case AlivcLivePushResolution240P:
                targetBitrate = 750;
                minBitrate = 180;
                initBitrate = 450;
                break;
            case AlivcLivePushResolution360P:
                targetBitrate = 1000;
                minBitrate = 300;
                initBitrate = 600;
                break;
            case AlivcLivePushResolution480P:
                targetBitrate = 1200;
                minBitrate = 300;
                initBitrate = 800;
                break;
            case AlivcLivePushResolution540P:
                targetBitrate = 1400;
                minBitrate = 600;
                initBitrate = 1000;
                break;
            case AlivcLivePushResolution720P:
                targetBitrate = 2000;
                minBitrate = 600;
                initBitrate = 1500;
                break;
            default:
                break;
        }
    }
    
    if (self.pushConfig.qualityMode == AlivcLivePushQualityModeCustom) {
        // 自定义模式，bitrate 固定值可修改
        enable = YES;
        targetBitrate = self.pushConfig.targetVideoBitrate;
        minBitrate = self.pushConfig.minVideoBitrate;
        initBitrate = self.pushConfig.initialVideoBitrate;
    }
    
    AUILiveParamTableViewCell *targetCell = [self.paramTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    [targetCell updateDefaultValue:targetBitrate enable:enable];
    
    AUILiveParamTableViewCell *minCell = [self.paramTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    [minCell updateDefaultValue:minBitrate enable:enable];
    
    AUILiveParamTableViewCell *initCell = [self.paramTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
    [initCell updateDefaultValue:initBitrate enable:enable];
}

- (NSString *)getWatermarkPathWithIndex:(NSInteger)index {
    
    NSString *watermarkBundlePath = [[NSBundle bundleWithPath:[NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:@"AUILiveCameraPush.bundle/Theme/DarkMode"]] pathForResource:@"watermark" ofType:@"png"];
    
    return watermarkBundlePath;
}

#pragma mark - TableViewdelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AlivcLiveParamModel *model = self.dataArray[indexPath.row];
    if (model) {
        NSString *cellIdentifier = [NSString stringWithFormat:@"AlivcLivePushTableViewIdentifier%ld", (long)indexPath.row];
        AUILiveParamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[AUILiveParamTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            [cell configureCellModel:model];
        }
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlivcLiveParamModel *paramModel = self.dataArray[indexPath.row];
    if (nil == paramModel) {
        return 0;
    }
    return [paramModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellSliderHeader] ? AlivcSizeHeight(39) : AlivcSizeHeight(46);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (![self.waterSettingView isEditing]) {
        [self.waterSettingView removeFromSuperview];
    }
    [self.view endEditing:YES];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self.view endEditing:YES];
}


#pragma mark - Keyboard

- (void)addKeyboardNoti {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)keyboardWillShow:(NSNotification *)sender {
  
    if(!self.isKeyboardShow){
     
        //获取键盘的frame
        CGRect keyboardFrame = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        // 修改tableView frame
//        [UIView animateWithDuration:0 animations:^{
//            CGRect frame = self.paramTableView.frame;
//            frame.size.height = frame.size.height - keyboardFrame.size.height;
//            self.paramTableView.frame = frame;
//        }];
        
        self.isKeyboardShow = true;
    }
 
}


- (void)keyboardWillHide:(NSNotification *)sender {
  
    if(self.isKeyboardShow){
        self.paramTableView.frame = self.tableViewFrame;
        self.isKeyboardShow = false;
    }
  
}


#pragma mark - TO PublisherVC
- (void)publiherButtonAction:(UIButton *)sender {
 
    AVAuthorizationStatus audioStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];

    if (audioStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {

        }];
        return;
    }else if(audioStatus == AVAuthorizationStatusRestricted || audioStatus == AVAuthorizationStatusDenied){
        [AVToastView show:AUILiveRecordPushString(@"当前没有麦克风权限，请在设置中打开麦克风权限") view:self.view position:AVToastViewPositionMid];
        return;
    }
    
    if(!_isPushing) {
        NSString *pushURLString = self.publisherURLTextField.text;
        if (!pushURLString || pushURLString.length == 0) {
            [AVToastView show:AUILiveCommonString(@"请输入推流地址") view:self.view position:AVToastViewPositionMid];
            return;
        }
        
        self.pushUrl = pushURLString;
        
        NSInteger resolution = self.pushConfig.resolution;
        
        if(self.isUseOriginResolution){
            resolution = AlivcLivePushResolutionPassThrough;
        }

        [self startLivePush];
        
        
        
    }else {
        
        [self stopLivePush];
        
    }
    
}

- (void)registerSDK {
    
    [AlivcLiveBase setObserver:self];
    NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    [AlivcLiveBase setLogPath:cacheDirectory maxPartFileSizeInKB:100*1024*1024];
    [AlivcLiveBase registerSDK];
}

- (void)startLivePush
{
    self.pushConfig.externMainStream = true;
    self.pushConfig.externVideoFormat = AlivcLivePushVideoFormatYUV420P;
    self.pushConfig.audioSampleRate = 44100;
    self.pushConfig.audioChannel = 2;
    self.pushConfig.audioFromExternal = false;
    self.pushConfig.videoEncoderMode = AlivcLivePushVideoEncoderModeSoft;
    self.pushConfig.qualityMode = AlivcLivePushQualityModeCustom;
    self.pushConfig.targetVideoBitrate = 2500;
    self.pushConfig.minVideoBitrate = 2000;
    self.pushConfig.initialVideoBitrate = 2000;
    //self.pushConfig.orientation = AlivcLivePushOrientationLandscapeRight;
    _livePusher = [[AlivcLivePusher alloc] initWithConfig:self.pushConfig];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
                      
    NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    [self.livePusher setLogPath:cacheDirectory maxPartFileSizeInKB:1024*1024];
    
    
    [self.livePusher setLogLevel:(AlivcLivePushLogLevelDebug)];
    
    [_livePusher setInfoDelegate:self];
    [_livePusher startScreenCapture:kAPPGROUP];
    //设置推流地址
    [_livePusher startPushWithURL:self.pushUrl];
    
}

- (void)stopLivePush
{
    [_livePusher stopPush];
    [AVToastView show:AUILiveRecordPushString(@"录屏推流已停止") view:self.view position:AVToastViewPositionMid];
}

- (NSString *)dictionary2JsonString:(NSDictionary *)dict
{
    if ([NSJSONSerialization isValidJSONObject:dict])
    {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
        NSString* jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return jsonString;
    }
    return nil;
}

#pragma mark - AlivcLiveBaseObserver
- (void)onLicenceCheck:(AlivcLiveLicenseCheckResultCode)result Reason:(NSString *)reason
{
    NSLog(@"LicenceCheck %ld, reason %@", (long)result, reason);
    if(result != AlivcLiveLicenseCheckResultCodeSuccess)
    {
        NSString *showMessage = [NSString stringWithFormat:@"License Error: code:%ld message:%@", (long)result, reason];

        dispatch_async(dispatch_get_main_queue(), ^{
            [AVAlertController showWithTitle:AUILiveRecordPushString(@"AlivcLivePusher License Error") message:showMessage needCancel:NO onCompleted:nil];
        });
    }
}

#pragma mark - TO QRCodeVC
- (void)QRCodeButtonAction:(UIButton *)sender {
    
    [self.view endEditing:YES];
    AUILiveQRCodeViewController *QRController = [[AUILiveQRCodeViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    QRController.backValueBlock = ^(BOOL scaned, NSString *sweepString) {
        if (scaned && sweepString) {
            weakSelf.publisherURLTextField.text = sweepString;
        }
    };
    [self.navigationController pushViewController:QRController animated:YES];
}

/**
 推流开始回调
 
 @param pusher 推流AlivcLivePusher
 */
- (void)onPushStarted:(AlivcLivePusher *)pusher
{
    self.isPushing = YES;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.publisherButton setTitle:AUILiveCommonString(@"停止推流") forState:(UIControlStateNormal)];
        strongSelf.publisherButton.backgroundColor = AUILiveRecordPushColor(@"ir_button_push");
    });
    
}


/**
 推流停止回调
 
 @param pusher 推流AlivcLivePusher
 */
- (void)onPushStoped:(AlivcLivePusher *)pusher
{
    self.isPushing = NO;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.livePusher destory];
        strongSelf.livePusher = nil;
        [strongSelf.publisherButton setTitle:AUILiveCommonString(@"开始推流") forState:(UIControlStateNormal)];
        strongSelf.publisherButton.backgroundColor = AUIFoundationColor(@"colourful_ic_strong");
    });
}

- (void)touchAction {
    [self.view.window endEditing:YES];
}

@end

