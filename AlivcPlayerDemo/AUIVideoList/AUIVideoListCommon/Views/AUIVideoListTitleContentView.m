//
//  AUIVideoListTitleContentView.m
//  AUIVideoList
//
//  Created by ISS013602000846 on 2022/6/7.
//

#import "AUIVideoListTitleContentView.h"

@interface AUIVideoListTitleContentView ()

@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UILabel *contentLabel;

@end

@implementation AUIVideoListTitleContentView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.contentLabel];
    }
    return self;
}

- (void)updateTitle:(NSString *)title content:(NSString *)content {
    self.titleLabel.text = title;
    self.contentLabel.text = content;
}

#pragma mark -- lazy load
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.av_width, 22)];
        _titleLabel.accessibilityIdentifier = AUIVideoListAccessibilityStr(@"titleLabel");
        _titleLabel.textColor = AUIVideoListColor(@"vl_slider_bg");
        _titleLabel.font = AVGetMediumFont(16);
    }
    return _titleLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.titleLabel.av_bottom + 2, self.av_width, 40)];
        _contentLabel.accessibilityIdentifier = AUIVideoListAccessibilityStr(@"contentLabel");
        _contentLabel.textColor = AUIVideoListColor(@"vl_subtext");
        _contentLabel.font = AVGetRegularFont(14);
        _contentLabel.numberOfLines = 2;
    }
    return _contentLabel;
}

@end
