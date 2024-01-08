//
//  AUILiveInteractiveParamConfigViewController.m
//  AlivcLivePusherDemo
//
//  Created by ISS013602000846 on 2022/8/24.
//  Copyright © 2022 TripleL. All rights reserved.
//

#import "AUILiveInteractiveParamConfigViewController.h"
#import "AlivcLiveParamModel.h"
#import "AUILiveParamTableViewCell.h"
#import "AUILiveInteractiveParamManager.h"

@interface AUILiveInteractiveParamConfigViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *settingButton;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) AUILiveInteractiveParamManager *manager;
@property (nonatomic, assign) AlivcLivePushResolution resolution_temp;
@property (nonatomic, assign) AlivcLivePushVideoEncoderMode videoEncoderMode_temp;
@property (nonatomic, assign) AlivcLivePushAudioEncoderMode audioEncoderMode_temp;
@property (nonatomic, assign) bool audioOnly_temp;
@property (nonatomic, assign) AlivcLivePushVideoEncodeGOP videoEncodeGop_temp;
@property (nonatomic, assign) AlivcLivePushVideoEncoderModeHardCodec videoHardEncoderCode_temp;
@property (nonatomic, assign) AlivcLivePushFPS fps_temp;
@property (nonatomic, assign) BOOL isUserMainStream_temp;
@property (nonatomic, assign) BOOL beautyOn_temp;

@end

@implementation AUILiveInteractiveParamConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleView.text = AUILiveCommonString(@"参数设置");
    self.hiddenMenuButton = YES;
    
    [self setupContent];
    [self setupParamData];
}

- (void)setupContent {
    [self.contentView addSubview:self.tableView];
    [self.contentView addSubview:self.settingButton];
}

