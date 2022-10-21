//
//  AUIPanelStatusButtonView.m
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/2.
//

#import "AUIPanelStatusButtonView.h"
#import "AUIUgsvMacro.h"


static const CGFloat kButtonSize  = 30.f;

@interface AUIPanelStatusButtonView()

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *sureButton;

@end

@implementation AUIPanelStatusButtonView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.cancelButton];
        [self addSubview:self.sureButton];
    }
    return self;
}


- (UIButton *)cancelButton
{
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] init];
        _cancelButton.frame = CGRectMake(16, (self.av_height - kButtonSize)/2, kButtonSize, kButtonSize);
        [_cancelButton setImage: AUIUgsvEditorImage(@"ic_status_closemark") forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)sureButton
{
    if (!_sureButton) {
        _sureButton = [[UIButton alloc] init];
        _sureButton.frame = CGRectMake(self.av_width - kButtonSize - 16, (self.av_height - kButtonSize)/2, kButtonSize, kButtonSize);
        [_sureButton setImage: AUIUgsvEditorImage(@"ic_status_checkmark") forState:UIControlStateNormal];
        [_sureButton addTarget:self action:@selector(onSure:) forControlEvents:UIControlEventTouchUpInside];
    }

    return _sureButton;
}


- (void)onCancel:(id)sender
{
    if (self.onConfirmBlock) {
        self.onConfirmBlock();
    }
}

- (void)onSure:(id)onSure
{
    if (self.onCancelBlock) {
        self.onCancelBlock();
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
