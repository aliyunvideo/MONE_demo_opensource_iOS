//
//  AUIUgsvParamCell.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/13.
//

#import "AUIUgsvParamCell.h"
#import "AUIUgsvMacro.h"
#import "Masonry.h"

@interface AUIUgsvParamCell ()<AUIUgsvParamItemModelDelegate>
@property (nonatomic, strong) UILabel *label;
@end

@implementation AUIUgsvParamCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

// MARK: - AUIUgsvParamItemModelDelegate
- (void) onAUIUgsvParamItemModelDidChange:(AUIUgsvParamItemModel *)model {
    [self updateValue];
}

- (void)setModel:(AUIUgsvParamItemModel *)model {
    if (_model == model) {
        return;
    }
    if (_model.delegate == self) {
        _model.delegate = nil;
    }
    _model = model;
    _model.delegate = self;
    [self updateValue];
}

- (void)setup {
    [_label removeFromSuperview];
    
    _label = [UILabel new];
    _label.backgroundColor = UIColor.clearColor;
    _label.font = AVGetRegularFont(15.0);
    _label.textColor = AUIFoundationColor(@"text_strong");
    [self.contentView addSubview:_label];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).inset(20.0);
        make.centerY.equalTo(self.contentView);
    }];
    self.backgroundColor = AUIFoundationColor(@"bg_weak");
    
    UIView *line = [UIView new];
    line.backgroundColor = AUIFoundationColor(@"border_medium");
    [self.contentView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1.0);
        make.bottom.right.equalTo(self.contentView);
        make.left.equalTo(self.contentView).inset(20.0);
    }];
}

- (void)updateValue {
    _label.text = _model.label;
    [self updateUIForEditabled:_model.editabled];
}

- (void)updateUIForEditabled:(BOOL)enabled {}

@end

// MARK: - AUIUgsvParamSwitchCell
@interface AUIUgsvParamSwitchCell ()
@property (nonatomic, strong) UISwitch *switchBtn;
@end

@implementation AUIUgsvParamSwitchCell

- (AUIUgsvParamItemSwitch *)switchModel {
    return (AUIUgsvParamItemSwitch *)self.model;
}

- (void)updateValue {
    [super updateValue];
    
    [_switchBtn setOn:self.switchModel.isOn];
    _switchBtn.thumbTintColor = _switchBtn.isOn ? AUIFoundationColor(@"fill_infrared") : AUIFoundationColor(@"fill_strong");
}

- (void)setup {
    [super setup];
    
    // clear
    [_switchBtn removeFromSuperview];
    
    // create
    _switchBtn = [UISwitch new];
    _switchBtn.onTintColor = AUIFoundationColor(@"colourful_fg_strong");
    _switchBtn.tintColor = AUIFoundationColor(@"fill_weak");
    [self.contentView addSubview:_switchBtn];
    [_switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).inset(20.0);
        make.centerY.equalTo(self.contentView);
    }];
    [_switchBtn addTarget:self
                   action:@selector(onSwitchChanged:)
         forControlEvents:UIControlEventValueChanged];
    
    // update
    [self updateValue];
}

- (void)updateUIForEditabled:(BOOL)enabled {
    [super updateUIForEditabled:enabled];
    _switchBtn.enabled = enabled;
}

- (void) onSwitchChanged:(UISwitch *)switchBtn {
    self.switchModel.isOn = switchBtn.isOn;
    [self updateValue];
}
@end

// MARK: - AUIUgsvParamTextFieldCell
@interface AUIUgsvParamTextFieldCell () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UILabel *unitLabel;
@end

@implementation AUIUgsvParamTextFieldCell

- (AUIUgsvParamItemTextField *)textFieldModel {
    return (AUIUgsvParamItemTextField *)self.model;
}

- (void)setup {
    [super setup];
    
    // clear
    [_textField removeFromSuperview];
    [_unitLabel removeFromSuperview];
    
    // create
    _unitLabel = [UILabel new];
    _unitLabel.font = AVGetRegularFont(11.0);
    _unitLabel.textColor = AUIFoundationColor(@"text_medium");
    [self.contentView addSubview:_unitLabel];
    [_unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).inset(20.0);
        make.centerY.equalTo(self.contentView);
    }];
    [_unitLabel setContentHuggingPriority:1000 forAxis:UILayoutConstraintAxisHorizontal];

    _textField = [UITextField new];
    _textField.delegate = self;
    _textField.backgroundColor = UIColor.clearColor;
    _textField.font = AVGetRegularFont(14.0);
    _textField.textColor = AUIFoundationColor(@"text_medium");
    _textField.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_textField];
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).inset(112.0);
        make.top.bottom.equalTo(self.contentView).inset(12.0);
        make.right.equalTo(_unitLabel.mas_left).inset(4.0);
    }];
    
    // update
    [self updateValue];
}

