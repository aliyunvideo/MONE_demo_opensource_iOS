//
//  AUIPlayerSpeedTipView.m
//  AUIVideoFlow
//
//  Created by ISS013602000846 on 2022/6/21.
//

#import "AUIPlayerSpeedTipView.h"
#import "AlivcPlayerManager.h"

@interface AUIPlayerSpeedTipView ()

@property (nonatomic, strong) UIImageView *tipImage;
@property (nonatomic, strong) UIImageView *handImage;
@property (nonatomic, strong) UILabel *tip;
@property (nonatomic, strong) UIButton *close;

@end

@implementation AUIPlayerSpeedTipView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.tipImage.frame = CGRectMake(0, 0, 117, 117);
        [self addSubview:self.tipImage];
        self.handImage.frame = CGRectMake(0, 23, 15.4, 16.2);
        [self.tipImage addSubview:self.handImage];
        self.tip.frame = CGRectMake(0, self.handImage.av_bottom + 7, self.tipImage.av_width, self.tipImage.av_height - self.handImage.av_bottom - 7);
        [self.tipImage addSubview:self.tip];
        self.handImage.av_centerX = self.tip.av_centerX;
        self.close.frame = CGRectMake(self.tipImage.av_right, 0, 28, 28);
        [self addSubview:self.close];
    }
    return self;
}

- (UIImageView *)tipImage {
    if (!_tipImage) {
        _tipImage = [[UIImageView alloc] init];
        _tipImage.image = AUIVideoFlowImage(@"ic_speed_qipao");
        _tipImage.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"tipImage");
    }
    return _tipImage;
}

- (UIImageView *)handImage {
    if (!_handImage) {
        _handImage = [[UIImageView alloc] init];
        _handImage.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"handImage");
        _handImage.image = AUIVideoFlowImage(@"ic_speed_hand");
    }
    return _handImage;
}

- (UILabel *)tip {
    if (!_tip) {
        _tip = [[UILabel alloc] init];
        _tip.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"speed_tip");
        _tip.font = AVGetRegularFont(14);
        _tip.textAlignment = NSTextAlignmentCenter;
        _tip.numberOfLines = 2;
        
        NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:AUIVideoFlowString(@"长按屏幕\n快进") attributes:@{
            NSForegroundColorAttributeName: AUIVideoFlowColor(@"vf_tip_text")
        }];
        [attriStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"2X" attributes:@{
            NSForegroundColorAttributeName: AUIVideoFlowColor(@"vf_time_progress")
        }]];
        _tip.attributedText = attriStr;
    }
    return _tip;
}

- (UIButton *)close {
    if (!_close) {
        _close = [UIButton buttonWithType:UIButtonTypeCustom];
        _close.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"speed_close");
        [_close setImage:AUIVideoFlowImage(@"ic_speed_close") forState:UIControlStateNormal];
        [_close addTarget:self action:@selector(onClickCloseAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _close;
}

- (void)onClickCloseAction:(UIButton *)button {
    [self removeFromSuperview];
    if (self.closeAction) {
        self.closeAction();
    }
}

@end
