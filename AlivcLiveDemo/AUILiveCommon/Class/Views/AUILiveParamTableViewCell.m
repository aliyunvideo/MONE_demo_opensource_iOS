//
//  AUILiveParamTableViewCell.m
//  AlivcLiveCaptureDev
//
//  Created by TripleL on 17/7/10.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import "AUILiveParamTableViewCell.h"
#import "AlivcLiveParamModel.h"

@interface AUILiveParamTableViewCell ()

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UITextField *inputView;
@property(nonatomic, strong) UISlider *slider;
@property(nonatomic, strong) UILabel *infoLabel;
@property(nonatomic, strong) UISwitch *switcher;

@property(nonatomic, strong) UIView *pickerSelectView;
@property(nonatomic, strong) UILabel *pickerSelectLabel;
@property(nonatomic, strong) UIImageView *pickerSelectImage;

@property(nonatomic, strong) UISegmentedControl *segment;
@property(nonatomic, strong) UIButton *switchButton;

@property(nonatomic, strong) UILabel *titleLabelAppose;
@property(nonatomic, strong) UISwitch *switcherAppose;
@property(nonatomic, strong) UILabel *headerLabel;

@property(nonatomic, strong) UIImageView *tickImageView;
@property(nonatomic, assign) BOOL firstSetSelectStatus;

@end

@implementation AUILiveParamTableViewCell

- (void)setupSubViews {
    self.backgroundColor = AUIFoundationColor(@"bg_weak");
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.firstSetSelectStatus = YES;

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.font = AVGetRegularFont(15);
    self.titleLabel.textColor = AUIFoundationColor(@"text_strong");;
    self.titleLabel.text = self.cellModel.title;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.numberOfLines = 0;
    [self.contentView addSubview:self.titleLabel];

    if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellInput]) {
        [self setupInputView];
    } else if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellSwitch]) {
        [self setupSwitchView];
    } else if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellSlider]) {
        [self setupSliderView];
    } else if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellSwitchButton]) {
        [self setupSwitchButtonView];
    } else if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellSwitchSetButton]) {
        [self setupSwitchSignalButtonView];
    } else if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellPickerSelect]) {
        [self setupPickerSelectView];
    } else if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellSelectCustomOpen]) {
        [self setupPickerSelectView];
    } else if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellSegment]) {
        [self setupSegmentViewAtRecord:NO];
    } else if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellSegmentAtRecord]) {
        [self setupSegmentViewAtRecord:YES];
    } else if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellSliderHeader]) {
        [self setupSliderHeader];
    } else if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellSegmentWhite]) {
        [self setupSliderHeader];
    } else if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellTick]) {
        [self setupTick];
    } else {
        
    }
}

- (void)setupInputView {
    self.inputView = [[UITextField alloc] init];
    self.inputView.backgroundColor = [UIColor clearColor];
    self.inputView.textAlignment = NSTextAlignmentRight;
    self.inputView.textColor = AUIFoundationColor(@"text_strong");
    self.inputView.font = AVGetRegularFont(15);
    self.inputView.keyboardType = UIKeyboardTypeNumberPad;
    if (!self.cellModel.placeHolder) {
        self.cellModel.placeHolder = AUILiveCommonString(@"请输入");
    }
    self.inputView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.cellModel.placeHolder attributes:@{NSForegroundColorAttributeName: AUIFoundationColor(@"text_ultraweak")}];
    if (self.cellModel.defaultValue > 0) {
        self.inputView.text = [NSString stringWithFormat:@"%ld", (long)self.cellModel.defaultValue];
    }
    self.inputView.delegate = (id) self;
    if (self.cellModel.inputNotEnable) {
        self.inputView.enabled = NO;
    }
    [self.contentView addSubview:self.inputView];
    
    self.infoLabel = [[UILabel alloc] init];
    self.infoLabel.textAlignment = NSTextAlignmentLeft;
    self.infoLabel.font = AVGetRegularFont(11);
    self.infoLabel.text = self.cellModel.infoText;
    if (self.cellModel.infoColor) {
        self.infoLabel.textColor = self.cellModel.infoColor;
    } else {
        self.infoLabel.textColor = AUIFoundationColor(@"text_ultraweak");
    }
    [self.contentView addSubview:self.infoLabel];
}

