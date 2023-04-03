//
//  AUIVideoListSlideIndicationView.m
//  AUIVideoList
//
//  Created by ISS013602000846 on 2022/6/7.
//

#import "AUIVideoListSlideIndicationView.h"

@interface AUIVideoListSlideIndicationView ()

@property (nonatomic,strong) UIView *superView;
@property (nonatomic,strong) UIImageView *handUpImageView;
@property (nonatomic,strong) UILabel *tip;

@end

@implementation AUIVideoListSlideIndicationView

- (instancetype)initOnView:(UIView *)view {
    if (self = [super init]) {
        self.superView = view;
        self.frame = CGRectMake(0, 0, view.av_width, 0);
        [self addSubview:self.handUpImageView];
        [self addSubview:self.tip];
        self.handUpImageView.av_centerX = self.tip.av_centerX;
        self.center = view.center;
        self.av_height = self.handUpImageView.av_height + 23 + self.tip.av_height;
    }
    return self;
}

- (void)updateShowStatus:(BOOL)isShow {
    if (isShow) {
        if (!self.superview) {
            [self.superView addSubview:self];
            [self.superView bringSubviewToFront:self];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self updateShowStatus:NO];
        });
    } else {
        if (self.superview) {
            [self removeFromSuperview];
        }
    }
}

#pragma mark -- lazy load
- (UIImageView *)handUpImageView {
    if (!_handUpImageView) {
        UIImage *handUpImage = AUIVideoListImage(@"ic_hand");
        _handUpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, handUpImage.size.width, handUpImage.size.height)];
        _handUpImageView.accessibilityIdentifier = AUIVideoListAccessibilityStr(@"handUpImageView");
        _handUpImageView.image = handUpImage;
    }
    return _handUpImageView;
}

- (UILabel *)tip {
    if (!_tip) {
        _tip = [[UILabel alloc] initWithFrame:CGRectMake(0, self.handUpImageView.av_height + 23, self.av_width, 24)];
        _tip.accessibilityIdentifier = AUIVideoListAccessibilityStr(@"tipLabel");
        _tip.textColor = AUIVideoListColor(@"vl_tiptext");
        _tip.font = AVGetMediumFont(16);
        _tip.textAlignment = NSTextAlignmentCenter;
        _tip.text = AUIVideoListString(@"Slideup_Tip");
    }
    return _tip;
}

@end
