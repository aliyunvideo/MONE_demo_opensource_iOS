//
//  AlivcPushConfigViewController.m
//  AlivcLiveCaptureDev
//
//  Created by lyz on 2017/9/20.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import "AUILivePushConfigViewController.h"
#import "AUILiveQRCodeViewController.h"
#import "AUILiveCameraPushViewController.h"
#import "AlivcLiveParamModel.h"
#import "AUILiveParamTableViewCell.h"
#import "AUILiveWatermarkSettingView.h"
#import "AUILiveCheckQueenManager.h"

#define RTMP_URL_PREFIX @"rtmp://"
#define ARTC_URL_PREFIX @"artc://"

#define TOP_TAB_BAR_TITLE_PUSH_CONFIG   AUILiveCameraPushString(@"推流参数")
#define TOP_TAB_BAR_TITLE_PUSH_FEATURE  AUILiveCameraPushString(@"推流功能")

@interface AUILivePushConfigViewController () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) UITextField *pushUrlTextField;
@property(nonatomic, strong) UIButton *pushBackButton;
@property(nonatomic, strong) UIButton *pushUrlQRCodeButton;
@property(nonatomic, strong) UIButton *pushStartButton;
@property(nonatomic, strong) UITableView *pushContentTableView;
@property(nonatomic, strong) UIView *pushTopTabBarSegmentLineView;
@property(nonatomic, strong) AUILiveWatermarkSettingDrawView *waterSettingView;

@property(nonatomic, strong) AUILiveWatermarkSettingDrawView *watermarkSettingView;

@property (nonatomic, copy) NSString *authDuration; // 测试鉴权，过期时长
@property (nonatomic, copy) NSString *authKey; // 测试鉴权，账号key

@property(nonatomic, strong) AlivcLivePushConfig *pushConfig;

@property(nonatomic, strong) NSArray<AlivcLiveParamModel *> *pushConfigArray;
@property(nonatomic, strong) NSArray<AlivcLiveParamModel *> *pushFeatureArray;

@property(nonatomic, assign) NSInteger pushTableHeadTagIndex;
@property(nonatomic, assign) BOOL showAdvancedSetting;

@property(nonatomic, assign) BOOL isUseWatermark;
@property(nonatomic, assign) BOOL isBeautyOn;
@property(nonatomic, assign) BOOL isUseExternalStream;
@property(nonatomic, assign) BOOL isUseAsync;

@property(nonatomic, assign) BOOL isKeyboardShow;
@property(nonatomic, assign) CGRect tableViewFrame;


@end

@implementation AUILivePushConfigViewController

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViewController];
    [self setupData];
    [self setupSubviews];
    [self addNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.pushConfig) {
        NSString *watermarkBundlePath = [[NSBundle bundleWithPath:[NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:@"AUILiveCameraPush.bundle/Theme/DarkMode"]] pathForResource:@"watermark" ofType:@"png"];
        [self.pushConfig removeWatermarkWithPath:watermarkBundlePath];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    [self removeNotifications];
}

#pragma mark - view components

- (void)setupViewController {
}

- (void)setupData {
    self.isUseWatermark = NO;
    self.isBeautyOn = YES;
    self.isUseExternalStream = NO;
    self.isUseAsync = YES;

    self.pushConfig = [[AlivcLivePushConfig alloc] init];
    self.pushConfig.pauseImg = AUILiveCommonImage(@"background_push.png");
    self.pushConfig.networkPoorImg = AUILiveCommonImage(@"poor_network.png");

    self.pushConfigArray = [self getPushConfigArray];
    self.pushFeatureArray = [self getPushFeatureArray];
}

- (void)setupSubviews {
    [self setupHeaderViews];
    [self setupContentViews];
    [self.contentView addSubview:self.pushStartButton];
}

- (void)setupHeaderViews {
    UIView *inputContentView = [[UIView alloc] initWithFrame:CGRectMake(self.backButton.av_right + 18, 0, self.headerView.av_width - self.backButton.av_right - 18 - 24, 32)];
    inputContentView.av_centerY = self.backButton.av_centerY;
    inputContentView.backgroundColor = AUIFoundationColor(@"fill_weak");
    [self.headerView addSubview:inputContentView];
    
    self.pushUrlQRCodeButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.pushUrlQRCodeButton.frame = CGRectMake(12, (inputContentView.av_height - 30)/2.0, 30, 30);
    [self.pushUrlQRCodeButton setImage:AUILiveCommonImage(@"ic_scan") forState:(UIControlStateNormal)];
    self.pushUrlQRCodeButton.layer.masksToBounds = YES;
    self.pushUrlQRCodeButton.layer.cornerRadius = 10;
    [self.pushUrlQRCodeButton addTarget:self action:@selector(clickPushUrlQRCodeButton:) forControlEvents:(UIControlEventTouchUpInside)];
    [inputContentView addSubview:self.pushUrlQRCodeButton];
    
    self.pushUrlTextField = [[UITextField alloc] init];
    self.pushUrlTextField.frame = CGRectMake(self.pushUrlQRCodeButton.av_right + 8, (inputContentView.av_height - 30)/2.0, inputContentView.av_width - self.pushUrlQRCodeButton.av_right - 8, 30);
    self.pushUrlTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:AUILiveCommonString(@"请输入推流url") attributes:@{
        NSFontAttributeName: AVGetRegularFont(14),
        NSForegroundColorAttributeName: AUIFoundationColor(@"text_ultraweak"),
    }];
    self.pushUrlTextField.font = AVGetRegularFont(14);
    self.pushUrlTextField.textColor = AUIFoundationColor(@"text_strong");
    self.pushUrlTextField.clearsOnBeginEditing = NO;
    self.pushUrlTextField.backgroundColor = [UIColor clearColor];
    self.pushUrlTextField.clearButtonMode = UITextFieldViewModeAlways;
    [inputContentView addSubview:self.pushUrlTextField];
}

- (void)setupContentViews {
    [self.contentView addSubview:self.pushContentTableView];
    [self.contentView addSubview:self.pushTopTabBarSegmentLineView];
    [self reloadTableView];

    self.tableViewFrame = self.pushContentTableView.frame;
}

#pragma mark - Logic