- (void)setupSwitchView {
    self.switcher = [[UISwitch alloc] init];
    self.switcher.onTintColor = AUIFoundationColor(@"colourful_fill_strong");
    [self.switcher setOn:(BOOL) self.cellModel.defaultValue];
    [self.switcher addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.switcher];

    self.titleLabelAppose = [[UILabel alloc] init];
    self.titleLabelAppose.textAlignment = NSTextAlignmentLeft;
    self.titleLabelAppose.font = AVGetRegularFont(14);
    self.titleLabelAppose.textColor = AUIFoundationColor(@"text_strong");
    self.titleLabelAppose.text = self.cellModel.titleAppose;
    self.titleLabelAppose.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabelAppose.numberOfLines = 1;

    self.switcherAppose = [[UISwitch alloc] init];
    self.switcherAppose.onTintColor = AUIFoundationColor(@"colourful_fill_strong");
    [self.switcherAppose setOn:(BOOL) self.cellModel.defaultValueAppose];
    [self.switcherAppose addTarget:self action:@selector(switchApposeAction:) forControlEvents:UIControlEventValueChanged];

    if (self.cellModel.titleAppose) {
        [self.contentView addSubview:self.titleLabelAppose];
        [self.contentView addSubview:self.switcherAppose];
    }
}

- (void)setupSliderHeader {
    _headerLabel = [[UILabel alloc] init];
    _headerLabel.backgroundColor = [UIColor clearColor];
    _headerLabel.text = self.cellModel.title;
    _headerLabel.textAlignment = NSTextAlignmentLeft;
    _headerLabel.font = AVGetRegularFont(12);
    _headerLabel.textColor = AUIFoundationColor(@"text_ultraweak");
    _headerLabel.numberOfLines = 0;
    self.backgroundColor = AUIFoundationColor(@"bg_medium");
    [self.contentView addSubview:_headerLabel];
}

- (void)setupSliderView {
    self.slider = [[UISlider alloc] init];
    self.slider.tintColor = AUIFoundationColor(@"colourful_fill_strong");
    [self.slider addTarget:self action:@selector(silderValueDidChanged) forControlEvents:UIControlEventValueChanged];
    self.slider.value = (float) self.cellModel.defaultValue;
    [self.contentView addSubview:self.slider];

    self.infoLabel = [[UILabel alloc] init];
    self.infoLabel.textAlignment = NSTextAlignmentCenter;
    if (self.cellModel.infoText && !self.cellModel.infoUnit) {
        self.infoLabel.font = AVGetRegularFont(15);
        self.infoLabel.text = self.cellModel.infoText;
        if (self.cellModel.infoColor) {
            self.infoLabel.textColor = self.cellModel.infoColor;
        } else {
            self.infoLabel.textColor = AUIFoundationColor(@"text_strong");
        }
    } else if (self.cellModel.infoUnit) {
        NSMutableAttributedString *infoAttributedText = [[NSMutableAttributedString alloc] initWithString:self.cellModel.infoText attributes:@{
            NSFontAttributeName: AVGetRegularFont(15),
            NSForegroundColorAttributeName: AUIFoundationColor(@"text_strong")
        }];
        [infoAttributedText appendAttributedString:[[NSAttributedString alloc] initWithString:[@"  /" stringByAppendingString:self.cellModel.infoUnit] attributes:@{
            NSFontAttributeName: AVGetRegularFont(11),
            NSForegroundColorAttributeName: AUIFoundationColor(@"text_weak")
        }]];
        self.infoLabel.attributedText = infoAttributedText;
    }
    
    [self.contentView addSubview:self.infoLabel];
}

