//
//  AUILiveInteractiveURLConfigViewController.m
//  AlivcLivePusherDemo
//
//  Created by ISS013602000846 on 2022/9/6.
//  Copyright © 2022 TripleL. All rights reserved.
//

#import "AUILiveInteractiveURLConfigViewController.h"
#import "AUILiveURLUtils.h"
#import "AUILiveURLConfigManager.h"
#import "AUILiveInputNumberView.h"
#import "AUILiveInteractiveParamManager.h"

@interface AUILiveInteractiveURLConfigViewController ()

@property (nonatomic, strong) AUILiveInputNumberView *appIDInputView;
@property (nonatomic, strong) AUILiveInputNumberView *appKeyInputView;
@property (nonatomic, strong) AUILiveInputNumberView *playDomainInputView;
@property (nonatomic, strong) UIButton *pushStartButton;
@property (nonatomic, strong) AUILiveURLConfigManager *urlManager;
@property (nonatomic, strong) NSString *appID_temp;
@property (nonatomic, strong) NSString *appKey_temp;
@property (nonatomic, strong) NSString *playDomain_temp;

@end

@implementation AUILiveInteractiveURLConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleView.text = AUILiveCommonString(@"应用信息");
    self.hiddenMenuButton = YES;
    
    [self setupData];
    [self setupContent];
}

- (void)setupData {
    self.appID_temp = self.urlManager.appID;
    self.appKey_temp = self.urlManager.appKey;
    self.playDomain_temp = self.urlManager.playDomain;
}

- (void)setupContent {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignInputStatus)];
    [self.view addGestureRecognizer:tap];
    
    [self.contentView addSubview:self.appIDInputView];
    [self.contentView addSubview:self.appKeyInputView];
    [self.contentView addSubview:self.playDomainInputView];
    [self.contentView addSubview:self.pushStartButton];
    
    __weak typeof(self) weakSelf = self;
    self.appIDInputView.defaultInput = self.appID_temp;
    self.appIDInputView.inputChanged = ^(NSString * _Nonnull value) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.appID_temp = value;
        [strongSelf updatePushStartButtonEnableStatus];
    };
    
    self.appKeyInputView.defaultInput = self.appKey_temp;
    self.appKeyInputView.inputChanged = ^(NSString * _Nonnull value) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.appKey_temp = value;
        [strongSelf updatePushStartButtonEnableStatus];
    };
    
    self.playDomainInputView.defaultInput = self.playDomain_temp;
    self.playDomainInputView.inputChanged = ^(NSString * _Nonnull value) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.playDomain_temp = value;
        [strongSelf updatePushStartButtonEnableStatus];
    };
    
    self.pushStartButton.enabled = NO;
}

- (void)updatePushStartButtonEnableStatus {
    if (self.appID_temp.length > 0 && self.appKey_temp.length > 0 && self.playDomain_temp.length > 0) {
            self.pushStartButton.enabled = YES;
            [self.pushStartButton setBackgroundColor:AUIFoundationColor(@"colourful_fill_strong")];
            [self.pushStartButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
    } else {
        self.pushStartButton.enabled = NO;
        [self.pushStartButton setBackgroundColor:AUILiveCommonColor(@"ir_button_unenable")];
        [self.pushStartButton setTitleColor:AUIFoundationColor(@"text_weak") forState:UIControlStateNormal];
    }
}

- (void)clickPushStartButton:(UIButton *)sender {
    self.urlManager.appID = self.appID_temp;
    self.urlManager.appKey = self.appKey_temp;
    self.urlManager.playDomain = self.playDomain_temp;

    UIViewController *lastVC = nil;
    if (self.navigationController.viewControllers.count >= 2) {
        lastVC = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2];
    }
    if (self.type == AUILiveInteractiveURLConfigTypeLinkMic) {
        Class viewControllerClass = NSClassFromString(@"AUILiveLinkMicConfigViewController");
        if (lastVC && [lastVC isKindOfClass:viewControllerClass]) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            UIViewController *vc = [[viewControllerClass alloc] init];
            if (vc) {
                [self.navigationController pushViewController:vc animated:YES];
                [self av_hideFromParentViewController];
            }
        }
    } else {
        Class viewControllerClass = NSClassFromString(@"AUILivePKConfigViewController");
        if (lastVC && [lastVC isKindOfClass:viewControllerClass]) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            UIViewController *vc = [[viewControllerClass alloc] init];
            if (vc) {
                [self.navigationController pushViewController:vc animated:YES];
                [self av_hideFromParentViewController];
            }
        }
    }
}

- (void)resignInputStatus {
    [self.appIDInputView resignInputStatus];
    [self.appKeyInputView resignInputStatus];
    [self.playDomainInputView resignInputStatus];
}

#pragma mark -- lazy load
- (AUILiveURLConfigManager *)urlManager {
    if (!_urlManager) {
        _urlManager = [AUILiveURLConfigManager manager];
    }
    return _urlManager;
}

- (AUILiveInputNumberView *)appIDInputView {
    if (!_appIDInputView) {
        _appIDInputView = [[AUILiveInputNumberView alloc] initWithFrame:CGRectMake(20, 30, self.contentView.av_width - 20 * 2, 73) type:AUILiveInputNumberTypeInputAndScan sourceVC:self];
        _appIDInputView.themeName = AUILiveCommonString(@"AppID");
        _appIDInputView.maxNumber = kAUILiveInputNotMaxNumer;
        _appIDInputView.isAllowExtraSpecialCharacters = YES;
    }
    return _appIDInputView;
}

- (AUILiveInputNumberView *)appKeyInputView {
    if (!_appKeyInputView) {
        _appKeyInputView = [[AUILiveInputNumberView alloc] initWithFrame:CGRectMake(20, self.appIDInputView.av_bottom + 30, self.contentView.av_width - 20 * 2, 73) type:AUILiveInputNumberTypeInputAndScan sourceVC:self];
        _appKeyInputView.themeName = AUILiveCommonString(@"AppKey");
        _appKeyInputView.maxNumber = kAUILiveInputNotMaxNumer;
        _appKeyInputView.isAllowExtraSpecialCharacters = YES;
    }
    return _appKeyInputView;
}

- (AUILiveInputNumberView *)playDomainInputView {
    if (!_playDomainInputView) {
        _playDomainInputView = [[AUILiveInputNumberView alloc] initWithFrame:CGRectMake(20, self.appKeyInputView.av_bottom + 30, self.contentView.av_width - 20 * 2, 73) type:AUILiveInputNumberTypeInputAndScan sourceVC:self];
        _playDomainInputView.themeName = AUILiveCommonString(@"播流域名");
        _playDomainInputView.maxNumber = kAUILiveInputNotMaxNumer;
        _playDomainInputView.isAllowExtraSpecialCharacters = YES;
    }
    return _playDomainInputView;
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

@end
