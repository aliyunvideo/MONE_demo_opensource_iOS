//
//  AUIPlayerTopActionView.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/16.
//

#import "AUIPlayerTopActionView.h"
#import "AlivcPlayerAsset.h"

static CGFloat kMargrnX = 6.f;


const static CGFloat kButtonSizeWidth = 26.f;


@implementation AUIPlayerTopActionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    [self addSubview:self.backButton];
    [self addSubview:self.titleLabel];
    // 暂时注释功能
    [self addSubview:self.buttonsContainer];
    // 暂时注释功能
}

- (void)updateUI:(BOOL)listening
{
    if (listening) {
        self.titleLabel.hidden = !self.landScape;
        
        // zzy 20220630 暂时注释功能
        [self updateButtons:AUIPlayerTopViewButtonTypeNone];
        // zzy 20220630 暂时注释功能
    } else {
       self.titleLabel.hidden = !self.landScape;
        
        NSUInteger type = AUIPlayerTopViewButtonTypeListen;
        [self updateButtons:type];
    }

}

- (UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(kMargrnX, 0, kButtonSizeWidth, kButtonSizeWidth)];
        _backButton.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"backButton");
        [_backButton setImage:AUIVideoFlowImage(@"player_back") forState:UIControlStateNormal];
        
        [_backButton addTarget:self action:@selector(onBackButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _backButton;
}




- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"titleLabel");
        _titleLabel.numberOfLines = 1;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = AVGetRegularFont(16);
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
    }
    return _titleLabel;
}

- (UIView *)buttonsContainer
{
    if (!_buttonsContainer) {
        _buttonsContainer = [[UIView alloc] init];
        _buttonsContainer.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"buttonsContainer");
        _buttonsContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
    }
    return _buttonsContainer;
}

- (void)onBackButtonClick:(id)sender
{
    if (self.onBackButtonBlock) {
        self.onBackButtonBlock();
    }
}

- (void)setLandScape:(BOOL)landScape
{
    _landScape = landScape;
    kMargrnX = landScape ? 24 : 6;
}

- (void)updateButtons:(NSUInteger)types
{
    for (UIView *view in self.buttonsContainer.subviews) {
        [view removeFromSuperview];
        view.autoresizingMask = 0;
    }
    
    if (types == AUIPlayerTopViewButtonTypeNone) {
        return;
    }
    
    CGFloat left = 0;
    CGFloat spaceX = self.landScape?16:12;
    
    if (types & AUIPlayerTopViewButtonTypeListen) {
        UIButton *button = [self createButton:AUIPlayerTopViewButtonTypeListen];
        button.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"player_backmode");
        button.frame = CGRectMake(left, 0, kButtonSizeWidth, kButtonSizeWidth);
        [button setImage:AUIVideoFlowImage(@"player_backmode") forState:UIControlStateNormal];

        [self.buttonsContainer addSubview:button];
        left += button.bounds.size.width + spaceX;
        
    }
    
    if (self.buttonsContainer.subviews.count) {
        CGFloat width = left - spaceX;
        self.buttonsContainer.frame = CGRectMake(self.bounds.size.width - width - kMargrnX, 0, width, kButtonSizeWidth);
    }
    
    _backButton.frame = CGRectMake(kMargrnX, 0, kButtonSizeWidth, kButtonSizeWidth);
    
    CGFloat labelLeft = self.backButton.av_right;
    self.titleLabel.frame = CGRectMake(labelLeft, 0, self.buttonsContainer.frame.origin.x - labelLeft - 5, kButtonSizeWidth);
}

- (UIButton *)createButton:(int)type
{
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, kButtonSizeWidth, kButtonSizeWidth)];
    button.tag = type;
    [button addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)onButtonClick:(UIButton *)button
{
    if (self.onButtonBlock) {
        self.onButtonBlock(button.tag);
    }
    
}

@end
