//
//  AUILiveInputNumberView.m
//  AUILiveLinkMic
//
//  Created by ISS013602000846 on 2022/8/1.
//

#import "AUILiveInputNumberView.h"
#import "AUILiveQRCodeViewController.h"

#define ALLOWSTRSET @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
#define ALLOWEXTRASPECIALCHARACTERS @".-"

@interface AUILiveInputNumberView ()<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *themeLabel;
@property (nonatomic, strong) UITextField *inputField;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, assign) AUILiveInputNumberType type;
@property (nonatomic, strong) UIViewController *sourceVC;

@end

@implementation AUILiveInputNumberView

- (instancetype)initWithFrame:(CGRect)frame type:(AUILiveInputNumberType)type sourceVC:(UIViewController *)sourceVC {
    if (self = [super initWithFrame:frame]) {
        self.type = type;
        self.sourceVC = sourceVC;
        
        [self addSubview:self.themeLabel];
        [self addSubview:self.inputField];
        [self addSubview:self.actionButton];
    
        self.themeLabel.frame = CGRectMake(0, 0, self.av_width, 24);
        
        if (self.type == AUILiveInputNumberTypeInput) {
            self.actionButton.frame = CGRectMake(self.av_width - 5 - 15, 0, 15, 15);
        } else {
            self.actionButton.frame = CGRectMake(self.av_width - 5 - 18, 0, 18, 18);
        }
        
        self.inputField.frame = CGRectMake(0, self.av_height - 36, self.actionButton.av_left - 12, 36);
        self.actionButton.av_centerY = self.inputField.av_centerY;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.av_height - 1, self.av_width, 1)];
        lineView.backgroundColor = AUIFoundationColor(@"border_weak");
        [self addSubview:lineView];
        
        if (self.type == AUILiveInputNumberTypeInput) {
            self.actionButton.hidden = YES;
        }
    }
    return self;
}

- (void)resignInputStatus {
    [self.inputField resignFirstResponder];
}

- (void)inputFieldValueChanged:(UITextField *)textField {
    if (textField.text.length > 0) {
        self.actionButton.hidden = NO;
    } else {
        self.actionButton.hidden = YES;
    }
    
    if (self.inputChanged) {
        self.inputChanged(textField.text);
    }
}

- (void)pressActionButton {
    if (self.type == AUILiveInputNumberTypeInput) {
        self.inputField.text = @"";
        if (self.inputChanged) {
            self.inputChanged(@"");
        }
        self.actionButton.hidden = YES;
    } else {
        AUILiveQRCodeViewController *QRController = [[AUILiveQRCodeViewController alloc] init];
        __weak typeof(self) weakSelf = self;
        QRController.backValueBlock = ^(BOOL scaned, NSString *sweepString) {
            __strong typeof(self) strongSelf = weakSelf;
            if (sweepString) {
                strongSelf.inputField.text  = sweepString;
                if (strongSelf.inputChanged) {
                    strongSelf.inputChanged(sweepString);
                }
            }
        };
        [self.sourceVC.navigationController pushViewController:QRController animated:YES];
    }
    [self resignInputStatus];
}

#pragma mark -- UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@""] ||
        [string isEqualToString:@"\n"]) {
        return YES;
    }
    
    if (self.type == AUILiveInputNumberTypeInputAndScan) {
        if ([string isEqualToString:@"."]) {
            return YES;
        }
    }
    
    if (self.maxNumber != kAUILiveInputNotMaxNumer) {
        if (range.location > (self.maxNumber - 1)) {
            [AVToastView show:[NSString stringWithFormat:AUILiveCommonString(@"字符长度不能超过%d位"), self.maxNumber] view:self.sourceVC.view position:AVToastViewPositionMid];
            return NO;
        }
    }
    
    if (![ALLOWSTRSET containsString:string]) {
        if (self.isAllowExtraSpecialCharacters && [ALLOWEXTRASPECIALCHARACTERS containsString:string]) {
            return YES;
        }
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (self.inputChanged) {
        self.inputChanged(textField.text);
    }
    return YES;
}

#pragma mark -- lazy load
- (UILabel *)themeLabel {
    if (!_themeLabel) {
        _themeLabel = [[UILabel alloc] init];
        _themeLabel.textColor = AUIFoundationColor(@"text_strong");
        _themeLabel.font = AVGetMediumFont(16);
    }
    return _themeLabel;
}

- (UITextField *)inputField {
    if (!_inputField) {
        _inputField = [[UITextField alloc] init];
        _inputField.returnKeyType = UIReturnKeyDone;
        _inputField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:AUILiveCommonString(@"请输入字母、数字") attributes:@{
            NSForegroundColorAttributeName: AUIFoundationColor(@"text_ultraweak"),
            NSFontAttributeName: AVGetRegularFont(14)
        }];
        _inputField.textColor = AUIFoundationColor(@"text_medium");
        _inputField.delegate = self;
        _inputField.borderStyle = UITextBorderStyleNone;
        _inputField.font = AVGetRegularFont(15);
        _inputField.keyboardType = UIKeyboardTypeASCIICapable;
        [_inputField addTarget:self action:@selector(inputFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    }
    return _inputField;
}

- (UIButton *)actionButton {
    if (!_actionButton) {
        _actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (self.type == AUILiveInputNumberTypeInput) {
            [_actionButton setImage:AUILiveCommonImage(@"field_close") forState:UIControlStateNormal];
        } else {
            [_actionButton setImage:AUILiveCommonImage(@"ic_scan") forState:UIControlStateNormal];
        }
        [_actionButton addTarget:self action:@selector(pressActionButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _actionButton;
}

- (void)setThemeName:(NSString *)themeName {
    _themeName = themeName;
    self.themeLabel.text = themeName;
    
}

- (void)setDefaultInput:(NSString *)defaultInput {
    _defaultInput = defaultInput;
    self.inputField.text = defaultInput;
}

@end
