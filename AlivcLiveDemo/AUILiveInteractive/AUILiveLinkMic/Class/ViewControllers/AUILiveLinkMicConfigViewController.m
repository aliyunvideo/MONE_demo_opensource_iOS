//
//  AUILiveLinkMicConfigViewController.m
//  AUILiveLinkMic
//
//  Created by ISS013602000846 on 2022/7/27.
//

#import "AUILiveLinkMicConfigViewController.h"
#import "AUILiveURLUtils.h"
#import "AUILiveURLConfigManager.h"
#import "AUILiveInputNumberView.h"
#import "AUILiveInteractiveURLConfigInfoView.h"
#import "AUILiveLinkMicSelectRoleView.h"
#import "AUILiveInteractiveParamManager.h"
#import "AUILiveInteractiveParamConfigViewController.h"
#import "AUILiveLinkMicAnchorLinkViewController.h"
#import "AUILiveLinkMicAudienceLinkViewController.h"
#import "AUILiveInteractiveURLConfigViewController.h"

@interface AUILiveLinkMicConfigViewController ()

@property (nonatomic, strong) AUILiveInputNumberView *userIdInputView;
@property (nonatomic, strong) AUILiveInputNumberView *streamIdInputView;
@property (nonatomic, strong) AUILiveInteractiveURLConfigInfoView *urlConfigInfoView;
@property (nonatomic, strong) AUILiveLinkMicSelectRoleView *selectRoleView;
@property (nonatomic, strong) UIButton *pushStartButton;
@property (nonatomic, strong) AUILiveURLUtils *rtcConfig;
@property (nonatomic, assign) AUILiveLinkMicSelectRoleType roleType;
@property (nonatomic, strong) AUILiveInteractiveParamManager *paramManager;

@end

@implementation AUILiveLinkMicConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleView.text = AUILiveLinkMicString(@"连麦互动");
    self.menuButton.av_left = self.headerView.av_width - 12 - 120;
    self.menuButton.av_width = 120;
    [self.menuButton setImage:nil forState:UIControlStateNormal];
    [self.menuButton setTitle:AUILiveCommonString(@"参数设置") forState:UIControlStateNormal];
    [self.menuButton addTarget:self action:@selector(openparamManager) forControlEvents:UIControlEventTouchUpInside];
    
    [self setupContent];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshPushStartButton];
    
    AUILiveURLConfigManager *urlConfigManager = [AUILiveURLConfigManager manager];
    [self.urlConfigInfoView showAppID:urlConfigManager.appID appKey:urlConfigManager.appKey playDomain:urlConfigManager.playDomain];
}

- (void)openparamManager {
    AUILiveInteractiveParamConfigViewController *vc = [[AUILiveInteractiveParamConfigViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setupContent {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignInputStatus)];
    [self.view addGestureRecognizer:tap];
    
    [self.contentView addSubview:self.userIdInputView];
    [self.contentView addSubview:self.streamIdInputView];
    [self.contentView addSubview:self.urlConfigInfoView];
    [self.contentView addSubview:self.selectRoleView];
    [self.contentView addSubview:self.pushStartButton];
    
    __weak typeof(self) weakSelf = self;
    self.userIdInputView.inputChanged = ^(NSString * _Nonnull value) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.rtcConfig.userId = value;
        [strongSelf refreshPushStartButton];
    };
    
    self.streamIdInputView.inputChanged = ^(NSString * _Nonnull value) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.rtcConfig.streamName = value;
        [strongSelf refreshPushStartButton];
    };
    
    self.urlConfigInfoView.modifyConfig = ^{
        __strong typeof(self) strongSelf = weakSelf;
        AUILiveInteractiveURLConfigViewController *urlConfig = [[AUILiveInteractiveURLConfigViewController alloc] init];
        urlConfig.type = AUILiveInteractiveURLConfigTypeLinkMic;
        [strongSelf.navigationController pushViewController:urlConfig animated:YES];
    };
    
    self.selectRoleView.selectRole = ^(AUILiveLinkMicSelectRoleType roleType) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.roleType = roleType;
        [strongSelf resignInputStatus];
        [strongSelf refreshPushStartButton];
    };
    
    if ([[AUILiveURLConfigManager manager] haveSigGenerateConfig]) {
        self.urlConfigInfoView.hidden = YES;
        self.selectRoleView.av_top = self.streamIdInputView.av_bottom + 30;
    }
    
    self.pushStartButton.enabled = NO;
}

- (void)refreshPushStartButton {
    if (self.rtcConfig.userId.length > 0 && self.rtcConfig.streamName.length > 0 && self.roleType != AUILiveLinkMicSelectRoleTypeNone) {
        [self setPushStartButtonEnableStatus:YES];
    } else {
        [self setPushStartButtonEnableStatus:NO];
    }
}

