//
//  AUIUgsvParamsViewController.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/14.
//

#import "AUIUgsvParamsViewController.h"
#import "AUIUgsvParamsView.h"
#import "AUIUgsvMacro.h"
#import "Masonry.h"

@interface AUIUgsvParamsViewController ()
@property (nonatomic, strong) AVBaseButton *confirmButton;
@property (nonatomic, strong) AUIUgsvParamsView *paramView;
@end

@implementation AUIUgsvParamsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup {
    // clear
    [_confirmButton removeFromSuperview];
    [_paramView removeFromSuperview];
    
    // create
    _confirmButton = [AVBaseButton TextButton];
    _confirmButton.layer.cornerRadius = 24.0;
    _confirmButton.layer.masksToBounds = YES;
    _confirmButton.backgroundColor = AUIFoundationColor(@"colourful_fill_strong");
    _confirmButton.font = AVGetRegularFont(18.0);
    _confirmButton.color = AUIFoundationColor(@"text_strong");
    __weak typeof(self) weakSelf = self;
    _confirmButton.action = ^(AVBaseButton *_) {
        if (weakSelf.onConfirm) {
            weakSelf.onConfirm(weakSelf);
        }
    };
    [self.contentView addSubview:_confirmButton];
    [_confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView).inset(20.0);
        make.bottom.equalTo(self.contentView).inset(42.0);
        make.height.mas_equalTo(48.0);
    }];
    
    _paramView = [AUIUgsvParamsView new];
    [self.contentView addSubview:_paramView];
    [_paramView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.contentView);
        make.bottom.equalTo(_confirmButton.mas_top).inset(20.0);
    }];
    
    // update
    self.hiddenMenuButton = YES;
    [self updateUI];
}

- (void)updateUI {
    self.titleView.text = self.titleText;
    self.confirmButton.title = self.confirmText;
    self.paramView.paramWrapper = self.paramWrapper;
}

- (void)setParamWrapper:(AUIUgsvParamWrapper *)paramWrapper {
    _paramWrapper = paramWrapper;
    [self updateUI];
}

- (void)setTitleText:(NSString *)titleText {
    _titleText = titleText;
    [self updateUI];
}

- (void)setConfirmText:(NSString *)confirmText {
    _confirmText = confirmText;
    [self updateUI];
}

@end
