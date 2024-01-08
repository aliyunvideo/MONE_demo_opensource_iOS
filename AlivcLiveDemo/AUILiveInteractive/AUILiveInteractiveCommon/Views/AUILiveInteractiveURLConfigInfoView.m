//
//  AUILiveInteractiveURLConfigInfoView.m
//  AlivcLivePusherDemo
//
//  Created by ISS013602000846 on 2022/9/7.
//  Copyright © 2022 TripleL. All rights reserved.
//

#import "AUILiveInteractiveURLConfigInfoView.h"

@interface AUILiveInteractiveURLConfigInfoView ()

@property (nonatomic, strong) UILabel *themeLabel;
@property (nonatomic, strong) UIButton *switchContentButton;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *appIDValueLabel;
@property (nonatomic, strong) UILabel *appKeyValueLabel;
@property (nonatomic, strong) UILabel *playDomainValueLabel;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation AUILiveInteractiveURLConfigInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.themeLabel];
        [self addSubview:self.switchContentButton];
        [self addSubview:self.contentView];
        [self addSubview:self.lineView];
        
        self.themeLabel.frame = CGRectMake(0, 0, self.av_width - 120, 24);
        
        self.switchContentButton.frame = CGRectMake(self.av_width - 120, 0, 120, 24);
        self.switchContentButton.av_centerY = self.themeLabel.av_centerY;
        self.switchContentButton.selected = NO;
        
        self.contentView.frame = CGRectMake(0, self.themeLabel.av_bottom, self.av_width, self.av_height - 8 - 1 - self.themeLabel.av_height);
        [self setupContent];
        self.contentView.hidden = YES;
        self.contentView.av_height = 0;
        
        self.lineView.frame = CGRectMake(0, self.contentView.av_bottom + 8, self.av_width, 1);
    }
    return self;
}

- (void)setupContent {
    UILabel *appIDNameLabel = [self setupConfigInfoView:CGRectMake(0, 8, 100, 27) text:NSLocalizedString(@"AppID", nil) align:NSTextAlignmentLeft];
    [self.contentView addSubview:appIDNameLabel];
    
    self.appIDValueLabel = [self setupConfigInfoView:CGRectMake(appIDNameLabel.av_right, 8, self.contentView.av_width - appIDNameLabel.av_right, 27) text:@"" align:NSTextAlignmentRight];
    [self.contentView addSubview:self.appIDValueLabel];
    
    UILabel *appKeyNameLabel = [self setupConfigInfoView:CGRectMake(0, appIDNameLabel.av_bottom, 100, 27) text:NSLocalizedString(@"AppKey", nil) align:NSTextAlignmentLeft];
    [self.contentView addSubview:appKeyNameLabel];
    
    self.appKeyValueLabel = [self setupConfigInfoView:CGRectMake(appKeyNameLabel.av_right, appIDNameLabel.av_bottom, self.contentView.av_width - appKeyNameLabel.av_right, 27) text:@"" align:NSTextAlignmentRight];
    [self.contentView addSubview:self.appKeyValueLabel];
    
    UILabel *playDomainNameLabel = [self setupConfigInfoView:CGRectMake(0, appKeyNameLabel.av_bottom, 100, 27) text:AUILiveCommonString(@"播流域名") align:NSTextAlignmentLeft];
    [self.contentView addSubview:playDomainNameLabel];
    
    self.playDomainValueLabel = [self setupConfigInfoView:CGRectMake(playDomainNameLabel.av_right, appKeyNameLabel.av_bottom, self.contentView.av_width - playDomainNameLabel.av_right, 27) text:@"" align:NSTextAlignmentRight];
    [self.contentView addSubview:self.playDomainValueLabel];
    
    UIButton *modifyConfigButton = [UIButton buttonWithType:UIButtonTypeCustom];
    modifyConfigButton.frame = CGRectMake(self.contentView.av_centerX, playDomainNameLabel.av_bottom, self.contentView.av_width / 2.0, 24);
    [modifyConfigButton setImage:AUILiveCommonImage(@"ic_siggen_edit") forState:UIControlStateNormal];
    modifyConfigButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    modifyConfigButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [modifyConfigButton addTarget:self action:@selector(onClickModifyConfigButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:modifyConfigButton];
    
}

- (void)showAppID:(NSString *)appID appKey:(NSString *)appKey playDomain:(NSString *)playDomain {
    self.appIDValueLabel.text = appID;
    self.appKeyValueLabel.text = appKey;
    self.playDomainValueLabel.text = playDomain;
}

- (void)onClickSwitchContentButton:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.contentView.hidden = !sender.selected;
    if (sender.selected) {
        self.contentView.av_height = self.av_height - 8 - 1 - self.themeLabel.av_height;
        self.lineView.av_top = self.contentView.av_bottom;
    } else {
        self.contentView.av_height = 0;
        self.lineView.av_top = self.contentView.av_bottom + 8;
    }
}

- (void)onClickModifyConfigButton:(UIButton *)sender {
    if (self.modifyConfig) {
        self.modifyConfig();
    }
}

#pragma mark -- lazy load
- (UILabel *)themeLabel {
    if (!_themeLabel) {
        _themeLabel = [[UILabel alloc] init];
        _themeLabel.textColor = AUIFoundationColor(@"text_strong");
        _themeLabel.font = AVGetMediumFont(16);
    }
    return _themeLabel;
}

- (UIButton *)switchContentButton {
    if (!_switchContentButton) {
        _switchContentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_switchContentButton setImage:AUILiveCommonImage(@"ic_chevron_up") forState:UIControlStateNormal];
        [_switchContentButton setImage:AUILiveCommonImage(@"ic_chevron_down") forState:UIControlStateSelected];
        _switchContentButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _switchContentButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_switchContentButton addTarget:self action:@selector(onClickSwitchContentButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchContentButton;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = AUIFoundationColor(@"border_weak");
    }
    return _lineView;
}

- (void)setThemeName:(NSString *)themeName {
    _themeName = themeName;
    self.themeLabel.text = themeName;
    
}

- (UILabel *)setupConfigInfoView:(CGRect)frame text:(NSString *)text align:(NSTextAlignment)align {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.textAlignment = align;
    label.font = AVGetRegularFont(12);
    label.textColor = AUIFoundationColor(@"text_weak");
    return label;
}

@end