- (void)setupSwitchButtonView {
    [self setupSwitchView];
    self.switchButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.switchButton addTarget:self action:@selector(switchButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.switchButton setTitleColor:AUIFoundationColor(@"text_strong") forState:(UIControlStateNormal)];
    self.switchButton.titleLabel.font = AVGetSemiboldFont(14);
    [self.switchButton setTitle:self.cellModel.infoText forState:(UIControlStateNormal)];
    [self.contentView addSubview:self.switchButton];
}

- (void)setupSwitchSignalButtonView {
    [self setupSwitchView];
    self.switchButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.switchButton addTarget:self action:@selector(switchButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.switchButton setTitleColor:[UIColor blueColor] forState:(UIControlStateNormal)];
    self.switchButton.titleLabel.font = AVGetSemiboldFont(14);
    [self.switchButton setTitle:self.cellModel.infoText forState:(UIControlStateNormal)];
    [self.contentView addSubview:self.switchButton];
}

- (void)setupPickerSelectView {
    self.pickerSelectView = [[UIView alloc] init];
    self.pickerSelectView.userInteractionEnabled = YES;
    [self.contentView addSubview:self.pickerSelectView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickerSelect:)];
    [self.pickerSelectView addGestureRecognizer:tap];
    
    self.pickerSelectLabel = [[UILabel alloc] init];
    self.pickerSelectLabel.textColor = AUIFoundationColor(@"text_medium");
    self.pickerSelectLabel.font = AVGetRegularFont(14);
    self.pickerSelectLabel.textAlignment = NSTextAlignmentRight;
    self.pickerSelectLabel.text = self.cellModel.pickerPanelTextArray[(NSInteger)self.cellModel.defaultValue];
    self.pickerSelectLabel.userInteractionEnabled = YES;
    [self.pickerSelectView addSubview:self.pickerSelectLabel];

    self.pickerSelectImage = [[UIImageView alloc] init];
    self.pickerSelectImage.image = AUIFoundationImage(@"ic_arraw");
    [self.pickerSelectView addSubview:self.pickerSelectImage];
}

- (void)setupSegmentViewAtRecord:(BOOL)isRecord {
    if (self.segment) {
        return;
    }
    self.segment = [[UISegmentedControl alloc] initWithItems:self.cellModel.segmentTitleArray];
    [self.segment addTarget:self action:@selector(segmentValueDidChanged:) forControlEvents:(UIControlEventValueChanged)];
    self.segment.selectedSegmentIndex = self.cellModel.defaultValue;

    NSDictionary *attr = @{};
    if (isRecord) {
        if (@available(iOS 13.0, *)) {
            self.segment.selectedSegmentTintColor = AUIFoundationColor(@"colourful_fill_strong");
        } else {
            self.segment.tintColor = AUIFoundationColor(@"colourful_fill_strong");
        }
        attr = @{
            NSForegroundColorAttributeName: AUIFoundationColor(@"text_strong"),
            NSFontAttributeName: AVGetRegularFont(14)
        };
    } else {
        attr = [NSDictionary dictionaryWithObjectsAndKeys:AVGetRegularFont(10), NSFontAttributeName, nil];
    }
    
    [self.segment setTitleTextAttributes:attr forState:UIControlStateNormal];
    [self.contentView addSubview:self.segment];
}

