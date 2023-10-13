//
//  AUILiveIntercativeBgStatusView.m
//  AUILiveLinkMic
//
//  Created by ISS013602000846 on 2022/8/3.
//

#import "AUILiveIntercativeBgStatusView.h"

@interface AUILiveIntercativeBgStatusView ()

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UILabel *statusLabel;

@end

@implementation AUILiveIntercativeBgStatusView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.bgImageView];
        [self addSubview:self.statusLabel];
    }
    return self;
}

- (void)setBgImage:(UIImage *)bgImage {
    _bgImage = bgImage;
    self.bgImageView.image = bgImage;
}

- (void)setStatus:(NSString *)status {
    _status = status;
    if (status && status.length > 0) {
        self.statusLabel.hidden = NO;
        self.statusLabel.text = status;
    } else {
        self.statusLabel.hidden = YES;
        self.statusLabel.text = @"";
    }
}

#pragma mark -- lazy load
- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    }
    return _bgImageView;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (CGRectGetHeight(self.bounds) - 30) / 2.0, self.av_width, 30)];
        _statusLabel.textColor = AUIFoundationColor(@"text_ultraweak");
        _statusLabel.font = AVGetRegularFont(20);
        _statusLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _statusLabel;
}

@end