- (void)setPushStartButtonEnableStatus:(BOOL)enable {
    self.pushStartButton.enabled = enable;
    if (enable) {
        [self.pushStartButton setBackgroundColor:AUIFoundationColor(@"colourful_fill_strong")];
        [self.pushStartButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
    } else {
        self.pushStartButton.enabled = NO;
        [self.pushStartButton setBackgroundColor:AUILiveCommonColor(@"ir_button_unenable")];
        [self.pushStartButton setTitleColor:AUIFoundationColor(@"text_weak") forState:UIControlStateNormal];
    }
}

- (void)clickPushStartButton:(UIButton *)sender {
    if (self.roleType == AUILiveLinkMicSelectRoleTypeAnchor) {
        AUILiveLinkMicAnchorLinkViewController *vc = [[AUILiveLinkMicAnchorLinkViewController alloc] init];
        vc.rtcConfig = self.rtcConfig;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (self.roleType == AUILiveLinkMicSelectRoleTypeAudience) {
        AUILiveLinkMicAudienceLinkViewController *vc = [[AUILiveLinkMicAudienceLinkViewController alloc] init];
        vc.rtcConfig = self.rtcConfig;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    [self setPushStartButtonEnableStatus:NO];
}

- (void)resignInputStatus {
    [self.userIdInputView resignInputStatus];
    [self.streamIdInputView resignInputStatus];
}

#pragma mark -- lazy load
- (AUILiveURLUtils *)rtcConfig {
    if (!_rtcConfig) {
        _rtcConfig = [[AUILiveURLUtils alloc] init];
    }
    return _rtcConfig;
}

- (AUILiveInteractiveParamManager *)paramManager {
    if (!_paramManager) {
        _paramManager = [AUILiveInteractiveParamManager manager];
    }
    return _paramManager;
}

- (AUILiveInputNumberView *)userIdInputView {
    if (!_userIdInputView) {
        _userIdInputView = [[AUILiveInputNumberView alloc] initWithFrame:CGRectMake(20, 30, self.contentView.av_width - 20 * 2, 73) type:AUILiveInputNumberTypeInput sourceVC:self];
        _userIdInputView.themeName = AUILiveCommonString(@"用户ID");
        _userIdInputView.maxNumber = 64;
    }
    return _userIdInputView;
}

- (AUILiveInputNumberView *)streamIdInputView {
    if (!_streamIdInputView) {
        _streamIdInputView = [[AUILiveInputNumberView alloc] initWithFrame:CGRectMake(20, self.userIdInputView.av_bottom + 30, self.contentView.av_width - 20 * 2, 73) type:AUILiveInputNumberTypeInput sourceVC:self];
        _streamIdInputView.themeName = AUILiveCommonString(@"房间号");
        _streamIdInputView.maxNumber = 64;
    }
    return _streamIdInputView;
}

- (AUILiveInteractiveURLConfigInfoView *)urlConfigInfoView {
    if (!_urlConfigInfoView) {
        _urlConfigInfoView = [[AUILiveInteractiveURLConfigInfoView alloc] initWithFrame:CGRectMake(20, self.streamIdInputView.av_bottom + 30, self.contentView.av_width - 20 * 2, 153)];
        _urlConfigInfoView.themeName = AUILiveCommonString(@"应用信息");
    }
    return _urlConfigInfoView;
}

- (AUILiveLinkMicSelectRoleView *)selectRoleView {
    if (!_selectRoleView) {
        _selectRoleView = [[AUILiveLinkMicSelectRoleView alloc] initWithFrame:CGRectMake(20, self.urlConfigInfoView.av_bottom + 30, self.contentView.av_width - 20 * 2, 120)];
    }
    return _selectRoleView;
}

- (UIButton *)pushStartButton {
    if (!_pushStartButton) {
        _pushStartButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        _pushStartButton.frame = CGRectMake(20, self.contentView.av_height - AVSafeBottom - 8 - 48, self.contentView.av_width - 20 * 2, 48);
        [_pushStartButton setBackgroundColor:AUILiveCommonColor(@"ir_button_unenable")];
        [_pushStartButton setTitle:AUILiveCommonString(@"确定") forState:UIControlStateNormal];
        [_pushStartButton setTitleColor:AUIFoundationColor(@"text_weak") forState:UIControlStateNormal];
        [_pushStartButton.titleLabel setFont:AVGetRegularFont(18)];
        [_pushStartButton.layer setMasksToBounds:YES];
        [_pushStartButton.layer setCornerRadius:24];
        [_pushStartButton addTarget:self action:@selector(clickPushStartButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pushStartButton;
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    if (!parent) {
        [self.paramManager reset];
    }
}

@end