- (void)setupTick {
    self.tickImageView = [[UIImageView alloc] init];
    self.tickImageView.image = AUILiveCommonImage(@"music_check");
    [self.contentView addSubview:self.tickImageView];
    self.tickImageView.hidden = self.cellModel.defaultValue == 0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat midY = CGRectGetMidY(self.contentView.bounds);
    CGFloat midX = CGRectGetMidX(self.contentView.bounds);
    CGFloat width = CGRectGetWidth(self.contentView.bounds);
    CGFloat titleWidth = AlivcSizeWidth(midX - 5);
    self.titleLabel.frame = CGRectMake(AlivcSizeWidth(20), 0, titleWidth, self.frame.size.height);
    if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellInput]) {
        self.inputView.frame = CGRectMake(titleWidth + 5, midY - 12, width - titleWidth - 45 - 10 - 5 * 2, 24);
        self.infoLabel.frame = CGRectMake(self.inputView.av_right + 5, midY - 12, 45, 24);
    } else if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellSwitch]) {
        self.switcher.frame = CGRectMake(titleWidth + 5, midY - 15, 40, 30);
        self.titleLabelAppose.frame = CGRectMake(midX, 0, 72, CGRectGetHeight(self.contentView.bounds));
        self.switcherAppose.frame = CGRectMake(CGRectGetMaxX(self.titleLabelAppose.frame) + 5, midY - 15, 40, 30);
    } else if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellSlider]) {
        self.titleLabel.frame = CGRectMake(0, 0, 0, 0);
        self.slider.frame = CGRectMake(16, midY - 8, width - 100, 24);
        if (self.cellModel.infoText && !self.cellModel.infoUnit) {
            self.infoLabel.frame = CGRectMake(CGRectGetMaxX(self.slider.frame) + 15, midY - 8, 65, 24);
        } else {
            self.infoLabel.frame = CGRectMake(CGRectGetMaxX(self.slider.frame) + 10, midY - 8, 65, 24);
        }
    } else if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellPickerSelect]) {
        self.pickerSelectView.frame = CGRectMake(titleWidth, midY - 15, self.contentView.av_width - titleWidth, 30);
        self.pickerSelectLabel.frame = CGRectMake(5, (self.pickerSelectView.av_height - 24) / 2.0, self.pickerSelectView.av_width - 5 * 2 - 25 - 15, 24);
        self.pickerSelectImage.frame = CGRectMake(self.pickerSelectLabel.av_right + 5, (self.pickerSelectView.av_height - 15) / 2.0, 15, 15);
    } else if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellSelectCustomOpen]) {
        self.pickerSelectView.frame = CGRectMake(titleWidth, midY - 15, self.contentView.av_width - titleWidth, 30);
        self.pickerSelectLabel.frame = CGRectMake(5, (self.pickerSelectView.av_height - 24) / 2.0, self.pickerSelectView.av_width - 5 * 2 - 25 - 15, 24);
        self.pickerSelectImage.frame = CGRectMake(self.pickerSelectLabel.av_right + 5, (self.pickerSelectView.av_height - 15) / 2.0, 15, 15);
    } else if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellSegment]) {
        self.segment.frame = CGRectMake(titleWidth + 5, midY - 15, AlivcSizeWidth(200), 30);
    } else if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellSegmentAtRecord]) {
        self.segment.frame = CGRectMake(titleWidth + 5, midY - 15, AlivcSizeWidth(200), 30);
    } else if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellSwitchButton]) {
        self.switcher.frame = CGRectMake(width - 70, midY - 15, 50, 30);
        self.switcher.hidden = NO;
    } else if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellSwitchSetButton]) {
        self.switcher.hidden = NO;
        self.switcher.frame = CGRectMake(width - 70, midY - 15, 50, 30);
        self.switchButton.hidden = YES;
    } else if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellSliderHeader]) {
        self.titleLabel.hidden = YES;
        _headerLabel.frame = CGRectMake(AlivcSizeWidth(20), 0, self.frame.size.width, self.frame.size.height);
    } else if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellSegmentWhite]) {
        self.titleLabel.hidden = YES;
        _headerLabel.frame = CGRectMake(AlivcSizeWidth(20), 0, self.frame.size.width, self.frame.size.height);
    } else if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellTick]) {
        UIImage *image = AUILiveCommonImage(@"music_check");
        CGSize imageSize = CGSizeMake(20, (image.size.height / image.size.width) * 20);
        self.tickImageView.frame = CGRectMake(width - 16 - imageSize.width, midY - imageSize.height / 2.0, imageSize.width, imageSize.height);
    }
}

- (void)configureCellModel:(AlivcLiveParamModel *)cellModel {
    self.cellModel = cellModel;
    [self setupSubViews];
}

