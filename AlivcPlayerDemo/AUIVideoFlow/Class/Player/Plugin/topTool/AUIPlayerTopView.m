//
//  AUIPlayerTopView.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/16.
//

#import "AUIPlayerTopView.h"
#import "AlivcPlayerAsset.h"


const static CGFloat kButtonSizeWidth = 26.f;

@interface AUIPlayerTopView()
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@end

@implementation AUIPlayerTopView

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
    [self.layer addSublayer:self.gradientLayer];
    [self addSubview:self.topActionView];
}


- (void)setLandScape:(BOOL)landScape
{
    if (_landScape != landScape) {
        _landScape = landScape;
        _topActionView.landScape = landScape;
        _statusBar.hidden = !landScape;
        if (landScape) {
            [self addSubview:self.statusBar];
            [self.statusBar updateData];
        }

    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _gradientLayer.frame = self.bounds;
    _statusBar.frame = CGRectMake(0, 0, self.av_width, self.landScape?24:0);
    _topActionView.frame = CGRectMake(0, _statusBar.av_bottom + (self.landScape?0:8), self.av_width, kButtonSizeWidth);
    [_topActionView updateUI:self.listening];
}

- (CAGradientLayer *)gradientLayer
{
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        UIColor *color1 = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        UIColor *color2 = [UIColor clearColor];
        _gradientLayer.colors = @[ (__bridge id) color1.CGColor,  (__bridge id) color2.CGColor];
    }
    return _gradientLayer;
}

- (AUIPlayerTopActionView *)topActionView
{
    if (!_topActionView) {
        _topActionView = [[AUIPlayerTopActionView alloc] init];
        _topActionView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"topActionView");
    }
    return _topActionView;;
}

- (AUIPlayerStatusBar *)statusBar
{
    if (!_statusBar) {
        _statusBar = [[AUIPlayerStatusBar alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, kButtonSizeWidth-2)];
        _statusBar.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"statusBar");
    }
    return _statusBar;
}
@end

