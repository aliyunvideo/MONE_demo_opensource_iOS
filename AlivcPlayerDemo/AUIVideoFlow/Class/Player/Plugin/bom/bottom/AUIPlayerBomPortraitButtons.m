//
//  AUIPlayerBomPortraitButtons.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/21.
//

#import "AUIPlayerBomPortraitButtons.h"
#import "AlivcPlayerAsset.h"
#import "AUIPlayerCustomImageButton.h"

@interface AUIPlayerBomPortraitButtons()
@property (nonatomic, strong) AUIPlayerCustomImageButton *fullScreenButton;
@end

@implementation AUIPlayerBomPortraitButtons

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
    [self addSubview:self.fullScreenButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.fullScreenButton.frame = CGRectMake(0, 0, self.av_width, self.av_height);

}

- (AUIPlayerCustomImageButton *)fullScreenButton
{
    if (!_fullScreenButton) {
        _fullScreenButton = [[AUIPlayerCustomImageButton alloc] initWithFrame:CGRectMake(12, 0, self.av_height, self.av_height)];
        _fullScreenButton.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"bomProtraitButton_fullScreenButton");
        _fullScreenButton.customSize = CGSizeMake(14, 14);

        [_fullScreenButton setImage:AUIVideoFlowImage(@"player_fullscreen") forState:UIControlStateNormal];
        
        [_fullScreenButton addTarget:self action:@selector(onFullscreenButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _fullScreenButton;
}

- (void)onFullscreenButtonClick:(id)sender
{
    if (self.onFullScreenBlock) {
        self.onFullScreenBlock();
    }
}

@end
