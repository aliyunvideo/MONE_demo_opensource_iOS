//
//  AUILiveIntercativeLinkCustomerView.m
//  AUILiveCommon
//
//  Created by ISS013602000846 on 2022/7/22.
//

#import "AUILiveIntercativeLinkCustomerView.h"

@interface AUILiveIntercativeLinkCustomerView ()

@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, strong) UIImageView *noPullView;
@property (nonatomic, strong) UIImageView *errorView;
@property (nonatomic, strong) UILabel *errorMsgView;

@end

@implementation AUILiveIntercativeLinkCustomerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.noPullView];
        self.noPullView.center = CGPointMake(CGRectGetWidth(frame) / 2.0, CGRectGetHeight(frame) / 2.0);
        
        [self addSubview:self.playerView];
        [self addSubview:self.errorView];
        
        [self addSubview:self.errorMsgView];
        self.errorMsgView.center = CGPointMake(CGRectGetWidth(frame) / 2.0, CGRectGetHeight(frame) / 2.0);
    }
    return self;
}

- (void)setCustomerStatus:(AUILiveLinkCustomerStatus)customerStatus {
    _customerStatus = customerStatus;
    switch (customerStatus) {
        case AUILiveLinkCustomerStatusNone:
        {
            self.noPullView.hidden = NO;
            self.playerView.hidden = YES;
            self.errorView.hidden = YES;
            self.errorMsgView.hidden = YES;
            [self bringSubviewToFront:self.noPullView];
        }
            break;
        case AUILiveLinkCustomerStatusPulling:
        {
            self.playerView.hidden = NO;
            self.noPullView.hidden = YES;
            self.errorView.hidden = YES;
            self.errorMsgView.hidden = YES;
            [self bringSubviewToFront:self.playerView];
        }
            break;
        case AUILiveLinkCustomerStatusError:
        {
            self.errorView.hidden = NO;
            self.errorMsgView.hidden = NO;
            self.noPullView.hidden = YES;
            self.playerView.hidden = YES;
            [self bringSubviewToFront:self.errorView];
            [self bringSubviewToFront:self.errorMsgView];
        }
            break;
        default:
            break;
    }
}

- (UIView *)getPlayerShow {
    return self.playerView;
}

#pragma mark -- lazy load
- (UIImageView *)noPullView {
    if (!_noPullView) {
        UIImage *placeholder = AUILiveCommonImage(@"customer_zhanwei");
        _noPullView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, placeholder.size.width, placeholder.size.height)];
        _noPullView.image = placeholder;
    }
    return _noPullView;
}

- (UIView *)playerView {
    if (!_playerView) {
        _playerView = [[UIView alloc] initWithFrame:self.bounds];
        _playerView.backgroundColor = AUIFoundationColor(@"fg_strong");
    }
    return _playerView;
}

- (UIImageView *)errorView {
    if (!_errorView) {
        UIImage *errorPlaceholder = [UIImage new];
        _errorView = [[UIImageView alloc] initWithFrame:self.bounds];
        _errorView.image = errorPlaceholder;
    }
    return _errorView;
}

- (UILabel *)errorMsgView {
    if (!_errorMsgView) {
        _errorMsgView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.av_width, 18)];
        _errorMsgView.text = AUILiveCommonString(@"出现异常");
        _errorMsgView.textColor = AUIFoundationColor(@"text_ultraweak");
        _errorMsgView.font = AVGetRegularFont(12);
        _errorMsgView.textAlignment = NSTextAlignmentCenter;
    }
    return _errorMsgView;
}

@end
