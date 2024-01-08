//
//  AUILiveWatermarkSettingView.m
//  AlivcLivePusherTest
//
//  Created by TripleL on 2017/10/12.
//  Copyright © 2017年 TripleL. All rights reserved.
//

#import "AUILiveWatermarkSettingView.h"

#define kAlivcWaterSettingIndex 3
#define kAlivcWaterSettingLabelWidth AlivcSizeWidth(25)
#define kAlivcWaterSettingRetract 10

@interface AUILiveWatermarkSettingDrawView ()

@property (nonatomic, strong) AUILiveWatermarkSettingView *param1;
@property (nonatomic, strong) AUILiveWatermarkSettingView *param2;
@property (nonatomic, strong) AUILiveWatermarkSettingView *param3;
@property (nonatomic, assign) BOOL isEditing;

@end

@implementation AUILiveWatermarkSettingDrawView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
        [self addNotifications];
    }
    return self;
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)setupSubViews {
    
    self.backgroundColor = AUILiveCommonColor(@"ir_watermarksetting_bg");
    self.isEditing = NO;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(kAlivcWaterSettingRetract, kAlivcWaterSettingRetract, 100, kAlivcWaterSettingLabelWidth);
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont systemFontOfSize:14.f];
    titleLabel.text = AUILiveCommonString(@"水印设置");
    [self addSubview:titleLabel];
    
    CGFloat watermarkCount = 3;
    CGFloat viewWidth = self.bounds.size.width;
    CGFloat viewHeight = (self.bounds.size.height - CGRectGetMaxY(titleLabel.frame)) / watermarkCount;
    
    self.param1 = [[AUILiveWatermarkSettingView alloc] initWithFrame:(CGRectMake(0, CGRectGetMaxY(titleLabel.frame), viewWidth, viewHeight))
                                                    defaultValue:@[@"0.1",@"0.1",@"0.15"]];
    [self.param1.switcher setOn:YES];
    
    self.param2 = [[AUILiveWatermarkSettingView alloc] initWithFrame:(CGRectMake(0, CGRectGetMaxY(titleLabel.frame)+viewHeight*1, viewWidth, viewHeight))
                                                    defaultValue:@[@"0.1",@"0.3",@"0.15"]];
    
    self.param3 = [[AUILiveWatermarkSettingView alloc] initWithFrame:(CGRectMake(0, CGRectGetMaxY(titleLabel.frame)+viewHeight*2, viewWidth, viewHeight))
                                                    defaultValue:@[@"0.1",@"0.5",@"0.15"]];
    
    [self addSubview:self.param1];
    [self addSubview:self.param2];
    [self addSubview:self.param3];

    
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



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    [self endEditing:YES];
}

- (void)keyboardWillShow:(NSNotification *)sender {
    
    CGRect keyboardFrame = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.isEditing = YES;
    
    [UIView animateWithDuration:0.2f animations:^{
        CGRect frame = self.frame;
        frame.origin.y = keyboardFrame.origin.y - frame.size.height;
        self.frame = frame;
    }];
    
}

- (void)keyboardWillHide:(NSNotification *)sender {

    self.isEditing = NO;
    
    [UIView animateWithDuration:0.2f animations:^{
        CGRect frame = self.frame;
        frame.origin.y = AlivcScreenHeight - frame.size.height;
        self.frame = frame;
    }];
}


- (BOOL)isEditing {
    
    return _isEditing;
}


- (AlivcWatermarkSettingStruct)getWatermarkSettingsWithCount:(NSInteger)index {
    
    if (index == 1) {
        return [self.param1 getWatermarkSetting];
    } else if (index == 2) {
        return [self.param2 getWatermarkSetting];
    } else {
        return [self.param3 getWatermarkSetting];
    }
}


@end


@implementation AUILiveWatermarkSettingView


- (instancetype)initWithFrame:(CGRect)frame defaultValue:(NSArray<NSString *> *)defaultValues {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviewsWithDefaultValue:defaultValues];
    }
    return self;
}


- (void)setupSubviewsWithDefaultValue:(NSArray<NSString *> *)defaultValues {
    
    self.switcher = [[UISwitch alloc] initWithFrame:(CGRectMake(0, 0, kAlivcWaterSettingLabelWidth * 2, kAlivcWaterSettingLabelWidth))];
    self.switcher.center = CGPointMake(self.switcher.center.x, self.bounds.size.height/2);
//    [self addSubview:self.switcher];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.frame = CGRectMake(0, self.bounds.size.height - 1, self.bounds.size.width, 1);
    lineView.backgroundColor = [UIColor blackColor];
    [self addSubview:lineView];
    
    NSArray *nameArray = @[@"x",@"y",@"w"];
    
    for (int index = 0; index < kAlivcWaterSettingIndex; index++) {
        
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.frame = CGRectMake(CGRectGetMaxX(self.switcher.frame) + kAlivcWaterSettingRetract,
                                     (kAlivcWaterSettingRetract+kAlivcWaterSettingLabelWidth)*index,
                                     kAlivcWaterSettingLabelWidth,
                                     kAlivcWaterSettingLabelWidth);
        nameLabel.textAlignment = NSTextAlignmentRight;
        nameLabel.font = [UIFont systemFontOfSize:14.f];
        nameLabel.text = nameArray[index];
        
        UITextField *textField = [[UITextField alloc] init];
        textField.frame = CGRectMake(CGRectGetMaxX(nameLabel.frame) + kAlivcWaterSettingRetract,
                                     CGRectGetMinY(nameLabel.frame),
                                     AlivcSizeWidth(220),
                                     CGRectGetHeight(nameLabel.frame));
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.placeholder = @"0";
        textField.text = defaultValues[index];
        textField.font = [UIFont systemFontOfSize:14.f];
        textField.clearsOnBeginEditing = YES;
        
        [self addSubview:nameLabel];
        [self addSubview:textField];
        
        switch (index) {
            case 0:
                self.xTextField = textField;
                break;
            case 1:
                self.yTextField = textField;
                break;
            case 2:
                self.wTextField = textField;
                break;
            default:
                break;
        }
    }
}

- (AlivcWatermarkSettingStruct)getWatermarkSetting {
    
    AlivcWatermarkSettingStruct setting;
    setting.watermarkX = [self.xTextField.text floatValue];
    setting.watermarkY = [self.yTextField.text floatValue];
    setting.watermarkWidth = [self.wTextField.text floatValue];
    
    return setting;
}

@end
