//
//  AUIPlayerLandScapeResolutionView.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/21.
//

#import "AUIPlayerLandScapeResolutionView.h"
#import <Masonry/Masonry.h>
#import "AlivcPlayerAsset.h"
#import "AlivcPlayerManager.h"
#import "UIView+AUIPlayerHelper.h"

@interface AUIPlayerLandScapeResolutionView ()
@property (nonatomic, strong) UIButton *bgButton;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, weak) UIButton *currentSeletedButton;

@end

@implementation AUIPlayerLandScapeResolutionView


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
        
        
        self.gradientLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
    }
    return self;
}

- (void)setDataList:(NSArray<AVPTrackInfo *> *)dataList
{
    if (dataList.count == 0) {
        return;
    }
    
    dataList =  [dataList sortedArrayUsingComparator:^NSComparisonResult(AVPTrackInfo *obj1, AVPTrackInfo *obj2) {
        return obj1.videoHeight < obj2.videoHeight;
    }];
    
    
    AVPTrackInfo *info = [[AVPTrackInfo alloc] init];
    info.trackIndex = -1;
    info.trackDefinition = @"AUTO";
    
    dataList = [dataList arrayByAddingObject:info];
    
    
    _dataList = [dataList copy];
    [self setupContentUI];
    
    
}

- (UIButton *)bgButton
{
    if (!_bgButton) {
        _bgButton = [[UIButton alloc] init];
        _bgButton.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"bomLandScapeResolution_bgButton");
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
        _contentView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"bomLandScapeResolution_contentView");
    }
    return _contentView;
}


- (void)setupContentUI
{
    NSArray *dataList = self.dataList;
    
    for (int i = 0; i< dataList.count; i++) {
        AVPTrackInfo *obj = [dataList objectAtIndex:i];
        NSString *title = [self formatBitrateTitleWithKey:obj.trackDefinition];
        title = [title stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        UIButton *button = [[UIButton alloc] init];
        button.tag = i;
      
        [self.contentView addSubview:button];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [button setTitleColor:APGetColor(APColorTypeCyanBg) forState:UIControlStateSelected];
        [button setTitleColor:UIColor.grayColor forState:UIControlStateDisabled];

        button.titleLabel.font = AVGetRegularFont(16);
        
        [button addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([title hasPrefix:@"1080P"]) {
            button.enabled = NO;
        }
    }
    
    [self.contentView.subviews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(22);
        make.left.right.equalTo(self.contentView);
    }];
    [self.contentView.subviews mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:10 leadSpacing:60 tailSpacing:60];
}

- (NSString *)formatBitrateTitleWithKey:(NSString *)key
{
    if (!key) {
        return  @"";
    }
    NSDictionary *dict = @{
        @"OD":@"1080P\n原画",
        @"HD":@"1080P\n超清",
        @"SD":@"720P\n高清",
        @"LD":@"480P\n清晰",
        @"FD":@"360P\n流畅",
        @"AUTO":@"720P\n自动",
    };
    
    NSString *value = dict[key];
    return value?:key;
}

- (void)onButtonClick:(UIButton *)button
{
    [self removeFromSuperview];
    
    if (self.dataList.count > button.tag) {
        
        self.currentSeletedButton.selected = NO;
        self.currentSeletedButton = button;
        self.currentSeletedButton.selected = YES;
        
        AVPTrackInfo *info = self.dataList[button.tag];
        if (self.onTrackChanged) {
            self.onTrackChanged(info);
        }
    }
    
    
}

- (CAGradientLayer *)gradientLayer
{
    if (!_gradientLayer) {
        _gradientLayer = [UIView bgGradientLayer];
        
    }
    return _gradientLayer;
}

- (void)updateCurrentSeleted:(AVPTrackInfo *)info
{
    self.currentSeletedButton.selected = NO;
    
    
    NSInteger index = self.dataList.count - 1;
    
    if (![AlivcPlayerManager manager].autoTrack) {
        for (int i = 0; i < self.dataList.count; i++) {
            AVPTrackInfo *track = [self.dataList objectAtIndex:i];
            if (track.trackDefinition && [info.trackDefinition isEqualToString:track.trackDefinition]) {
                index = i;
            }
        }
    }
    
    if (index >= 0 && self.contentView.subviews.count > index) {
        self.currentSeletedButton = self.contentView.subviews[index];
        
        self.currentSeletedButton.selected = YES;
    }
}

@end
