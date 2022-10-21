//
//  AUILiveLinkMicSelectRoleView.m
//  AUILiveLinkMic
//
//  Created by ISS013602000846 on 2022/8/1.
//

#import "AUILiveLinkMicSelectRoleView.h"

@interface AUILiveLinkMicSelectRoleView ()

@property (nonatomic, strong) UIView *anchorView;
@property (nonatomic, strong) UIView *audienceView;
@property (nonatomic, assign) AUILiveLinkMicSelectRoleType roleType;

@end

@implementation AUILiveLinkMicSelectRoleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.anchorView];
        [self addSubview:self.audienceView];
    }
    return self;
}

- (void)selectAnchor {
    self.roleType = AUILiveLinkMicSelectRoleTypeAnchor;
    if (self.selectRole) {
        self.selectRole(self.roleType);
    }
}

- (void)selectAudience {
    self.roleType = AUILiveLinkMicSelectRoleTypeAudience;
    if (self.selectRole) {
        self.selectRole(self.roleType);
    }
}

#pragma mark -- lazy load
- (UIView *)anchorView {
    if (!_anchorView) {
        _anchorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (self.av_width - 15) / 2.f, self.av_height)];
        _anchorView.backgroundColor = AUIFoundationColor(@"fill_weak");
        [self setSelectItemThemeName:AUILiveLinkMicString(@"主播") atView:_anchorView];
        [self setSelectItemThemeIcon:AUILiveLinkMicImage(@"item_anchor") atView:_anchorView];
        _anchorView.layer.cornerRadius = 12;
        [_anchorView av_setLayerBorderColor:AUIFoundationColor(@"border_weak") borderWidth:0.5];
        _anchorView.layer.masksToBounds = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectAnchor)];
        [_anchorView addGestureRecognizer:tap];
    }
    return _anchorView;
}

- (UIView *)audienceView {
    if (!_audienceView) {
        _audienceView = [[UIView alloc] initWithFrame:CGRectMake(self.anchorView.av_right + 15, 0, (self.av_width - 15) / 2.f, self.av_height)];
        _audienceView.backgroundColor = AUIFoundationColor(@"fill_weak");
        [self setSelectItemThemeName:AUILiveLinkMicString(@"观众") atView:_audienceView];
        [self setSelectItemThemeIcon:AUILiveLinkMicImage(@"item_anchor") atView:_audienceView];
        _audienceView.layer.cornerRadius = 12;
        [_audienceView av_setLayerBorderColor:AUIFoundationColor(@"border_weak") borderWidth:0.5];
        _audienceView.layer.masksToBounds = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectAudience)];
        [_audienceView addGestureRecognizer:tap];
    }
    return _audienceView;
}

- (void)setSelectItemThemeName:(NSString *)themeName atView:(UIView *)view {
    UILabel *themeNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 12, view.av_width - 20 * 2, 22)];
    themeNameLabel.text = themeName;
    themeNameLabel.textColor = AUIFoundationColor(@"text_strong");
    themeNameLabel.font = AVGetRegularFont(14);
    [view addSubview:themeNameLabel];
    
    UIImage *decorate = AUILiveLinkMicImage(@"item_decorate");
    UIImageView *decorateView = [[UIImageView alloc] initWithFrame:CGRectMake(20, themeNameLabel.av_bottom + 4, decorate.size.width, decorate.size.height)];
    decorateView.image = decorate;
    [view addSubview:decorateView];
}

- (void)setSelectItemThemeIcon:(UIImage *)icon atView:(UIView *)view {
    UIImageView *themeIconView = [[UIImageView alloc] initWithFrame:CGRectMake(view.av_width - 20 - icon.size.width, view.av_height - 12 - icon.size.height, icon.size.width, icon.size.height)];
    themeIconView.image = icon;
    [view addSubview:themeIconView];
}

- (void)setRoleType:(AUILiveLinkMicSelectRoleType)roleType {
    if (roleType != _roleType) {
        UIColor *unselectColor = AUIFoundationColor(@"border_weak");
        UIColor *selectColor = AUIFoundationColor(@"colourful_border_weak");
        if (roleType == AUILiveLinkMicSelectRoleTypeAnchor) {
            self.anchorView.layer.borderColor = selectColor.CGColor;
            self.audienceView.layer.borderColor = unselectColor.CGColor;
        } else if (roleType == AUILiveLinkMicSelectRoleTypeAudience) {
            self.anchorView.layer.borderColor = unselectColor.CGColor;
            self.audienceView.layer.borderColor = selectColor.CGColor;
        } else {
            self.anchorView.layer.borderColor = unselectColor.CGColor;
            self.audienceView.layer.borderColor = unselectColor.CGColor;
        }
        _roleType = roleType;
    }
}

@end