- (void)setupParamData {
    AlivcLiveParamModel *titlePlaceholderModel = [[AlivcLiveParamModel alloc] init];
    titlePlaceholderModel.reuseId = AlivcLiveParamModelReuseCellSliderHeader;
    
    AlivcLiveParamModel *titleResolutionModel = [[AlivcLiveParamModel alloc] init];
    titleResolutionModel.reuseId = AlivcLiveParamModelReuseCellSliderHeader;
    titleResolutionModel.title = AUILiveCommonString(@"分辨率");

    NSArray *resolutionArray = @[@"180P", @"240P", @"360P", @"480P", @"540P", @"720P", @"1080P"];
    self.resolution_temp = self.manager.resolution;
    AlivcLiveParamModel *resolutionModel = [[AlivcLiveParamModel alloc] init];
    resolutionModel.title = AUILiveCommonString(@"分辨率");
    resolutionModel.placeHolder = resolutionArray[self.manager.resolution];
    resolutionModel.infoText = resolutionArray[self.manager.resolution];
    resolutionModel.defaultValue = (CGFloat)self.manager.resolution / (CGFloat)resolutionArray.count;
    resolutionModel.reuseId = AlivcLiveParamModelReuseCellSlider;
    resolutionModel.sliderBlock = ^(int value){
        self.resolution_temp = value;
    };
    
    self.videoEncoderMode_temp = self.manager.videoEncoderMode;
    AlivcLiveParamModel *videoEncoderModeModel = [[AlivcLiveParamModel alloc] init];
    videoEncoderModeModel.title = AUILiveCommonString(@"视频硬编码");
    videoEncoderModeModel.defaultValue = !self.manager.videoEncoderMode;
    videoEncoderModeModel.defaultValueAppose = 1.0;
    videoEncoderModeModel.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    videoEncoderModeModel.switchBlock = ^(int index, BOOL open) {
        self.videoEncoderMode_temp = open?AlivcLivePushVideoEncoderModeHard:AlivcLivePushVideoEncoderModeSoft;
    };
    
    self.audioEncoderMode_temp = self.manager.audioEncoderMode;
    AlivcLiveParamModel *audioEncoderModeModel = [[AlivcLiveParamModel alloc] init];
    audioEncoderModeModel.title = AUILiveCommonString(@"音频硬编码");
    audioEncoderModeModel.defaultValue = !self.manager.audioEncoderMode;
    audioEncoderModeModel.defaultValueAppose = 1.0;
    audioEncoderModeModel.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    audioEncoderModeModel.switchBlock = ^(int index, BOOL open) {
        self.audioEncoderMode_temp = open?AlivcLivePushAudioEncoderModeHard:AlivcLivePushAudioEncoderModeSoft;
    };
    
    self.audioOnly_temp = self.manager.audioOnly;
    AlivcLiveParamModel *audiOnlyModeModel = [[AlivcLiveParamModel alloc] init];
    audiOnlyModeModel.title = AUILiveCommonString(@"纯音频");
    audiOnlyModeModel.defaultValue = self.manager.audioOnly;
    audiOnlyModeModel.defaultValueAppose = 1.0;
    audiOnlyModeModel.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    audiOnlyModeModel.switchBlock = ^(int index, BOOL open) {
        self.audioOnly_temp = open?true:false;
    };
    
    AlivcLiveParamModel *titleVideoEncodeGopModel = [[AlivcLiveParamModel alloc] init];
    titleVideoEncodeGopModel.reuseId = AlivcLiveParamModelReuseCellSliderHeader;
    titleVideoEncodeGopModel.title = AUILiveCommonString(@"关键帧间隔");
    
    self.videoEncodeGop_temp = self.manager.videoEncodeGop;
    AlivcLiveParamModel *videoEncodeGopModel = [[AlivcLiveParamModel alloc] init];
    videoEncodeGopModel.title = AUILiveCommonString(@"关键帧间隔");
    videoEncodeGopModel.defaultValue = self.manager.videoEncodeGop / 5.0;
    videoEncodeGopModel.infoText = [NSString stringWithFormat:@"%lds", (long)self.manager.videoEncodeGop];
    videoEncodeGopModel.placeHolder = @"2s";
    videoEncodeGopModel.reuseId = AlivcLiveParamModelReuseCellSlider;
    videoEncodeGopModel.sliderBlock = ^(int value) {
        self.videoEncodeGop_temp = value;
    };
    
    self.videoHardEncoderCode_temp = self.manager.videoHardEncoderCodec;
    AlivcLiveParamModel *videoHardEncodeCodecModel = [[AlivcLiveParamModel alloc] init];
    videoHardEncodeCodecModel.title = AUILiveCommonString(@"视频硬编Codec");
    videoHardEncodeCodecModel.pickerPanelTextArray = @[@"H264", @"H265"];
    videoHardEncodeCodecModel.defaultValue = 0;
    videoHardEncodeCodecModel.reuseId = AlivcLiveParamModelReuseCellPickerSelect;
    videoHardEncodeCodecModel.pickerSelectBlock = ^(int value) {
        self.videoHardEncoderCode_temp = (value == 1 ? AlivcLivePushVideoEncoderModeHardCodecHEVC : AlivcLivePushVideoEncoderModeHardCodecH264);
    };
    
    AlivcLiveParamModel *titlefpsModel = [[AlivcLiveParamModel alloc] init];
    titlefpsModel.reuseId = AlivcLiveParamModelReuseCellSliderHeader;
    titlefpsModel.title = AUILiveCommonString(@"采集帧率");
    
    NSArray *fpsArray = @[@"8",@"10",@"12",@"15",@"20",@"25",@"30"];
    self.fps_temp = self.manager.fps;
    NSString *fpsStr = [NSString stringWithFormat:@"%ld", self.manager.fps];
    AlivcLiveParamModel *fpsModel = [[AlivcLiveParamModel alloc] init];
    fpsModel.title = AUILiveCommonString(@"采集帧率");
    fpsModel.defaultValue = [fpsArray indexOfObject:fpsStr] / (float)fpsArray.count;
    fpsModel.infoText = fpsStr;
    fpsModel.placeHolder = fpsStr;
    fpsModel.infoUnit = @"fps";
    fpsModel.reuseId = AlivcLiveParamModelReuseCellSlider;
    fpsModel.sliderBlock = ^(int value) {
        self.fps_temp = value;
    };
    
    self.isUserMainStream_temp = self.manager.isUserMainStream;
    AlivcLiveParamModel *userMainStreamModel = [[AlivcLiveParamModel alloc] init];
    userMainStreamModel.title = AUILiveCommonString(@"外部音视频");
    userMainStreamModel.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    userMainStreamModel.defaultValue = self.manager.isUserMainStream;
    userMainStreamModel.switchBlock = ^(int index, BOOL open) {
        if (index == 0) {
            self.isUserMainStream_temp = open?true:false;
            if (open) {
                if ([AliveLiveDemoUtil haveExternalStreamResourceSavePath]) {
                    return;
                }
                
                AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:self.view animated:YES];
                loading.labelText = AUILiveCommonString(@"正在下载外部音视频资源中，请等待");

                [AliveLiveDemoUtil requestExternalStreamResourceWithCompletion:^(BOOL success, NSString * _Nonnull errMsg) {
                    [loading hideAnimated:YES];
                    if (!success) {
                        [AVToastView show:errMsg view:self.view position:AVToastViewPositionMid];
                        AUILiveParamTableViewCell *targetCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:10 inSection:0]];
                        [targetCell updateDefaultValue:0 enable:YES];
                        self.isUserMainStream_temp = NO;
                    } else {
                        [AVToastView show:AUILiveCommonString(@"下载外部音视频资源完成") view:self.view position:AVToastViewPositionMid];
                    }
                }];
            }
        }
    };
    
    self.beautyOn_temp = self.manager.beautyOn;
    AlivcLiveParamModel *beautyOnModel = [[AlivcLiveParamModel alloc] init];
    beautyOnModel.title = AUILiveCommonString(@"开启美颜");
    beautyOnModel.defaultValue = self.manager.beautyOn;
    beautyOnModel.defaultValueAppose = 1.0;
    beautyOnModel.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    beautyOnModel.switchBlock = ^(int index, BOOL open) {
            self.beautyOn_temp = open;
    };
    
    self.dataArray = @[titleResolutionModel, resolutionModel, titlePlaceholderModel, videoEncoderModeModel, audioEncoderModeModel, audiOnlyModeModel, titleVideoEncodeGopModel, videoEncodeGopModel, titlePlaceholderModel, videoHardEncodeCodecModel, titlefpsModel, fpsModel, userMainStreamModel, beautyOnModel];
}

