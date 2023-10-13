//
//  AUILiveRtsPlayInputUrlView.m
//  AUILiveRtsPlay
//
//  Created by ISS013602000846 on 2022/8/1.
//

#import "AUILiveRtsPlayInputUrlView.h"
#import "AUILiveQRCodeViewController.h"

@interface AUILiveRtsPlayInputUrlView ()<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *themeLabel;
@property (nonatomic, strong) UITextField *inputField;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) UIViewController *sourceVC;
@property (nonatomic, assign) BOOL isEditing;

@end

@implementation AUILiveRtsPlayInputUrlView

- (instancetype)initWithFrame:(CGRect)frame sourceVC:(UIViewController *)sourceVC {
    if (self = [super initWithFrame:frame]) {
        self.sourceVC = sourceVC;
        
        [self addSubview:self.themeLabel];
        [self addSubview:self.inputField];
        [self addSubview:self.actionButton];
    
        self.themeLabel.frame = CGRectMake(0, 0, self.av_width, 24);
        
        self.actionButton.frame = CGRectMake(self.av_width - 5 - 18, 0, 18, 18);
        
        self.inputField.frame = CGRectMake(0, self.av_height - 36, self.actionButton.av_left - 12, 36);
        self.actionButton.av_centerY = self.inputField.av_centerY;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.av_height - 1, self.av_width, 1)];
        lineView.backgroundColor = AUIFoundationColor(@"border_weak");
        [self addSubview:lineView];
                
        [self addNotifications];
    }
    return self;
}

- (void)resignInputStatus {
    [self.inputField resignFirstResponder];
}

- (void)inputFieldValueChanged:(UITextField *)textField {
    if (textField.text.length == 0) {
        self.isEditing = NO;
        [self resignInputStatus];
    }
    
    if (self.inputChanged) {
        self.inputChanged(textField.text);
    }
}

- (void)pressActionButton {
    if (self.isEditing) {
        self.inputField.text = @"";
        if (self.inputChanged) {
            self.inputChanged(@"");
        }
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

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)keyboardWillShow:(NSNotification *)sender {
    self.isEditing = YES;
}

- (void)keyboardWillHide:(NSNotification *)sender {
    self.isEditing = NO;
}

- (void)setIsEditing:(BOOL)isEditing {
    _isEditing = isEditing;
    if (isEditing) {
        [_actionButton setImage:AUILiveCommonImage(@"field_close") forState:UIControlStateNormal];
    } else {
        [_actionButton setImage:AUILiveCommonImage(@"ic_scan") forState:UIControlStateNormal];
    }
}

#pragma mark -- UITextFieldDelegate
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
        _inputField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@" " attributes:@{
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
        [_actionButton setImage:AUILiveCommonImage(@"ic_scan") forState:UIControlStateNormal];
        [_actionButton addTarget:self action:@selector(pressActionButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _actionButton;
}

- (void)setThemeName:(NSString *)themeName {
    _themeName = themeName;
    self.themeLabel.text = themeName;
    
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.inputField.placeholder = placeholder;
}

@end
