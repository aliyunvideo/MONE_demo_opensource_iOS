//
//  AUILiveInputNumberAlert.m
//  AUILiveLinkMic
//
//  Created by ISS013602000846 on 2022/8/2.
//

#import "AUILiveInputNumberAlert.h"
#import "AVToastView.h"

#define ALLOWSTRSET @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

@interface AUILiveInputNumberAlert ()<UITextFieldDelegate>

@property (nonatomic, strong) NSArray<NSString *> *messages;
@property (nonatomic, assign) NSInteger maxNumber;
@property (nonatomic, strong) UIView *sourceView;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *actionView;
@property (nonatomic, strong) UIButton *okButton;

@property (nonatomic, strong) NSMutableArray<UITextField *> *inputs;
@property (nonatomic, copy) void(^inputAction)(BOOL ok, NSArray<NSString *> *inputs);

@end

@implementation AUILiveInputNumberAlert

- (instancetype)init {
    if (self = [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
        self.av_top = AlivcScreenHeight;
        self.av_height = 0;
        self.backgroundColor = AUILiveCommonColor(@"ir_toaste_bg");
        self.inputs = [NSMutableArray array];
    }
    return self;
}

+ (void)show:(NSArray<NSString *> *)messages view:(UIView *)view maxNumber:(NSInteger)maxNumber inputAction:(void(^)(BOOL ok, NSArray<NSString *> *inputs))inputAction {
    AUILiveInputNumberAlert *alertView = [[AUILiveInputNumberAlert alloc] init];
    alertView.sourceView = view;
    alertView.messages = messages;
    alertView.maxNumber = maxNumber;
    alertView.inputAction = inputAction;
    [view addSubview:alertView];
    [alertView show];
}

- (void)show {
    [UIView animateWithDuration:0.3 animations:^{
        self.av_top = 0;
        self.av_height = AlivcScreenHeight;
    }];
    
    self.contentView.backgroundColor = AUIFoundationColor(@"fg_strong");
    self.okButton.enabled = NO;
}

- (void)hide {
    [UIView animateWithDuration:0.3 animations:^{
        self.av_top = AlivcScreenHeight;
        self.av_height = 0;
    }];
    [self removeFromSuperview];
}

- (void)pressCancel {
    [self hide];
    if (self.inputAction) {
        self.inputAction(NO, @[]);
    }
}

- (void)pressOK {
    [self hide];
    if (self.inputAction) {
        NSMutableArray *inputInfos = [NSMutableArray array];
        for (int i = 0; i < self.inputs.count; i++) {
            UITextField *input = self.inputs[i];
            [inputInfos addObject:input.text];
        }
        
        self.inputAction(YES, inputInfos);
    }
}

- (BOOL)okButtonEnabled {
    if (self.inputs.count == self.messages.count) {
        for (UITextField *input in self.inputs) {
            if (input.text.length == 0) {
                return NO;
            }
        }
    }
    return YES;
}

- (void)inputEditingChanged:(UITextField *)textField {
    BOOL okButtonEnabled = [self okButtonEnabled];
    if (self.okButton.enabled != okButtonEnabled) {
        self.okButton.enabled = okButtonEnabled;
        if (okButtonEnabled) {
            [self.okButton setTitleColor:AUIFoundationColor(@"colourful_fill_strong") forState:UIControlStateNormal];
        } else {
            [self.okButton setTitleColor:AUILiveCommonColor(@"ir_button_unenable") forState:UIControlStateNormal];
        }
    }
}

#pragma mark -- UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@""] ||
        [string isEqualToString:@"\n"]) {
        return YES;
    }
    
    if (self.maxNumber != kAUILiveInputAlertNotMaxNumer) {
        if (range.location > (self.maxNumber - 1)) {
            [AVToastView show:[NSString stringWithFormat:AUILiveCommonString(@"字符长度不能超过%d位"), self.maxNumber] view:self.sourceView position:AVToastViewPositionMid];
            return NO;
        }
    }
    
    if (![ALLOWSTRSET containsString:string]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    BOOL okButtonEnabled = [self okButtonEnabled];
    if (okButtonEnabled) {
        [self pressOK];
    }
    
    return YES;
}