- (void)silderValueDidChanged {

    if ([self.titleLabel.text isEqual:AUILiveCommonString(@"分辨率")]) {
        CGFloat total = 7;
        CGFloat value = self.slider.value;
        if (value <= (1.0 / total)) {
            self.cellModel.sliderBlock(0);
            self.infoLabel.text = @"180P";
        } else if (value > (1.0 / total) && value <= (2.0 / total)) {
            self.cellModel.sliderBlock(1);
            self.infoLabel.text = @"240P";
        } else if (value > (2.0 / total) && value <= (3.0 / total)) {
            self.cellModel.sliderBlock(2);
            self.infoLabel.text = @"360P";
        } else if (value > (3.0 / total) && value <= (4.0 / total)) {
            self.cellModel.sliderBlock(3);
            self.infoLabel.text = @"480P";
        } else if (value > (4.0 / total) && value <= (5.0 / total)) {
            self.cellModel.sliderBlock(4);
            self.infoLabel.text = @"540P";
        } else if (value > (5.0 / total) && value <= (6.0 / total)) {
            self.cellModel.sliderBlock(5);
            self.infoLabel.text = @"720P";
        } else if (value > (6.0 / total) && value <= (7.0 / total)) {
            self.cellModel.sliderBlock(6);
            self.infoLabel.text = @"1080P";
        } else {

        }
    } else if ([self.titleLabel.text isEqual:AUILiveCommonString(@"音频采样率")]) {
        CGFloat total = 4;
        CGFloat value = self.slider.value;
        if (value <= (1.0 / total) || value == 0) {
            self.cellModel.sliderBlock(16000);
            self.infoLabel.attributedText = [self getSliderRightAttributedStringAtName:@"16" unit:@"kHz"];
        } else if (value > (1.0 / total) && value <= (2.0 / total)) {
            self.cellModel.sliderBlock(32000);
            self.infoLabel.attributedText = [self getSliderRightAttributedStringAtName:@"32" unit:@"kHz"];
        } else if (value > (2.0 / total) && value <= (3.0 / total)) {
            self.cellModel.sliderBlock(44100);
            self.infoLabel.attributedText = [self getSliderRightAttributedStringAtName:@"44" unit:@"kHz"];
        } else if (value > (3.0 / total) && value <= (4.0 / total)) {
            self.cellModel.sliderBlock(48000);
            self.infoLabel.attributedText = [self getSliderRightAttributedStringAtName:@"48" unit:@"kHz"];
        } else {

        }
    } else if ([self.titleLabel.text isEqual:AUILiveCommonString(@"采集帧率")] || [self.titleLabel.text isEqual:AUILiveCommonString(@"最小帧率")]) {
        CGFloat total = 7;
        CGFloat value = self.slider.value;
        CGFloat FPSValue = 0;
        if (value < 1 / total || value == 0) {
            self.infoLabel.attributedText = [self getSliderRightAttributedStringAtName:@"8" unit:@"fps"];
            FPSValue = 8;
        } else if ((value > 1 / total) && (value < 2 / total)) {
            self.infoLabel.attributedText = [self getSliderRightAttributedStringAtName:@"10" unit:@"fps"];
            FPSValue = 10;
        } else if ((value > 2 / total) && (value < 3 / total)) {
            self.infoLabel.attributedText = [self getSliderRightAttributedStringAtName:@"12" unit:@"fps"];
            FPSValue = 12;
        } else if ((value > 3 / total) && (value < 4 / total)) {
            self.infoLabel.attributedText = [self getSliderRightAttributedStringAtName:@"15" unit:@"fps"];
            FPSValue = 15;
        } else if ((value > 4 / total) && (value < 5 / total)) {
            self.infoLabel.attributedText = [self getSliderRightAttributedStringAtName:@"20" unit:@"fps"];
            FPSValue = 20;
        } else if ((value > 5 / total) && (value < 6 / total)) {
            self.infoLabel.attributedText = [self getSliderRightAttributedStringAtName:@"25" unit:@"fps"];
            FPSValue = 25;
        } else if ((value > 6 / total) && (value < 7 / total)) {
            self.infoLabel.attributedText = [self getSliderRightAttributedStringAtName:@"30" unit:@"fps"];
            FPSValue = 30;
        } else if (value == 1) {
            self.infoLabel.attributedText = [self getSliderRightAttributedStringAtName:@"30" unit:@"fps"];
            FPSValue = 30;
        }
        self.cellModel.sliderBlock(FPSValue);
    } else if ([self.titleLabel.text isEqual:AUILiveCommonString(@"关键帧间隔")]) {
        CGFloat total = 5;
        CGFloat value = self.slider.value;
        CGFloat FPSValue = 0;
        if (value < 1 / total || value == 0) {
            self.infoLabel.attributedText = [self getSliderRightAttributedStringAtName:@"1" unit:@"s"];
            FPSValue = 1;
        } else if ((value > 1 / total) && (value < 2 / total)) {
            self.infoLabel.attributedText = [self getSliderRightAttributedStringAtName:@"2" unit:@"s"];
            FPSValue = 2;
        } else if ((value > 2 / total) && (value < 3 / total)) {
            self.infoLabel.attributedText = [self getSliderRightAttributedStringAtName:@"3" unit:@"s"];
            FPSValue = 3;
        } else if ((value > 3 / total) && (value < 4 / total)) {
            self.infoLabel.attributedText = [self getSliderRightAttributedStringAtName:@"4" unit:@"s"];
            FPSValue = 4;
        } else if ((value > 4 / total) && (value < 5 / total)) {
            self.infoLabel.attributedText = [self getSliderRightAttributedStringAtName:@"5" unit:@"s"];
            FPSValue = 5;
        } else if (value == 1) {
            self.infoLabel.attributedText = [self getSliderRightAttributedStringAtName:@"5" unit:@"s"];
            FPSValue = 5;
        }
        self.cellModel.sliderBlock(FPSValue);
    } else {
        int beautyValue = self.slider.value * 100;
        self.cellModel.sliderBlock(beautyValue);
        self.infoLabel.text = [NSString stringWithFormat:@"%d", beautyValue];
    }
}