- (void)updateValue {
    [super updateValue];
    
    AUIUgsvParamItemTextField *textFieldModel = self.textFieldModel;
    if (textFieldModel.formatter.valueType == AUIUgsvParamItemValueTypeInt) {
        _textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    else if (textFieldModel.formatter.valueType == AUIUgsvParamItemValueTypeFloat) {
        _textField.keyboardType = UIKeyboardTypeDecimalPad;
    }
    else {
        _textField.keyboardType = UIKeyboardTypeDefault;
    }

    NSString *unit = self.textFieldModel.unit;
    if (unit.length > 0) {
        _unitLabel.text = [NSString stringWithFormat:@"/%@", unit];
    }
    else {
        _unitLabel.text = @"";
    }
    if (self.textFieldModel.placeHolder.length > 0) {
        _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.textFieldModel.placeHolder attributes:@{NSForegroundColorAttributeName: AUIFoundationColor(@"text_ultraweak")}];
    }
    else {
        _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:AUIUgsvGetString(@"请填入") attributes:@{NSForegroundColorAttributeName: AUIFoundationColor(@"text_ultraweak")}];

    }
    _textField.text = self.textFieldModel.text;
}

- (void)updateUIForEditabled:(BOOL)enabled {
    [super updateUIForEditabled:enabled];
    
    _textField.enabled = enabled;
}

// MARK: - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.textFieldModel.text = textField.text;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([_textFieldDelegate respondsToSelector:@selector(onAUIUgsvParamTextFieldCell:becomeFirstResponder:)]) {
        [_textFieldDelegate onAUIUgsvParamTextFieldCell:self becomeFirstResponder:textField];
    }
}

@end

// MARK: - AUIUgsvParamRadioCell
@interface AUIUgsvParamRadioCell ()
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UIButton *btn;
@end

@implementation AUIUgsvParamRadioCell

- (AUIUgsvParamItemRadio *)radioModel {
    return (AUIUgsvParamItemRadio *)self.model;
}

- (void)setup {
    [super setup];
    
    // clear
    [_valueLabel removeFromSuperview];
    [_arrowImageView removeFromSuperview];
    
    // create
    _arrowImageView = [[UIImageView alloc] initWithImage:AUIUgsvGetImage(@"ic_param_options")];
    [self.contentView addSubview:_arrowImageView];
    [_arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).inset(16.0);
        make.centerY.equalTo(self.contentView);
    }];
    
    _valueLabel = [UILabel new];
    _valueLabel.font = AVGetRegularFont(14.0);
    _valueLabel.textColor = AUIFoundationColor(@"text_medium");
    [self.contentView addSubview:_valueLabel];
    [_valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(_arrowImageView.mas_left).inset(8.0);
    }];
    
    _btn = [UIButton new];
    _btn.backgroundColor = UIColor.clearColor;
    [self.contentView addSubview:_btn];
    [_btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [_btn addTarget:self
             action:@selector(onClick:)
   forControlEvents:UIControlEventTouchUpInside];

    // update
    [self updateValue];
}

- (void)onClick:(UIButton *)btn {
    __weak typeof(self) weakSelf = self;
    AUIUgsvParamItemRadio *radioModel = self.radioModel;

    UIView *superView = UIViewController.av_topViewController.view;
    AUIPickerPanel *picker = [[AUIPickerPanel alloc] initWithFrame:superView.bounds];
    picker.listArray = radioModel.optionsLabel;
    picker.selectedIndex = radioModel.selectedIndex;
    picker.onDismissed = ^(AUIPickerPanel * _Nonnull sender, BOOL cancel) {
        if (!cancel) {
            radioModel.selectedIndex = sender.selectedIndex;
            [weakSelf updateValue];
        }
    };
    [picker showOnView:superView];
}

- (void)updateValue {
    [super updateValue];
    
    _valueLabel.text = self.radioModel.showValue;
}

- (void)updateUIForEditabled:(BOOL)enabled {
    [super updateUIForEditabled:enabled];
    _btn.enabled = enabled;
}

@end
