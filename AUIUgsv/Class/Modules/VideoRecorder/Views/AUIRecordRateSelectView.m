//
//  AUIRecorderRateSelectView.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/2.
//

#import "AUIRecorderRateSelectView.h"
#import "AUIUgsvMacro.h"
#import "AVBaseButton.h"
#import "Masonry.h"

@interface AUIRecorderRateSelectView ()
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) UIView *selectedView;
@property (nonatomic, assign) uint8_t selectedIndex;
@property (nonatomic, strong) NSArray<UIButton *> *buttons;
@end

typedef struct {
    const char *name;
    CGFloat rate;
} RateInfo;
static const RateInfo RateInfos[] = {
    { "极慢", 0.5 },
    { "慢", 0.75 },
    { "标准", 1.0 },
    { "快", 1.5 },
    { "极快", 2.0 },
};
static const int RateCount = sizeof(RateInfos) / sizeof(RateInfos[0]);

@implementation AUIRecorderRateSelectView

- (instancetype) initWithDelegate:(id<AUIRecorderRateSelectViewDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        self.backgroundColor = AUIFoundationColor2(@"bg_weak", 0.8);
        self.layer.cornerRadius = 4.0;
        self.layer.masksToBounds = YES;

        self.rate = 1.0;
        _selectedView = [UIView new];
        _selectedView.backgroundColor = UIColor.whiteColor;
        _selectedView.layer.cornerRadius = 4.0;
        _selectedView.layer.masksToBounds = YES;
        [self setupStackView];
    }
    return self;
}

- (void) setRate:(CGFloat)rate {
    CGFloat dis = fabs(rate - RateInfos[0].rate);
    uint8_t idx = 0;
    for (int i = 1; i < RateCount; ++i) {
        CGFloat tmpDis = fabs(rate - RateInfos[i].rate);
        if (tmpDis < dis) {
            idx = i;
            dis = tmpDis;
        }
    }
    [self setSelectedIndex:idx animation:YES];
}
- (CGFloat) rate {
    return RateInfos[_selectedIndex].rate;
}

- (void) setupStackView {
    if (!_stackView) {
        [_stackView removeFromSuperview];
    }
    _stackView = [UIStackView new];
    _stackView.axis = UILayoutConstraintAxisHorizontal;
    _stackView.alignment = UIStackViewAlignmentCenter;
    _stackView.spacing = 0;
    _stackView.distribution = UIStackViewDistributionFillEqually;
    [self addSubview:_stackView];
    [_stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [_stackView insertSubview:_selectedView atIndex:0];
    

    NSMutableArray<UIButton *> *btns = @[].mutableCopy;
    for (int i = 0; i < RateCount; ++i) {
        UIButton *btn = [UIButton new];
        btn.backgroundColor = UIColor.clearColor;
        btn.titleLabel.font = AVGetRegularFont(14);
        btn.titleLabel.textAlignment =NSTextAlignmentCenter;
        NSString *title = AUIUgsvGetString(@(RateInfos[i].name));
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitle:title forState:UIControlStateSelected];
        [btn setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
        [btn setTitleColor:AUIFoundationColor(@"bg_weak") forState:UIControlStateSelected];
        btn.showsTouchWhenHighlighted = YES;
        btn.tag = i;
        [btn addTarget:self action:@selector(onBtnDidPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_stackView addArrangedSubview:btn];
        [btns addObject:btn];
    }
    _buttons = btns;
    [self setSelectedIndex:_selectedIndex animation:NO];
}

- (void) onBtnDidPressed:(UIButton *)btn {
    [self setSelectedIndex:(int)btn.tag animation:YES];
}

- (void) setSelectedIndex:(int)selectedIndex animation:(BOOL)animation {
    _selectedIndex = selectedIndex;
    if (_buttons.count == 0) {
        return;
    }
    
    for (UIButton *btn in _buttons) {
        btn.selected = (btn.tag == selectedIndex);
    }
    
    [_selectedView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.stackView).multipliedBy(1.0/RateCount);
        make.centerY.height.equalTo(self.stackView);
        make.centerX.equalTo(_buttons[selectedIndex]);
    }];

    if (animation) {
        [UIView animateWithDuration:0.2 animations:^{
            [self.stackView layoutIfNeeded];
        }];
    }
}

@end