- (NSAttributedString *)getSliderRightAttributedStringAtName:(NSString *)name unit:(NSString *)unit {
    NSMutableAttributedString *infoAttributedText = [[NSMutableAttributedString alloc] initWithString:name attributes:@{
        NSFontAttributeName: AVGetRegularFont(15),
        NSForegroundColorAttributeName: AUIFoundationColor(@"text_strong")
    }];
    [infoAttributedText appendAttributedString:[[NSAttributedString alloc] initWithString:[@"  /" stringByAppendingString:unit] attributes:@{
        NSFontAttributeName: AVGetRegularFont(11),
        NSForegroundColorAttributeName: AUIFoundationColor(@"text_weak")
    }]];
    return infoAttributedText;
}

- (void)pickerSelect:(UITapGestureRecognizer *)tap {
    if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellSelectCustomOpen]) {
        if (self.cellModel.selectCustomOpenBlock) {
            self.cellModel.selectCustomOpenBlock();
        }
    } else {
        UIView *superView = UIViewController.av_topViewController.view;
        AUIPickerPanel *pickerPanel = [[AUIPickerPanel alloc] initWithFrame:superView.bounds];
        pickerPanel.listArray = self.cellModel.pickerPanelTextArray;
        pickerPanel.selectedIndex = self.cellModel.defaultValue;
        __weak typeof(self) weakSelf = self;
        pickerPanel.onDismissed = ^(AUIPickerPanel * _Nonnull sender, BOOL cancel) {
            __strong typeof(self) strongSelf = weakSelf;
            strongSelf.cellModel.defaultValue = sender.selectedIndex;
            strongSelf.pickerSelectLabel.text = strongSelf.cellModel.pickerPanelTextArray[sender.selectedIndex];
            if (strongSelf.cellModel.pickerSelectBlock) {
                strongSelf.cellModel.pickerSelectBlock((int)sender.selectedIndex);
            }
        };
        [pickerPanel showOnView:superView];
    }
}