- (void)reloadTableView {
    dispatch_async(dispatch_get_main_queue(), ^{
        // reload segment buttons
        for (UIButton *btn in self.pushTopTabBarSegmentLineView.subviews) {
            BOOL isBtnSelected = (self.pushTableHeadTagIndex == 0 && [btn.currentTitle isEqualToString:TOP_TAB_BAR_TITLE_PUSH_CONFIG])
                    || (self.pushTableHeadTagIndex == 1 && [btn.currentTitle isEqualToString:TOP_TAB_BAR_TITLE_PUSH_FEATURE]);
            [btn.titleLabel setFont:isBtnSelected ? AVGetMediumFont(14) : AVGetRegularFont(14)];
        }
        // reload tableview
        [self.pushContentTableView reloadData];
        // reload specific cells
        [self updateBitrateAndFPSCell];
    });
}

- (void)updateBitrateAndFPSCell {
    
    BOOL haveInteractiveMode = NO;
#ifdef ALIVC_LIVE_INTERACTIVE_MODE
    haveInteractiveMode = YES;
#endif
    
    if (self.pushTableHeadTagIndex == 0) {
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
                case AlivcLivePushResolution1080P:
                    targetBitrate = 2200;
                    minBitrate = 1200;
                    initBitrate = 1500;
                    break;
                default:
                    break;
            }
        } else if (self.pushConfig.qualityMode == AlivcLivePushQualityModeResolutionFirst) {
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
                case AlivcLivePushResolution1080P:
                    targetBitrate = 2500;
                    minBitrate = 1200;
                    initBitrate = 1800;
                    break;
                default:
                    break;
            }
        } else if (self.pushConfig.qualityMode == AlivcLivePushQualityModeCustom) {
            // 自定义模式，bitrate 固定值可修改
            enable = YES;
            targetBitrate = self.pushConfig.targetVideoBitrate;
            minBitrate = self.pushConfig.minVideoBitrate;
            initBitrate = self.pushConfig.initialVideoBitrate;
        }
        
        AUILiveParamTableViewCell *targetCell = [self.pushContentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:haveInteractiveMode ? 9 : 8 inSection:0]];
        [targetCell updateDefaultValue:targetBitrate enable:enable];

        AUILiveParamTableViewCell *minCell = [self.pushContentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:haveInteractiveMode ? 10 : 9 inSection:0]];
        [minCell updateDefaultValue:minBitrate enable:enable];

        AUILiveParamTableViewCell *initCell = [self.pushContentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:haveInteractiveMode ? 11 : 10 inSection:0]];
        [initCell updateDefaultValue:initBitrate enable:enable];
    } else {
        AUILiveParamTableViewCell *mirrorDescCell = [self.pushContentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:haveInteractiveMode ? 9 : 8 inSection:0]];
        [mirrorDescCell updateEnable:YES];

        AUILiveParamTableViewCell *pushMirrorCell = [self.pushContentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:haveInteractiveMode ? 10 : 9 inSection:0]];
        [pushMirrorCell updateEnable:YES];

        AUILiveParamTableViewCell *previewMirrorCell = [self.pushContentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:haveInteractiveMode ? 11 : 10 inSection:0]];
        [previewMirrorCell updateEnable:YES];
    }
}

- (void)showAndHiddenVideoCodecVideo:(BOOL)isHidden
{
    if (self.pushTableHeadTagIndex == 0) {
        BOOL haveInteractiveMode = NO;
    #ifdef ALIVC_LIVE_INTERACTIVE_MODE
        haveInteractiveMode = YES;
    #endif
        
        AUILiveParamTableViewCell *targetCell = [self.pushContentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:haveInteractiveMode ? 26 : 25 inSection:0]];
        if(isHidden)
        {
            [targetCell setHidden:YES];
        }
        else
        {
            [targetCell setHidden:NO];
        }
        
        targetCell = [self.pushContentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:haveInteractiveMode ? 27 : 26 inSection:0]];
        if(isHidden)
        {
            [targetCell setHidden:YES];
        }
        else
        {
            [targetCell setHidden:NO];
        }
    }
}

#pragma mark - lazy load