- (void)clickSettingButton:(UIButton *)sender {
    self.manager.resolution = self.resolution_temp;
    self.manager.videoEncoderMode = self.videoEncoderMode_temp;
    self.manager.audioEncoderMode = self.audioEncoderMode_temp;
    self.manager.audioOnly = self.audioOnly_temp;
    self.manager.videoEncodeGop = self.videoEncodeGop_temp;
    self.manager.videoHardEncoderCodec = self.videoHardEncoderCode_temp;
    self.manager.fps = self.fps_temp;
    self.manager.isUserMainStream = self.isUserMainStream_temp;
    self.manager.beautyOn = self.beautyOn_temp;
    
    [self goBack];
    if (self.changeParam) {
        self.changeParam();
    }
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlivcLiveParamModel *model = self.dataArray[indexPath.row];
    NSString *cellIdentifier = [NSString stringWithFormat:@"AlivcLivePushTableViewIdentifier%ld", (long)indexPath.row];
    AUILiveParamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[AUILiveParamTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell configureCellModel:model];
    }
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlivcLiveParamModel *model = self.dataArray[indexPath.row];
    if ([model.reuseId isEqualToString:AlivcLiveParamModelReuseCellSliderHeader]) {
        return 40;
    } else {
        return 60;
    }
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

#pragma mark -- lazy load
- (UITableView *)tableView {
    if (nil == _tableView) {
        CGRect frame = CGRectMake(0, 0, self.contentView.av_width, self.settingButton.av_top - 20);
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [_tableView setBackgroundColor:AUIFoundationColor(@"bg_weak")];
        [_tableView setShowsVerticalScrollIndicator:NO];
    }
    return _tableView;
}

- (UIButton *)settingButton {
    if (!_settingButton) {
        _settingButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        _settingButton.frame = CGRectMake(20, self.contentView.av_height - AVSafeBottom - 8 - 48, self.contentView.av_width - 20 * 2, 48);
        [_settingButton setBackgroundColor:AUIFoundationColor(@"colourful_fill_strong")];
        [_settingButton setTitle:AUILiveCommonString(@"确定") forState:UIControlStateNormal];
        [_settingButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
        [_settingButton.titleLabel setFont:AVGetRegularFont(18)];
        [_settingButton.layer setMasksToBounds:YES];
        [_settingButton.layer setCornerRadius:24];
        [_settingButton addTarget:self action:@selector(clickSettingButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _settingButton;
}

- (AUILiveInteractiveParamManager *)manager {
    if (!_manager) {
        _manager = [AUILiveInteractiveParamManager manager];
    }
    return _manager;
}

@end