- (void)segmentValueDidChanged:(UISegmentedControl *)sender {
    if ([self.cellModel.title isEqualToString:AUILiveCommonString(@"声道数")]) {
        int value = (int) sender.selectedSegmentIndex + 1;
        self.cellModel.segmentBlock(value);
    } else if ([self.cellModel.title isEqualToString:AUILiveCommonString(@"关键帧间隔")]) {
        int value = (int) sender.selectedSegmentIndex + 1;
        self.cellModel.segmentBlock(value);
    } else if ([self.cellModel.title isEqualToString:AUILiveCommonString(@"采集帧率")] || [self.cellModel.title isEqualToString:AUILiveCommonString(@"最小帧率")]) {
        int value = 12;
        switch (sender.selectedSegmentIndex) {
            case 0:
                value = 8;
                break;
            case 1:
                value = 10;
                break;
            case 2:
                value = 12;
                break;
            case 3:
                value = 15;
                break;
            case 4:
                value = 20;
                break;
            case 5:
                value = 25;
                break;
            case 6:
                value = 30;
                break;
            default:
                break;
        }
        self.cellModel.segmentBlock(value);
    } else if ([self.cellModel.title isEqualToString:AUILiveCommonString(@"音频格式")]) {

        int value = 2;
        switch (sender.selectedSegmentIndex) {
            case 0:
                value = 2;
                break;
            case 1:
                value = 5;
                break;
            case 2:
                value = 29;
                break;
            case 3:
                value = 23;
                break;
            default:
                break;
        }
        self.cellModel.segmentBlock(value);
    } else {
        int value = (int) sender.selectedSegmentIndex;
        self.cellModel.segmentBlock(value);
    }
}


- (void)switchAction:(id)sender {
    UISwitch *switcher = (UISwitch *) sender;
    BOOL isButtonOn = [switcher isOn];
    if (nil != self.cellModel && nil != self.cellModel.switchBlock) {
        self.cellModel.switchBlock(0, isButtonOn);
    }
}


- (void)switchApposeAction:(id)sender {
    UISwitch *switcher = (UISwitch *) sender;
    BOOL isButtonOn = [switcher isOn];

    if (nil != self.cellModel && nil != self.cellModel.switchBlock) {
        self.cellModel.switchBlock(1, isButtonOn);
    }
}

- (void)switchButtonAction:(UIButton *)sender {

    self.cellModel.switchButtonBlock();
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellTick]) {
        BOOL oldSelected = !self.tickImageView.hidden;
        if (selected && oldSelected != selected) {
            if (self.cellModel.tickBlock) {
                self.cellModel.tickBlock();
            }
        }
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {

    if (self.cellModel.valueBlock) {
        self.inputView.keyboardType = UIKeyboardTypeNumberPad;
    }
    if (self.cellModel.stringBlock) {
        self.inputView.keyboardType = UIKeyboardTypeDefault;
    }
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (!textField.text.length) {
        textField.text = textField.placeholder;
    }

    CGFloat r = [textField.text intValue];
    if (self.cellModel.valueBlock) {
        self.cellModel.valueBlock(r);
    }
    if (self.cellModel.stringBlock) {
        self.cellModel.stringBlock(textField.text);
    }
}

- (void)updateEnable:(BOOL)enable {
    if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellInput]) {
        self.inputView.enabled = enable;
    } else if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellSwitchButton]) {
        self.switcher.enabled = enable;
    } else {

    }
}

- (void)updateDefaultValue:(int)value enable:(BOOL)enable {
    if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellInput]) {
        self.inputView.text = [NSString stringWithFormat:@"%ld", (long)value];
        self.inputView.enabled = enable;
    } else if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellSegment] || [self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellSegmentAtRecord]) {
        self.segment.selectedSegmentIndex = value;
    } else if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellSwitchButton]) {
        [self.switcher setOn:value];
        self.switcher.enabled = enable;
    }  else if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellSelectCustomOpen]) {
        self.pickerSelectLabel.text = self.cellModel.pickerPanelTextArray[(NSInteger)value];
    }  else if ([self.cellModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellTick]) {
        self.tickImageView.hidden = value == 0;
    }  else {

    }
}

- (void)closeInputStatus {
    if (self.inputView) {
        [self.inputView resignFirstResponder];
    }
}

@end
