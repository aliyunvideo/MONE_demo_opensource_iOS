//
//  AUIPlayerLandScapeSpeedView.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/21.
//

#import "AUIPlayerLandScapeSpeedView.h"
#import <Masonry/Masonry.h>
#import "AlivcPlayerAsset.h"
#import "UIView+AUIPlayerHelper.h"

@interface AUIPlayerLandScapeSpeedView ()
@property (nonatomic, strong) UIButton *bgButton;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, copy) NSArray<NSString *> *dataList;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, weak) UIButton *currentSeletedButton;

@end

@implementation AUIPlayerLandScapeSpeedView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer addSublayer:self.gradientLayer];

        [self addSubview:self.bgButton];
        [self addSubview:self.contentView];
        
        [self.bgButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.equalTo(self);
            make.width.equalTo(@248);
        }];
        
        [self setupContentUI];
        
        self.gradientLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
    }
    return self;
}

- (UIButton *)bgButton
{
    if (!_bgButton) {
        _bgButton = [[UIButton alloc] init];
        _bgButton.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"bomLandScapeSpeed_bgButton");
        [_bgButton addTarget:self action:@selector(onBgButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bgButton;
}

- (void)onBgButtonClick:(id)sender
{
    [self removeFromSuperview];
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [UIView new];
        _contentView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"bomLandScapeSpeed_contentView");
    }
    return _contentView;
}


- (void)setupContentUI
{
    NSArray *dataList = @[@"2.0", @"1.5", @"1.25", @"1.0", @"0.75",@"0.5"];
    self.dataList = dataList;

    for (int i = 0; i< dataList.count; i++) {
        NSString *obj = [dataList objectAtIndex:i];
        NSString *title = [obj stringByAppendingString:@"X"];
        UIButton *button = [[UIButton alloc] init];
        NSString *buttonId = [NSString stringWithFormat:@"bomLandScapeSpeed_button_%d", i];
        button.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(buttonId);
        button.tag = i;
        [self.contentView addSubview:button];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [button setTitleColor:APGetColor(APColorTypeCyanBg) forState:UIControlStateSelected];
        button.titleLabel.font = AVGetRegularFont(16);
        [button addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.contentView.subviews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(22);
        make.left.right.equalTo(self.contentView);
    }];
    [self.contentView.subviews mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:10 leadSpacing:64 tailSpacing:64];
}

- (void)onButtonClick:(UIButton *)button
{
    [self removeFromSuperview];
    
    if (self.dataList.count > button.tag) {
        
        self.currentSeletedButton.selected = NO;
        self.currentSeletedButton = button;
        self.currentSeletedButton.selected = YES;
        
        NSString *string = [_dataList objectAtIndex:button.tag];
        if (self.onRateChanged) {
            self.onRateChanged(string.floatValue);
        }
    }
    
    
}

- (CAGradientLayer *)gradientLayer
{
    if (!_gradientLayer) {
        _gradientLayer =   [UIView bgGradientLayer];
    }
    return _gradientLayer;
}

- (void)updateSeletedRate:(float)rate
{
    self.currentSeletedButton.selected = NO;
    
    for (UIButton *button in self.contentView.subviews) {
        if (_dataList.count > button.tag) {
            NSString *string = [_dataList objectAtIndex:button.tag];
            if (string.floatValue == rate) {
                self.currentSeletedButton = button;
            }
        }
    }
    self.currentSeletedButton.selected = YES;
}

@end
