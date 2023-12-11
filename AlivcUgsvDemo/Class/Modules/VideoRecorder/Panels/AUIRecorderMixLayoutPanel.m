//
//  AUIRecorderMixLayoutPanel.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/23.
//

#import "AUIRecorderMixLayoutPanel.h"
#import "AUIUgsvMacro.h"


@interface AUIRecorderMixLayoutPanel()

@property (nonatomic, assign) BOOL isInchanged;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, copy) NSArray<UIButton *> *buttonList;

@end

@implementation AUIRecorderMixLayoutPanel

// MARK: - UI
+ (CGFloat)panelHeight {
    return 186.0 + AVSafeBottom;
}

- (instancetype)initWithFrame:(CGRect)frame mixType:(AUIRecorderMixType)mixType {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup:mixType];
    }
    return self;
}

- (void)setup:(AUIRecorderMixType)mixType {
    self.titleView.text = AUIUgsvGetString(@"布局");
    self.showBackButton = NO;
    
    [self.menuButton setTitle:AUIUgsvGetString(@"交换") forState:UIControlStateNormal];
    [self.menuButton setImage:nil forState:UIControlStateNormal];
    
    UIButton *left_right = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    left_right.center = CGPointMake(20 + left_right.av_width, self.contentView.av_height / 2.0);
    [left_right setImage:AUIUgsvRecorderImage(@"ic_mix_left_right") forState:UIControlStateNormal];
    [left_right addTarget:self action:@selector(onClickMixButton:) forControlEvents:UIControlEventTouchUpInside];
    left_right.layer.borderColor = AUIFoundationColor(@"colourful_border_strong").CGColor;
    left_right.layer.cornerRadius = 2.0;
    [self.contentView addSubview:left_right];
    
    UIButton *top_bottom = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    top_bottom.center = CGPointMake(left_right.av_right + 10 + top_bottom.av_width, self.contentView.av_height / 2.0);
    [top_bottom setImage:AUIUgsvRecorderImage(@"ic_mix_top_bottom") forState:UIControlStateNormal];
    [top_bottom addTarget:self action:@selector(onClickMixButton:) forControlEvents:UIControlEventTouchUpInside];
    top_bottom.layer.borderColor = AUIFoundationColor(@"colourful_border_strong").CGColor;
    top_bottom.layer.cornerRadius = 2.0;
    [self.contentView addSubview:top_bottom];
    
    UIButton *back_front = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    back_front.center = CGPointMake(top_bottom.av_right + 10 + back_front.av_width, self.contentView.av_height / 2.0);
    [back_front setImage:AUIUgsvRecorderImage(@"ic_mix_back_front") forState:UIControlStateNormal];
    [back_front addTarget:self action:@selector(onClickMixButton:) forControlEvents:UIControlEventTouchUpInside];
    back_front.layer.borderColor = AUIFoundationColor(@"colourful_border_strong").CGColor;
    back_front.layer.cornerRadius = 2.0;
    [self.contentView addSubview:back_front];
    
    _buttonList = @[left_right, top_bottom, back_front];
    
    _isInchanged = mixType % 2;
    _selectedIndex = mixType / 2;
    [_buttonList objectAtIndex:_selectedIndex].layer.borderWidth = 1.0;
}

- (void)onClickMixButton:(UIButton *)btn {
    NSInteger oldIndex = [_buttonList indexOfObject:btn];
    if (oldIndex == _selectedIndex) {
        return;
    }
    UIButton *old = [_buttonList objectAtIndex:_selectedIndex];
    _selectedIndex = oldIndex;
    old.layer.borderWidth = 0;
    btn.layer.borderWidth = 1;
    [self raiseMixTypeChanged];
}

- (void)onMenuBtnClicked:(UIButton *)sender {
    _isInchanged = !_isInchanged;
    [self raiseMixTypeChanged];
}

- (void)raiseMixTypeChanged {
    AUIRecorderMixType type = (AUIRecorderMixType)(_selectedIndex * 2 + (_isInchanged ? 1 : 0));
    if (_onMixTypeChanged) {
        _onMixTypeChanged(type);
    }
}

@end
