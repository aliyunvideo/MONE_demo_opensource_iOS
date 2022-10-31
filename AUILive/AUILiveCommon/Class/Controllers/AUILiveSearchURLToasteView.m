//
//  AUILiveSearchURLToasteView.m
//  AUILiveCommon
//
//  Created by ISS013602000846 on 2022/7/25.
//

#import "AUILiveSearchURLToasteView.h"
#import "AUILiveQRCodeViewController.h"

@interface AUILiveSearchURLToasteView ()<UITextFieldDelegate>

@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITextField *inputTextField;

@end

@implementation AUILiveSearchURLToasteView

- (instancetype)init {
    if (self = [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
        self.av_top = AlivcScreenHeight;
        self.av_height = 0;
        self.backgroundColor = AUILiveCommonColor(@"ir_toaste_bg");
    }
    return self;
}

- (void)show {
    [UIView animateWithDuration:0.3 animations:^{
        self.av_top = 0;
        self.av_height = AlivcScreenHeight;
    }];
    
    if (!self.contentView.superview) {
        [self setupContentView];
        [self setupSearchView];
        [self setupStartButton];
    }
}

- (void)hide {
    [UIView animateWithDuration:0.3 animations:^{
        self.av_top = AlivcScreenHeight;
        self.av_height = 0;
    }];
}

- (void)setupContentView {
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMidY(self.bounds) - 60, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - (CGRectGetMidY(self.bounds) - 60))];
    self.contentView.backgroundColor = AUIFoundationColor(@"bg_weak");
    [self addSubview:self.contentView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchAction)];
    [self.contentView addGestureRecognizer:tap];
}

// 扫描框
- (void)setupSearchView {
    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(20, 20, CGRectGetWidth(self.contentView.bounds) - 20 * 2, 36)];
    searchView.backgroundColor = AUIFoundationColor(@"fg_strong");
    [searchView av_setLayerBorderColor:AUIFoundationColor(@"border_weak") borderWidth:1];
    [self.contentView addSubview:searchView];
    
    UIButton *scanButton = [[UIButton alloc] initWithFrame:CGRectMake(18, CGRectGetMidY(searchView.bounds) - 20 / 2, 20, 20)];
    [scanButton setImage:AUILiveCommonImage(@"ic_scan") forState:UIControlStateNormal];
    [scanButton addTarget:self action:@selector(scanUrl) forControlEvents:UIControlEventTouchUpInside];
    [searchView addSubview:scanButton];
    
    self.inputTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(scanButton.frame) + 8, 0, CGRectGetWidth(searchView.bounds) - 20 - (CGRectGetMaxX(scanButton.frame) + 8), CGRectGetHeight(searchView.bounds))];
    self.inputTextField.returnKeyType = UIReturnKeyDone;
    self.inputTextField.textColor = [UIColor whiteColor];
    self.inputTextField.delegate = self;
    self.inputTextField.borderStyle = UITextBorderStyleNone;
    self.inputTextField.font = AVGetRegularFont(16);
    self.inputTextField.tintColor = [UIColor whiteColor];
    self.inputTextField.keyboardType = UIKeyboardTypeURL;
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:AUILiveCommonString(@"请扫描或输入Url") attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:AVGetRegularFont(16)}];
    self.inputTextField.attributedPlaceholder = attrString;
    [searchView addSubview:self.inputTextField];
}

- (void)scanUrl {
    AUILiveQRCodeViewController *QRController = [[AUILiveQRCodeViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    QRController.backValueBlock = ^(BOOL scaned, NSString *sweepString) {
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf.exitQRPage) {
            strongSelf.exitQRPage();
        }
        
        [strongSelf.inputTextField resignFirstResponder];
        if (scaned) {
            if (sweepString) {
                strongSelf.inputTextField.text = sweepString;
                strongSelf.url = sweepString;
            }
        }
    };
    [UIViewController.av_topViewController.navigationController pushViewController:QRController animated:YES];
    
    if (self.enterQRPage) {
        self.enterQRPage();
    }
}

- (void)touchAction {
    [self.inputTextField resignFirstResponder];
}

- (void)setupStartButton {
    UIButton *startButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    startButton.frame = CGRectMake(20, CGRectGetHeight(self.contentView.bounds) - AVSafeBottom - 8 - 48, CGRectGetWidth(self.contentView.bounds) - 20 * 2, 48);
    [startButton setBackgroundColor:AUIFoundationColor(@"colourful_fill_strong")];
    [startButton setTitle:AUILiveCommonString(@"开始") forState:UIControlStateNormal];
    [startButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
    [startButton.titleLabel setFont:AVGetRegularFont(18)];
    [startButton.layer setMasksToBounds:YES];
    [startButton.layer setCornerRadius:24];
    [startButton addTarget:self action:@selector(clickStartButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:startButton];
}

- (void)clickStartButton:(UIButton *)sender {
    [self hide];
    if (self.goBack) {
        self.goBack(self.url);
    }
}

#pragma mark -- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *url = textField.text ?:@"";
    if (url.length == 0) {
        [AVToastView show:AUILiveCommonString(@"无效的URL") view:self position:AVToastViewPositionMid];
        return NO;
    }
    self.url = textField.text ?:@"";
    [textField resignFirstResponder];
    return YES;
}


@end