#pragma mark -- lazy load
- (UIView *)contentView {
    if (!_contentView) {
        CGFloat inputHeight = self.messages.count * 32 + (self.messages.count - 1) * 16;
        
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(32, (self.av_height - 94 - inputHeight) / 2.0, self.av_width - 32 * 2, 94 + inputHeight)];
        _contentView.backgroundColor = AUIFoundationColor(@"fg_strong");
        _contentView.layer.cornerRadius = 16;
        _contentView.layer.masksToBounds = YES;
        [self addSubview:_contentView];
        
        UIView *inputView = [[UIView alloc] initWithFrame:CGRectMake(24, self.actionView.av_top - 24 - inputHeight, self.contentView.av_width - 24 * 2, inputHeight)];
        [_contentView addSubview:inputView];
        
        for (int i = 0; i < self.messages.count; i++) {
            UIView *inputContentView = [[UIView alloc] initWithFrame:CGRectMake(0, i * (16 + 32), inputView.av_width, 32)];
            inputContentView.layer.borderColor = AUIFoundationColor(@"border_weak").CGColor;
            inputContentView.layer.borderWidth = 1;
            inputContentView.layer.cornerRadius = 2;
            [inputView addSubview:inputContentView];
            
            UITextField *inputField = [[UITextField alloc] initWithFrame:CGRectMake(12, 0, inputView.av_width - 12 * 2, inputContentView.av_height)];
            inputField.returnKeyType = UIReturnKeyDone;
            inputField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.messages[i] attributes:@{
                NSForegroundColorAttributeName: AUIFoundationColor(@"text_ultraweak"),
                NSFontAttributeName: AVGetRegularFont(14)
            }];
            inputField.textColor = AUIFoundationColor(@"text_medium");
            inputField.borderStyle = UITextBorderStyleNone;
            inputField.font = AVGetRegularFont(15);
            inputField.keyboardType = UIKeyboardTypeASCIICapable;
            inputField.tag = 1000 + i;
            inputField.delegate = self;
            [inputField addTarget:self action:@selector(inputEditingChanged:) forControlEvents:UIControlEventEditingChanged];
            [inputContentView addSubview:inputField];
            
            if (i == 0) {
                [inputField becomeFirstResponder];
            }
            
            [self.inputs addObject:inputField];
        }
    }
    return _contentView;
}

- (UIView *)actionView {
    if (!_actionView) {
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentView.av_height - 48 - 1, self.contentView.av_width, 1)];
        topLine.backgroundColor = AUIFoundationColor(@"border_weak");
        [self.contentView addSubview:topLine];
        
        _actionView = [[UIView alloc] initWithFrame:CGRectMake(0, topLine.av_bottom, self.contentView.av_width, 47)];
        [self.contentView addSubview:_actionView];
    
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(0, 0, _actionView.av_width / 2.0 - 1, _actionView.av_height);
        [cancelButton setTitle:AUILiveCommonString(@"取消") forState:UIControlStateNormal];
        [cancelButton setTitleColor:AUIFoundationColor(@"text_weak") forState:UIControlStateNormal];
        cancelButton.titleLabel.font = AVGetRegularFont(16);
        [cancelButton addTarget:self action:@selector(pressCancel) forControlEvents:UIControlEventTouchUpInside];
        [_actionView addSubview:cancelButton];
        
        UIView *midLine = [[UIView alloc] initWithFrame:CGRectMake(cancelButton.av_right, 0, 1, _actionView.av_height)];
        midLine.backgroundColor = AUIFoundationColor(@"border_weak");
        [_actionView addSubview:midLine];
        
        self.okButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _okButton.frame = CGRectMake(_actionView.av_width / 2.0 + 1, 0, _actionView.av_width / 2.0 - 1, _actionView.av_height);
        [_okButton setTitle:AUILiveCommonString(@"确定") forState:UIControlStateNormal];
        [_okButton setTitleColor:AUILiveCommonColor(@"ir_button_unenable") forState:UIControlStateNormal];
        _okButton.titleLabel.font = AVGetRegularFont(16);
        [_okButton addTarget:self action:@selector(pressOK) forControlEvents:UIControlEventTouchUpInside];
        [_actionView addSubview:_okButton];
    }
    return _actionView;
}

@end
