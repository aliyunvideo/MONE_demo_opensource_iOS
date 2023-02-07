//
//  AUIVideoTemplateEditTextInput.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/12/23.
//

#import "AUIVideoTemplateEditTextInput.h"
#import "AUIFoundation.h"
#import "AUIUgsvMacro.h"

@interface AUIVideoTemplateTextField : UITextField

@end

@implementation AUIVideoTemplateTextField

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 0);
}

@end

@interface AUIVideoTemplateEditTextInput () <UITextFieldDelegate>

@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) AUIVideoTemplateTextField *textField;

@property (nonatomic, copy) void (^completedBlock)(NSString *inputText);

@end

@implementation AUIVideoTemplateEditTextInput

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)]];
        
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, self.av_height - 45, self.av_width, 45)];
        container.backgroundColor = AUIFoundationColor(@"bg_weak");
        [self addSubview:container];
        self.container = container;
        
        CGFloat top = (container.av_height - 30) / 2.0;
        UIButton *ok = [[UIButton alloc] initWithFrame:CGRectMake(0, top, 30, 30)];
        [ok setImage:AUIUgsvTemplateImage(@"ic_text_input_confirm") forState:UIControlStateNormal];
        [ok addTarget:self action:@selector(onClickOK:) forControlEvents:UIControlEventTouchUpInside];
        ok.av_right = container.av_width - 16;
        [container addSubview:ok];
        
        UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(16, top, 30, 30)];
        [cancel setImage:AUIUgsvTemplateImage(@"ic_text_input_cancel") forState:UIControlStateNormal];
        [cancel addTarget:self action:@selector(onClickCancel:) forControlEvents:UIControlEventTouchUpInside];
        [container addSubview:cancel];
        
        AUIVideoTemplateTextField *textField = [[AUIVideoTemplateTextField alloc] initWithFrame:CGRectMake(cancel.av_right + 12, top, ok.av_left - cancel.av_right - 12 - 12, 30)];
        textField.backgroundColor = AUIFoundationColor(@"fill_weak");
        textField.textColor = AUIFoundationColor(@"text_strong");
        textField.font = AVGetRegularFont(12);
        textField.layer.cornerRadius = 15;
        textField.layer.masksToBounds = YES;
        textField.returnKeyType = UIReturnKeyDone;
        textField.delegate = self;
        [container addSubview:textField];
        self.textField = textField;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)onTap:(UITapGestureRecognizer *)recognizer {
    [self dismiss];
}

- (void)onClickOK:(UIButton *)sender {
    [self dismiss];
    if (self.completedBlock) {
        self.completedBlock(self.textField.text);
    }
}

- (void)onClickCancel:(UIButton *)sender {
    [self dismiss];
}

- (void)dismiss {
    [self resignFirstResponder];
    [self removeFromSuperview];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self onClickOK:nil];
    return YES;
}

#pragma mark - Notification

- (void)keyBoardWillShow:(NSNotification *)notification {
    if (!self.textField.isFirstResponder) {
        return;
    }
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:notification.userInfo];
    CGRect keyboardEndFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    self.container.transform = CGAffineTransformMakeTranslation(0, -keyboardEndFrame.size.height);
}

- (void)keyBoardWillHide:(NSNotification *)notification {
    self.container.transform = CGAffineTransformIdentity;
}

+ (void)show:(NSString *)text completed:(void (^)(NSString *inputText))completed {
    
    UIView *parentView = UIViewController.av_topViewController.view;
    AUIVideoTemplateEditTextInput *view = [[AUIVideoTemplateEditTextInput alloc] initWithFrame:parentView.bounds];
    view.completedBlock = completed;
    [parentView addSubview:view];
    view.textField.text = text;
    [view.textField becomeFirstResponder];
}

@end