- (UIButton *)pushStartButton {
    if (nil == _pushStartButton) {
        _pushStartButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [_pushStartButton setFrame:CGRectMake(20, self.contentView.av_height - 48 - AVSafeBottom - 8, AlivcScreenWidth - 40, 48)];
        [_pushStartButton setBackgroundColor:AUIFoundationColor(@"colourful_fill_strong")];
        [_pushStartButton setTitle:AUILiveCommonString(@"开始推流") forState:UIControlStateNormal];
        [_pushStartButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
        [_pushStartButton.titleLabel setFont:AVGetRegularFont(18)];
        [_pushStartButton.layer setMasksToBounds:YES];
        [_pushStartButton.layer setCornerRadius:24];
        [_pushStartButton addTarget:self action:@selector(clickPushStartButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pushStartButton;
}

- (UIView *)pushTopTabBarSegmentLineView {
    if (nil == _pushTopTabBarSegmentLineView) {
        _pushTopTabBarSegmentLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, AlivcScreenWidth, AlivcSizeHeight(48))];
        _pushTopTabBarSegmentLineView.backgroundColor = AUIFoundationColor(@"bg_weak");

        for (NSInteger i = 0; i < 2; i++) {
            UIButton *segmentButton = [UIButton buttonWithType:UIButtonTypeCustom];
            segmentButton.frame = CGRectMake(i * AlivcScreenWidth / 2, 0, AlivcScreenWidth / 2, AlivcSizeHeight(48));
            [segmentButton setTitle:AUILiveCameraPushString((i == 0) ? TOP_TAB_BAR_TITLE_PUSH_CONFIG : TOP_TAB_BAR_TITLE_PUSH_FEATURE) forState:UIControlStateNormal];
            segmentButton.backgroundColor = [UIColor clearColor];
            [segmentButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
            [segmentButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateSelected];
            [segmentButton.titleLabel setFont:AVGetRegularFont(14)];
            [segmentButton addTarget:self action:@selector(clickPushTopTabBarButton:) forControlEvents:UIControlEventTouchUpInside];
            [segmentButton setSelected:(i == 0) ? YES : NO];
            [_pushTopTabBarSegmentLineView addSubview:segmentButton];
        }
    }
    return _pushTopTabBarSegmentLineView;
}

- (UITableView *)pushContentTableView {
    if (nil == _pushContentTableView) {
        CGRect frame = CGRectMake(0, self.pushTopTabBarSegmentLineView.av_bottom, AlivcScreenWidth, self.pushStartButton.av_top - self.pushTopTabBarSegmentLineView.av_bottom);
        _pushContentTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        [_pushContentTableView setDelegate:self];
        [_pushContentTableView setDataSource:self];
        [_pushContentTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [_pushContentTableView setBackgroundColor:AUIFoundationColor(@"bg_weak")];
        [_pushContentTableView setShowsVerticalScrollIndicator:NO];
    }
    return _pushContentTableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.pushTableHeadTagIndex == 0) {
        if (self.showAdvancedSetting) {
            if (self.pushConfig.videoEncoderMode != AlivcLivePushVideoEncoderModeHard) {
                return [self.pushConfigArray count] - 2;
            } else {
                return [self.pushConfigArray count] ;
            }
        } else {
            return [[self getPushBasicConfigArray] count];
        }
    } else {
        return [self.pushFeatureArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = (NSUInteger) indexPath.row;
    AlivcLiveParamModel *paramModel = (self.pushTableHeadTagIndex == 0) ? self.pushConfigArray[index] : self.pushFeatureArray[index];
    if (nil == paramModel) {
        return nil;
    }

    NSString *cellIdentifier = [NSString stringWithFormat:@"AlivcLivePushTableViewIdentifier%ld%ld", (long) indexPath.row, (long) self.pushTableHeadTagIndex];
    AUILiveParamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[AUILiveParamTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell configureCellModel:paramModel];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = (NSUInteger) indexPath.row;
    AlivcLiveParamModel *paramModel = (self.pushTableHeadTagIndex == 0) ? self.pushConfigArray[index] : self.pushFeatureArray[index];
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
    if (![self.watermarkSettingView isEditing]) {
        [self.watermarkSettingView removeFromSuperview];
    }
    [self.view endEditing:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (AUILiveWatermarkSettingDrawView *)waterSettingView {
    if (nil == _waterSettingView) {
        _waterSettingView = [[AUILiveWatermarkSettingDrawView alloc] initWithFrame:(CGRectMake(0, AlivcScreenHeight - AlivcSizeHeight(330), AlivcScreenWidth, AlivcSizeHeight(330)))];
    }
    return _waterSettingView;
}

#pragma mark - Click Actions

- (void)clickPushUrlQRCodeButton:(id)sender {
    [self.view endEditing:YES];

    AUILiveQRCodeViewController *QRCodeVC = [[AUILiveQRCodeViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    QRCodeVC.backValueBlock = ^(BOOL scaned, NSString *sweepString) {
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf && scaned && sweepString) {
            [strongSelf.pushUrlTextField setText:sweepString];
        }
    };
    [self.navigationController pushViewController:QRCodeVC animated:YES];
}

- (void)clickPushTopTabBarButton:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.pushTableHeadTagIndex = ([sender.currentTitle isEqualToString:TOP_TAB_BAR_TITLE_PUSH_CONFIG]) ? 0 : 1;
    [self reloadTableView];
}

- (void)clickPushStartButton:(id)sender {
    NSString *pushUrl = self.pushUrlTextField.text;

    if (nil == pushUrl || pushUrl.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:AUILiveCommonString(@"提示") message:AUILiveCommonString(@"请输入推流地址") delegate:nil cancelButtonTitle:AUILiveCommonString(@"确定") otherButtonTitles:nil];
        [alert show];
        return;
    }

    if (!([[pushUrl lowercaseString] hasPrefix:@"rtmp"] || [[pushUrl lowercaseString] hasPrefix:@"artc"])) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:AUILiveCommonString(@"提示") message:AUILiveCameraPushString(@"请输入有效推流地址") delegate:nil cancelButtonTitle:AUILiveCommonString(@"确定") otherButtonTitles:nil];
        [alert show];
        return;
    }

    if (nil == self.pushConfig) {
        return;
    }

    if (self.isUseWatermark) {
        for (int index = 0; index <= 1; index++) {
            AlivcWatermarkSettingStruct watermarkSetting = [self.waterSettingView getWatermarkSettingsWithCount:index];
            NSString *watermarkPath = [[NSBundle bundleWithPath:[NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:@"AUILiveCameraPush.bundle/Theme/DarkMode"]] pathForResource:@"watermark" ofType:@"png"];
            [self.pushConfig addWatermarkWithPath:watermarkPath watermarkCoordX:watermarkSetting.watermarkX
                                  watermarkCoordY:watermarkSetting.watermarkY
                                   watermarkWidth:watermarkSetting.watermarkWidth];
        }
    } else {
        NSArray *watermarkArr = [self.pushConfig getAllWatermarks];
        for (NSDictionary *watermark in watermarkArr) {
            [self.pushConfig removeWatermarkWithPath:watermark[@"watermarkPath"]];
        }
    }

    if (self.pushConfig.minFps > self.pushConfig.fps) {
        [AliveLiveDemoUtil showAlertWithTitle:AUILiveCameraPushString(@"最小帧率不能大于视频帧率") message:@"" confirmBlock:nil cancelBlock:nil];
        return;
    }
    
    [AUILiveCheckQueenManager checkWithCurrentView:self.view completed:^(BOOL completed) {
        if (completed) {
            AUILiveCameraPushViewController *pusherVC = [[AUILiveCameraPushViewController alloc] init];
            pusherVC.pushURL = pushUrl;
            pusherVC.pushConfig = self.pushConfig;
            pusherVC.beautyOn = self.isBeautyOn;
            pusherVC.isUseAsyncInterface = self.isUseAsync;
            pusherVC.isUserMainStream = self.isUseExternalStream;
            pusherVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:pusherVC animated:YES completion:nil];
        }
    }];
}

#pragma mark - Notifications

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowAction:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideAction:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShowAction:(NSNotification *)sender {
    if (!self.isKeyboardShow) {
        CGRect keyboardFrame = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        [UIView animateWithDuration:0 animations:^{
            CGRect frame = self.pushContentTableView.frame;
            frame.size.height = frame.size.height - keyboardFrame.size.height;
            self.pushContentTableView.frame = frame;
        }];
        self.isKeyboardShow = YES;
    }
}

- (void)keyboardWillHideAction:(NSNotification *)sender {
    if (self.isKeyboardShow) {
        self.pushContentTableView.frame = self.tableViewFrame;
        self.isKeyboardShow = NO;
    }
}

#pragma mark - Data Source

- (NSArray *)getPushConfigArray {
    return [[self getPushBasicConfigArray] arrayByAddingObjectsFromArray:[self getPushAdvancedConfigArray]];
}

- (NSArray *)getPushBasicConfigArray {
    AlivcLiveParamModel *blankSegmentModel = [[AlivcLiveParamModel alloc] init];
    blankSegmentModel.reuseId = AlivcLiveParamModelReuseCellSliderHeader;
    blankSegmentModel.title = @"";
    
#ifdef ALIVC_LIVE_INTERACTIVE_MODE
    AlivcLiveParamModel *livePushModeModel = [[AlivcLiveParamModel alloc] init];
    livePushModeModel.title = AUILiveCameraPushString(@"互动模式");
    livePushModeModel.defaultValue = 0;
    livePushModeModel.defaultValueAppose = 0;
    livePushModeModel.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    livePushModeModel.switchBlock = ^(int index, BOOL open) {
        self.pushConfig.livePushMode = open ? AlivcLivePushInteractiveMode : AlivcLivePushBasicMode;
    };
#endif

    AlivcLiveParamModel *titleResolutionModel = [[AlivcLiveParamModel alloc] init];
    titleResolutionModel.reuseId = AlivcLiveParamModelReuseCellSliderHeader;
    titleResolutionModel.title = AUILiveCommonString(@"分辨率");

    AlivcLiveParamModel *resolutionModel = [[AlivcLiveParamModel alloc] init];
    resolutionModel.title = AUILiveCommonString(@"分辨率");
    resolutionModel.placeHolder = @"540P";
    resolutionModel.infoText = @"540P";
    resolutionModel.defaultValue = 4.0 / 7.0;
    resolutionModel.reuseId = AlivcLiveParamModelReuseCellSlider;
    resolutionModel.sliderBlock = ^(int value) {
        self.pushConfig.resolution = (AlivcLivePushResolution) value;
        [self updateBitrateAndFPSCell];
    };
    
    AlivcLiveParamModel *autoBitrate = [[AlivcLiveParamModel alloc] init];
    autoBitrate.title = AUILiveCommonString(@"码率自适应");
    autoBitrate.defaultValue = 1.0;
    autoBitrate.defaultValueAppose = 0;
    autoBitrate.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    autoBitrate.switchBlock = ^(int index, BOOL open) {
        self.pushConfig.enableAutoBitrate = open?true:false;
        /*
        if (index == 0) {
            self.pushConfig.enableAutoBitrate = open?true:false;
        } else {
            self.pushConfig.enableAutoResolution = open?true:false;
        }
         */
    };

    AlivcLiveParamModel *pushStreamModel = [[AlivcLiveParamModel alloc] init];
    pushStreamModel.title = AUILiveCameraPushString(@"分辨率自适应");
    pushStreamModel.defaultValue = 0;
    pushStreamModel.defaultValueAppose = 0;
    pushStreamModel.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    pushStreamModel.switchBlock = ^(int index, BOOL open) {
        self.pushConfig.enableAutoResolution = open ? true : false;
    };

    AlivcLiveParamModel *pushStreamDescModel = [[AlivcLiveParamModel alloc] init];
    pushStreamDescModel.title = AUILiveCameraPushString(@"分辨率自适应需要开启码率自适应，详细请参考Api文档");
    pushStreamDescModel.reuseId = AlivcLiveParamModelReuseCellSegmentWhite;

    AlivcLiveParamModel *advancedSettingModel = [[AlivcLiveParamModel alloc] init];
    advancedSettingModel.title = AUILiveCameraPushString(@"高级设置");
    advancedSettingModel.defaultValue = 0;
    advancedSettingModel.defaultValueAppose = 0;
    advancedSettingModel.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    advancedSettingModel.switchBlock = ^(int index, BOOL open) {
        self.showAdvancedSetting = open;
        [self reloadTableView];
        [self updateBitrateAndFPSCell];
    };

#ifdef ALIVC_LIVE_INTERACTIVE_MODE
    return @[livePushModeModel, titleResolutionModel, resolutionModel, autoBitrate, pushStreamModel, pushStreamDescModel, advancedSettingModel];
#else
    return @[titleResolutionModel, resolutionModel, autoBitrate, pushStreamModel, pushStreamDescModel, advancedSettingModel];
#endif
}

- (NSArray *)getPushAdvancedConfigArray {
    AlivcLiveParamModel *blankSegmentModel = [[AlivcLiveParamModel alloc] init];
    blankSegmentModel.reuseId = AlivcLiveParamModelReuseCellSliderHeader;
    blankSegmentModel.title = @"";

    AlivcLiveParamModel *qualityModeModel = [[AlivcLiveParamModel alloc] init];
    qualityModeModel.title = AUILiveCommonString(@"码率模式");
    qualityModeModel.pickerPanelTextArray = @[AUILiveCommonString(@"清晰度优先"), AUILiveCommonString(@"流畅度优先"), AUILiveCommonString(@"自定义")];
    qualityModeModel.defaultValue = 0;
    qualityModeModel.reuseId = AlivcLiveParamModelReuseCellPickerSelect;
    qualityModeModel.pickerSelectBlock = ^(int value) {
        self.pushConfig.qualityMode = (AlivcLivePushQualityMode) value;
        [self updateBitrateAndFPSCell];
    };

    AlivcLiveParamModel *qualityModeDescModel = [[AlivcLiveParamModel alloc] init];
    qualityModeDescModel.title = AUILiveCameraPushString(@"视频码率和帧率仅在自定义模式下可以调整");
    qualityModeDescModel.reuseId = AlivcLiveParamModelReuseCellSegmentWhite;

    AlivcLiveParamModel *targetBitrateModel = [[AlivcLiveParamModel alloc] init];
    targetBitrateModel.title = AUILiveCommonString(@"视频目标码率");
    targetBitrateModel.defaultValue = 800;
    targetBitrateModel.infoText = @"/Kbps";
    targetBitrateModel.reuseId = AlivcLiveParamModelReuseCellInput;
    targetBitrateModel.valueBlock = ^(int value) {
        self.pushConfig.targetVideoBitrate = value;
    };

    AlivcLiveParamModel *minBitrateModel = [[AlivcLiveParamModel alloc] init];
    minBitrateModel.title = AUILiveCommonString(@"视频最小码率");
    minBitrateModel.defaultValue = 200;
    minBitrateModel.infoText = @"/Kbps";
    minBitrateModel.reuseId = AlivcLiveParamModelReuseCellInput;
    minBitrateModel.valueBlock = ^(int value) {
        self.pushConfig.minVideoBitrate = value;
    };

    AlivcLiveParamModel *initBitrateModel = [[AlivcLiveParamModel alloc] init];
    initBitrateModel.title = AUILiveCommonString(@"视频初始码率");
    initBitrateModel.defaultValue = 800;
    initBitrateModel.infoText = @"/Kbps";
    initBitrateModel.reuseId = AlivcLiveParamModelReuseCellInput;
    initBitrateModel.valueBlock = ^(int value) {
        self.pushConfig.initialVideoBitrate = value;
    };

    AlivcLiveParamModel *audioBitrateModel = [[AlivcLiveParamModel alloc] init];
    audioBitrateModel.title = AUILiveCommonString(@"音频码率");
    audioBitrateModel.defaultValue = 64;
    audioBitrateModel.infoText = @"/Kbps";
    audioBitrateModel.infoColor = AUIFoundationColor(@"text_strong");
    audioBitrateModel.reuseId = AlivcLiveParamModelReuseCellInput;
    audioBitrateModel.valueBlock = ^(int value) {
        self.pushConfig.audioBitrate = value;
    };
    
    AlivcLiveParamModel *minFPSDescModel = [[AlivcLiveParamModel alloc] init];
    minFPSDescModel.reuseId = AlivcLiveParamModelReuseCellSliderHeader;
    minFPSDescModel.title = AUILiveCommonString(@"最小帧率");

    AlivcLiveParamModel *minFPSModel = [[AlivcLiveParamModel alloc] init];
    minFPSModel.title = AUILiveCommonString(@"最小帧率");
    minFPSModel.defaultValue = 0 / 2.0;
    minFPSModel.infoText = @"8";
    minFPSModel.infoUnit = @"fps";
    minFPSModel.reuseId = AlivcLiveParamModelReuseCellSlider;
    minFPSModel.sliderBlock = ^(int value) {
        self.pushConfig.minFps = (AlivcLivePushFPS) value;
    };
    
    AlivcLiveParamModel *fpsDescModel = [[AlivcLiveParamModel alloc] init];
    fpsDescModel.reuseId = AlivcLiveParamModelReuseCellSliderHeader;
    fpsDescModel.title = AUILiveCommonString(@"采集帧率");

    AlivcLiveParamModel *captureFPSModel = [[AlivcLiveParamModel alloc] init];
    captureFPSModel.title = AUILiveCommonString(@"采集帧率");
    captureFPSModel.defaultValue = 1.5 / 2.0;;
    captureFPSModel.infoText = @"20";
    captureFPSModel.infoUnit = @"fps";
    captureFPSModel.reuseId = AlivcLiveParamModelReuseCellSlider;
    captureFPSModel.sliderBlock = ^(int value) {
        self.pushConfig.fps = (AlivcLivePushFPS) value;
    };

    AlivcLiveParamModel *audioSampleRateDescModel = [[AlivcLiveParamModel alloc] init];
    audioSampleRateDescModel.reuseId = AlivcLiveParamModelReuseCellSliderHeader;
    audioSampleRateDescModel.title = AUILiveCameraPushString(@"音频采样率");
    
    AlivcLiveParamModel *audioSampleRateModel = [[AlivcLiveParamModel alloc] init];
    audioSampleRateModel.title = AUILiveCommonString(@"音频采样率");
    audioSampleRateModel.infoText = @"48";
    audioSampleRateModel.infoUnit = @"kHz";
    audioSampleRateModel.defaultValue = 1;
    audioSampleRateModel.reuseId = AlivcLiveParamModelReuseCellSlider;
    audioSampleRateModel.sliderBlock = ^(int value) {
        self.pushConfig.audioSampleRate = (AlivcLivePushAudioSampleRate) value;
    };

    AlivcLiveParamModel *gopDescModel = [[AlivcLiveParamModel alloc] init];
    gopDescModel.reuseId = AlivcLiveParamModelReuseCellSliderHeader;
    gopDescModel.title = AUILiveCommonString(@"关键帧间隔");

    AlivcLiveParamModel *gopModel = [[AlivcLiveParamModel alloc] init];
    gopModel.title = AUILiveCommonString(@"关键帧间隔");
    gopModel.defaultValue = 1.0 / 2.0;
    gopModel.infoText = @"2";
    gopModel.infoUnit = @"s";
    gopModel.reuseId = AlivcLiveParamModelReuseCellSlider;
    gopModel.sliderBlock = ^(int value) {
        self.pushConfig.videoEncodeGop = (AlivcLivePushVideoEncodeGOP) value;
    };

    AlivcLiveParamModel *audioProfileModel = [[AlivcLiveParamModel alloc] init];
    audioProfileModel.title = AUILiveCommonString(@"音频格式");
    audioProfileModel.pickerPanelTextArray = @[@"AAC_LC", @"HE_AAC", @"HEAAC_V2", @"AAC_LD"];
    audioProfileModel.defaultValue = 0;
    audioProfileModel.reuseId = AlivcLiveParamModelReuseCellPickerSelect;
    audioProfileModel.pickerSelectBlock = ^(int value) {
        switch (value) {
            case 0:
                self.pushConfig.audioEncoderProfile = AlivcLivePushAudioEncoderProfile_AAC_LC;
                break;
            case 1:
                self.pushConfig.audioEncoderProfile = AlivcLivePushAudioEncoderProfile_HE_AAC;
                break;
            case 2:
                self.pushConfig.audioEncoderProfile = AlivcLivePushAudioEncoderProfile_HE_AAC_V2;
                break;
            case 3:
                self.pushConfig.audioEncoderProfile = AlivcLivePushAudioEncoderProfile_AAC_LD;
                break;
            default:
                break;
        }
    };

    AlivcLiveParamModel *audioChannelModel = [[AlivcLiveParamModel alloc] init];
    audioChannelModel.title = AUILiveCommonString(@"声道数");
    audioChannelModel.pickerPanelTextArray = @[AUILiveCommonString(@"单声道"), AUILiveCommonString(@"双声道")];
    audioChannelModel.defaultValue = 0;
    audioChannelModel.reuseId = AlivcLiveParamModelReuseCellPickerSelect;
    audioChannelModel.pickerSelectBlock = ^(int value) {
        self.pushConfig.audioChannel = (value == 0 ? AlivcLivePushAudioChannel_1 : AlivcLivePushAudioChannel_2);
    };

    AlivcLiveParamModel *audioHardwareEncodeModel = [[AlivcLiveParamModel alloc] init];
    audioHardwareEncodeModel.title = AUILiveCommonString(@"音频硬编码");
    audioHardwareEncodeModel.defaultValue = 1;
    audioHardwareEncodeModel.defaultValueAppose = 1.0;
    audioHardwareEncodeModel.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    audioHardwareEncodeModel.switchBlock = ^(int index, BOOL open) {
        self.pushConfig.audioEncoderMode = open ? AlivcLivePushAudioEncoderModeHard : AlivcLivePushAudioEncoderModeSoft;
    };

    AlivcLiveParamModel *videoOnly_encodeModeModel = [[AlivcLiveParamModel alloc] init];
    videoOnly_encodeModeModel.title = AUILiveCommonString(@"视频硬编码");
    videoOnly_encodeModeModel.defaultValue = 1;
    videoOnly_encodeModeModel.defaultValueAppose = 1.0;
    videoOnly_encodeModeModel.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    videoOnly_encodeModeModel.switchBlock = ^(int index, BOOL open) {
        self.pushConfig.videoEncoderMode = open ? AlivcLivePushVideoEncoderModeHard : AlivcLivePushVideoEncoderModeSoft;
        [self.pushContentTableView reloadData];
        // [self showAndHiddenVideoCodecVideo:!open];
    };

    AlivcLiveParamModel *videoHardEncodeCodecModel = [[AlivcLiveParamModel alloc] init];
    videoHardEncodeCodecModel.title = AUILiveCommonString(@"视频硬编Codec");
    videoHardEncodeCodecModel.pickerPanelTextArray = @[@"H264", @"H265"];
    videoHardEncodeCodecModel.defaultValue = 0;
    videoHardEncodeCodecModel.reuseId = AlivcLiveParamModelReuseCellPickerSelect;
    videoHardEncodeCodecModel.pickerSelectBlock = ^(int value) {
        self.pushConfig.videoHardEncoderCodec = (value == 1 ? AlivcLivePushVideoEncoderModeHardCodecHEVC : AlivcLivePushVideoEncoderModeHardCodecH264);
    };

    AlivcLiveParamModel *bFrameModeModel = [[AlivcLiveParamModel alloc] init];
    bFrameModeModel.title = AUILiveCameraPushString(@"B-Frame");
    bFrameModeModel.defaultValue = 0;
    bFrameModeModel.defaultValueAppose = 1.0;
    bFrameModeModel.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    bFrameModeModel.switchBlock = ^(int index, BOOL open) {
        self.pushConfig.openBFrame = open;
    };

    return @[qualityModeModel, qualityModeDescModel, targetBitrateModel, minBitrateModel, initBitrateModel, audioBitrateModel,
             minFPSDescModel, minFPSModel, fpsDescModel, captureFPSModel, audioSampleRateDescModel, audioSampleRateModel, gopDescModel, gopModel, blankSegmentModel,
            audioProfileModel, audioChannelModel, audioHardwareEncodeModel,
            videoOnly_encodeModeModel, videoHardEncodeCodecModel, bFrameModeModel];
}

- (NSAttributedString *)getSliderRightAttributedStringAtName:(NSString *)name unit:(NSString *)unit {
    NSMutableAttributedString *infoAttributedText = [[NSMutableAttributedString alloc] initWithString:name attributes:@{
        NSFontAttributeName: AVGetRegularFont(15),
        NSForegroundColorAttributeName: AUIFoundationColor(@"text_strong")
    }];
    [infoAttributedText appendAttributedString:[[NSAttributedString alloc] initWithString:unit attributes:@{
        NSFontAttributeName: AVGetRegularFont(11),
        NSForegroundColorAttributeName: AUIFoundationColor(@"text_weak")
    }]];
    return infoAttributedText;
}

- (NSArray *)getPushFeatureArray {
    AlivcLiveParamModel *blankSegmentModel = [[AlivcLiveParamModel alloc] init];
    blankSegmentModel.reuseId = AlivcLiveParamModelReuseCellSliderHeader;
    blankSegmentModel.title = @"";

    AlivcLiveParamModel *orientationModel = [[AlivcLiveParamModel alloc] init];
    orientationModel.title = AUILiveCommonString(@"推流方向");
    orientationModel.pickerPanelTextArray = @[AUILiveCommonString(@"竖屏"), AUILiveCommonString(@"横屏向左"), AUILiveCommonString(@"横屏向右")];
    orientationModel.defaultValue = 0;
    orientationModel.reuseId = AlivcLiveParamModelReuseCellPickerSelect;
    orientationModel.pickerSelectBlock = ^(int value) {
        self.pushConfig.orientation = (AlivcLivePushOrientation) value;
        self.pushConfig.pauseImg = (self.pushConfig.orientation == AlivcLivePushOrientationPortrait)
                ? AUILiveCommonImage(@"background_push.png") : AUILiveCommonImage(@"background_push_land.png");
        self.pushConfig.networkPoorImg = (self.pushConfig.orientation == AlivcLivePushOrientationPortrait)
                ? AUILiveCommonImage(@"poor_network.png") : AUILiveCommonImage(@"poor_network_land.png");
    };
    
    AlivcLiveParamModel *previewDisplayModeModel = [[AlivcLiveParamModel alloc] init];
    previewDisplayModeModel.title = AUILiveCameraPushString(@"显示模式");
    previewDisplayModeModel.pickerPanelTextArray = @[AUILiveCameraPushString(@"拉伸"), AUILiveCameraPushString(@"适合"), AUILiveCameraPushString(@"裁剪")];
    previewDisplayModeModel.defaultValue = 1;
    previewDisplayModeModel.reuseId = AlivcLiveParamModelReuseCellPickerSelect;
    previewDisplayModeModel.pickerSelectBlock = ^(int value) {
        self.pushConfig.previewDisplayMode = (AlivcPusherPreviewDisplayMode) value;
    };

    AlivcLiveParamModel *reconnectDescModel = [[AlivcLiveParamModel alloc] init];
    reconnectDescModel.reuseId = AlivcLiveParamModelReuseCellSliderHeader;
    reconnectDescModel.title = AUILiveCameraPushString(@"自动重连");

    AlivcLiveParamModel *reconnectDurationModel = [[AlivcLiveParamModel alloc] init];
    reconnectDurationModel.title = AUILiveCommonString(@"重连时长");
    reconnectDurationModel.defaultValue = 1000;
    reconnectDurationModel.infoText = @"/ms";
    reconnectDurationModel.infoColor = AUIFoundationColor(@"text_strong");
    reconnectDurationModel.reuseId = AlivcLiveParamModelReuseCellInput;
    reconnectDurationModel.valueBlock = ^(int value) {
        self.pushConfig.connectRetryInterval = value;
    };

    AlivcLiveParamModel *reconnectTimeModel = [[AlivcLiveParamModel alloc] init];
    reconnectTimeModel.title = AUILiveCommonString(@"重连次数");
    reconnectTimeModel.defaultValue = 5;
    reconnectTimeModel.infoText = [@"/" stringByAppendingString:AUILiveCameraPushString(@"次")];
    reconnectTimeModel.infoColor = AUIFoundationColor(@"text_strong");
    reconnectTimeModel.reuseId = AlivcLiveParamModelReuseCellInput;
    reconnectTimeModel.valueBlock = ^(int value) {
        self.pushConfig.connectRetryCount = value;
    };

    AlivcLiveParamModel *watermarkDescModel = [[AlivcLiveParamModel alloc] init];
    watermarkDescModel.reuseId = AlivcLiveParamModelReuseCellSliderHeader;
    watermarkDescModel.title = AUILiveCommonString(@"水印");

    AlivcLiveParamModel *watermarkModel = [[AlivcLiveParamModel alloc] init];
    watermarkModel.title = AUILiveCommonString(@"开启水印");
    watermarkModel.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    watermarkModel.defaultValue = self.isUseWatermark;
    watermarkModel.defaultValueAppose = self.isUseWatermark;
    watermarkModel.switchBlock = ^(int index, BOOL open) {
        self.isUseWatermark = open;
    };

//    AlivcLiveParamModel *watermarkSetLocationModel = [[AlivcLiveParamModel alloc] init];
//    watermarkSetLocationModel.title = AUILiveCommonString(@"水印设置");
//    watermarkSetLocationModel.reuseId = AlivcLiveParamModelReuseCellSwitchSetButton;
//    watermarkSetLocationModel.defaultValue = 1.0;
//    watermarkSetLocationModel.infoText = AUILiveCommonString(@"去设置");
//    watermarkSetLocationModel.switchBlock = ^(int index, BOOL open) {
//        self.isUseWatermark = open;
//    };
//    watermarkSetLocationModel.switchButtonBlock = ^() {
//        [self.view addSubview:self.waterSettingView];
//    };

    AlivcLiveParamModel *mirrorDescModel = [[AlivcLiveParamModel alloc] init];
    mirrorDescModel.reuseId = AlivcLiveParamModelReuseCellSliderHeader;
    mirrorDescModel.title = AUILiveCameraPushString(@"镜像");

    AlivcLiveParamModel *pushMirrorModel = [[AlivcLiveParamModel alloc] init];
    pushMirrorModel.title = AUILiveCommonString(@"推流镜像");
    pushMirrorModel.defaultValue = 0;
    pushMirrorModel.defaultValueAppose = 0;
    pushMirrorModel.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    pushMirrorModel.switchBlock = ^(int index, BOOL open) {
        self.pushConfig.pushMirror = open;
    };

    AlivcLiveParamModel *previewMirrorModel = [[AlivcLiveParamModel alloc] init];
    previewMirrorModel.title = AUILiveCommonString(@"预览镜像");
    previewMirrorModel.defaultValue = 0;
    previewMirrorModel.defaultValueAppose = 0;
    previewMirrorModel.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    previewMirrorModel.switchBlock = ^(int index, BOOL open) {
        self.pushConfig.previewMirror = open;
    };

    AlivcLiveParamModel *cameraControlModel = [[AlivcLiveParamModel alloc] init];
    cameraControlModel.reuseId = AlivcLiveParamModelReuseCellSliderHeader;
    cameraControlModel.title = AUILiveCameraPushString(@"相机控制");

    AlivcLiveParamModel *cameraTypeModel = [[AlivcLiveParamModel alloc] init];
    cameraTypeModel.title = AUILiveCommonString(@"前置摄像头");
    cameraTypeModel.defaultValue = 1.0;
    cameraTypeModel.defaultValueAppose = 1.0;
    cameraTypeModel.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    cameraTypeModel.switchBlock = ^(int index, BOOL open) {
        self.pushConfig.cameraType = open ? AlivcLivePushCameraTypeFront : AlivcLivePushCameraTypeBack;
    };

    AlivcLiveParamModel *autoFocusModel = [[AlivcLiveParamModel alloc] init];
    autoFocusModel.title = AUILiveCommonString(@"自动对焦");
    autoFocusModel.defaultValue = 1.0;
    autoFocusModel.defaultValueAppose = 0;
    autoFocusModel.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    autoFocusModel.switchBlock = ^(int index, BOOL open) {
        self.pushConfig.autoFocus = open;
    };

    AlivcLiveParamModel *beautyDescModel = [[AlivcLiveParamModel alloc] init];
    beautyDescModel.reuseId = AlivcLiveParamModelReuseCellSliderHeader;
    beautyDescModel.title = AUILiveCameraPushString(@"美颜开关");

    AlivcLiveParamModel *beautySwitchModel = [[AlivcLiveParamModel alloc] init];
    beautySwitchModel.title = AUILiveCommonString(@"开启美颜");
    beautySwitchModel.defaultValue = self.isBeautyOn;
    beautySwitchModel.defaultValueAppose = self.isBeautyOn;
    beautySwitchModel.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    beautySwitchModel.switchBlock = ^(int index, BOOL open) {
        self.isBeautyOn = open;
    };

    AlivcLiveParamModel *backgroundDescModel = [[AlivcLiveParamModel alloc] init];
    backgroundDescModel.reuseId = AlivcLiveParamModelReuseCellSliderHeader;
    backgroundDescModel.title = AUILiveCameraPushString(@"垫片推流");

    AlivcLiveParamModel *pauseImageModel = [[AlivcLiveParamModel alloc] init];
    pauseImageModel.title = AUILiveCommonString(@"暂停图片");
    pauseImageModel.defaultValue = 1.0;
    pauseImageModel.defaultValueAppose = 1.0;
    pauseImageModel.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    pauseImageModel.switchBlock = ^(int index, BOOL open) {
        self.pushConfig.pauseImg = open ? (self.pushConfig.orientation == AlivcLivePushOrientationPortrait ? AUILiveCommonImage(@"background_push.png") : AUILiveCommonImage(@"background_push_land.png")) : nil;
    };

    AlivcLiveParamModel *networkWeakImageModel = [[AlivcLiveParamModel alloc] init];
    networkWeakImageModel.title = AUILiveCommonString(@"网络差图片");
    networkWeakImageModel.defaultValue = 1.0;
    networkWeakImageModel.defaultValueAppose = 1.0;
    networkWeakImageModel.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    networkWeakImageModel.switchBlock = ^(int index, BOOL open) {
        if (open) {
            self.pushConfig.networkPoorImg = (self.pushConfig.orientation == AlivcLivePushOrientationPortrait) ? AUILiveCommonImage(@"poor_network.png") : AUILiveCommonImage(@"poor_network_land.png");
        } else {
            self.pushConfig.networkPoorImg = nil;
        }
    };
    
    AlivcLiveParamModel *pushStreamingModel = [[AlivcLiveParamModel alloc] init];
    pushStreamingModel.title = AUILiveCameraPushString(@"推流模式");
    pushStreamingModel.pickerPanelTextArray = @[AUILiveCameraPushString(@"音视频"), AUILiveCommonString(@"纯音频"), AUILiveCommonString(@"纯视频")];
    pushStreamingModel.defaultValue = 0;
    pushStreamingModel.reuseId = AlivcLiveParamModelReuseCellPickerSelect;
    pushStreamingModel.pickerSelectBlock = ^(int value) {
        if (value == 0) {
            self.pushConfig.audioOnly = NO;
            self.pushConfig.videoOnly = NO;
        } else if (value == 1) {
            self.pushConfig.audioOnly = YES;
            self.pushConfig.videoOnly = NO;
        } else if (value == 2) {
            self.pushConfig.audioOnly = NO;
            self.pushConfig.videoOnly = YES;
        }
    };
    
    AlivcLiveParamModel *authTestModel = [[AlivcLiveParamModel alloc] init];
    authTestModel.reuseId = AlivcLiveParamModelReuseCellSliderHeader;
    authTestModel.title = AUILiveCameraPushString(@"测试鉴权");
    
    AlivcLiveParamModel *authTimeModel = [[AlivcLiveParamModel alloc] init];
    authTimeModel.title = AUILiveCameraPushString(@"鉴权时间");
    authTimeModel.infoText = @"ms";
    authTimeModel.reuseId = AlivcLiveParamModelReuseCellInput;
    authTimeModel.stringBlock = ^(NSString *message) {
        self.authDuration = message;
    };
    
    AlivcLiveParamModel *authKeyModel = [[AlivcLiveParamModel alloc] init];
    authKeyModel.title = AUILiveCameraPushString(@"鉴权Key");
    authKeyModel.infoText = @"";
    authKeyModel.reuseId = AlivcLiveParamModelReuseCellInput;
    authKeyModel.stringBlock = ^(NSString *message) {
        self.authKey = message;
    };

    AlivcLiveParamModel *otherDescModel = [[AlivcLiveParamModel alloc] init];
    otherDescModel.reuseId = AlivcLiveParamModelReuseCellSliderHeader;
    otherDescModel.title = AUILiveCameraPushString(@"其他功能");

    AlivcLiveParamModel *useExternalStreamModel = [[AlivcLiveParamModel alloc] init];
    useExternalStreamModel.title = AUILiveCommonString(@"外部音视频");
    useExternalStreamModel.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    useExternalStreamModel.defaultValue = self.isUseExternalStream;
    useExternalStreamModel.switchBlock = ^(int index, BOOL open) {
        if (index == 0) {
            self.isUseExternalStream = open;
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
                        AUILiveParamTableViewCell *targetCell = [self.pushContentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:22 inSection:0]];
                        [targetCell updateDefaultValue:0 enable:YES];
                        self.isUseExternalStream = NO;
                    }
                }];
            }
        }
    };

    AlivcLiveParamModel *asyncModel = [[AlivcLiveParamModel alloc] init];
    asyncModel.title = AUILiveCommonString(@"异步接口");
    asyncModel.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    asyncModel.defaultValue = self.isUseAsync;
    asyncModel.switchBlock = ^(int index, BOOL open) {
        if (index == 0) {
            self.isUseAsync = open;
        }
    };

    AlivcLiveParamModel *musicMode = [[AlivcLiveParamModel alloc] init];
    musicMode.title = AUILiveCameraPushString(@"音乐模式");
    musicMode.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    musicMode.defaultValue = 0.0;
    musicMode.switchBlock = ^(int index, BOOL open) {
        if (index == 0) {
            self.pushConfig.audioScene = open ? AlivcLivePusherAudioScenarioMusicMode : AlivcLivePusherAudioScenarioDefaultMode;
        }
    };
    
    AlivcLiveParamModel *localLogModel = [[AlivcLiveParamModel alloc] init];
    localLogModel.title = AUILiveCameraPushString(@"本地日志");
    localLogModel.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    localLogModel.defaultValue = 0.0;
    localLogModel.switchBlock = ^(int index, BOOL open) {
        if (index == 0) {
            if (open) {
                [AlivcLiveBase setLogLevel:(AlivcLivePushLogLevelDebug)];
                [AlivcLiveBase setConsoleEnable:YES];
                
                NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                [AlivcLiveBase setLogPath:cacheDirectory maxPartFileSizeInKB:100*1024*1024];
            } else {
                [AlivcLiveBase setLogLevel:(AlivcLivePushLogLevelNone)];
                [AlivcLiveBase setConsoleEnable:NO];
            }
        }
    };

    return @[orientationModel, previewDisplayModeModel, reconnectDescModel, reconnectDurationModel, reconnectTimeModel,
            watermarkDescModel, watermarkModel, mirrorDescModel, pushMirrorModel, previewMirrorModel,
            cameraControlModel, cameraTypeModel, autoFocusModel, beautyDescModel, beautySwitchModel,
            backgroundDescModel, pauseImageModel, networkWeakImageModel, blankSegmentModel, pushStreamingModel,
            otherDescModel, useExternalStreamModel, asyncModel, localLogModel];
}

@end
