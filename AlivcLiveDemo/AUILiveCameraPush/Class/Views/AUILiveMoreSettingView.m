//
//  AUILiveMoreSettingView.m
//  AlivcLiveDemo
//
//  Created by ISS013602000846 on 2022/7/5.
//

#import "AUILiveMoreSettingView.h"
#import "AlivcLiveParamModel.h"
#import "AUILiveParamTableViewCell.h"
#import "AlivcLiveSettingManager.h"

#define kThemeHeight 44
#define kHeaderHeight 19
#define kCellHeight 46

typedef NS_ENUM(NSInteger, AUILiveMoreSettingType) {
    AUILiveMoreSettingTypeAll = 0,
    AUILiveMoreSettingTypePreviewDisplayMode,
};

@interface AUILiveMoreSettingView ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) AUILiveMoreSettingType settingType;
@property (nonatomic, copy) NSArray *allSettingArray;
@property (nonatomic, copy) NSArray *previewDisplayModeSettingArray;
@property (nonatomic, strong) AlivcLiveSettingConfig *tempConfig;
@property (nonatomic, assign) BOOL refreshStatus;
@property (nonatomic, assign) AlivcLiveSettingManager *manager;

@end

@implementation AUILiveMoreSettingView

- (instancetype)init {
    if (self = [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
        self.av_top = AlivcScreenHeight;
        self.av_height = 0;
        self.backgroundColor = AUILiveCameraPushColor(@"ir_picker_bg");
        self.manager = [AlivcLiveSettingManager manager];
    }
    return self;
}

- (void)show {
    [self.tempConfig convert:self.manager.moreSettingConfig];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.av_top = 0;
        self.av_height = AlivcScreenHeight;
    }];
    
    self.settingType = AUILiveMoreSettingTypeAll;
    BOOL initStatus = !self.tableView.superview;
    if (initStatus) {
        [self addSubview:self.tableView];
        self.tableView.tableHeaderView = [self getThemeView];
        self.allSettingArray = [self getAllSettingSourceArray];
        self.previewDisplayModeSettingArray = [self getPreviewDisplayModeSettingSourceArray];
    }
    
    if (self.refreshStatus) {
        self.tableView.tableHeaderView = [self getThemeView];
        [self.tableView reloadData];
    }
    
    if (!initStatus) {
        [self updateAllSettingDisplay];
    }
}

- (void)hide {
    if (self.tempConfig.qualityMode == AlivcLivePushQualityModeCustom) {
        AUILiveParamTableViewCell *targetBitrateCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        [targetBitrateCell closeInputStatus];
        
        AUILiveParamTableViewCell *minBitrateCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        [minBitrateCell closeInputStatus];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.av_top = AlivcScreenHeight;
        self.av_height = 0;
    }];
}

- (UIView *)getThemeView {
    UIView *themeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.av_width, kThemeHeight)];
    themeView.backgroundColor = AUIFoundationColor(@"bg_weak");
    
    UILabel *themeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, kThemeHeight)];
    if (self.settingType == AUILiveMoreSettingTypeAll) {
        themeLabel.text = AUILiveCameraPushString(@"更多设置");
    } else {
        themeLabel.text = AUILiveCameraPushString(@"显示模式");
    }
    themeLabel.textColor = AUIFoundationColor(@"text_strong");
    themeLabel.font = AVGetRegularFont(15);
    themeLabel.center = themeView.center;
    [themeView addSubview:themeLabel];
    
    
    if (self.settingType == AUILiveMoreSettingTypeAll) {
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(20, 0, 80, kThemeHeight);
        cancelButton.av_centerY = themeView.av_centerY;
        [cancelButton setTitle:AUILiveCommonString(@"取消") forState:UIControlStateNormal];
        cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        cancelButton.titleLabel.font = AVGetRegularFont(15);
        [cancelButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(pressCancel) forControlEvents:UIControlEventTouchUpInside];
        [themeView addSubview:cancelButton];
    } else {
        AVBaseButton *leftButton = [[AVBaseButton alloc] initWithType:AVBaseButtonTypeImageText titlePos:AVBaseButtonTitlePosRight];
        leftButton.frame = CGRectMake(20, 0, 90, kThemeHeight);
        leftButton.av_centerY = themeView.av_centerY;
        leftButton.image = AUILiveCameraPushImage(@"ic_moresetting_back");
        leftButton.title = AUILiveCameraPushString(@"更多设置");
        leftButton.font = AVGetRegularFont(15);
        leftButton.color = AUILiveCommonColor(@"ir_sheet_button");
        __weak typeof(self) weakSelf = self;
        leftButton.action = ^(AVBaseButton * _Nonnull btn) {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf pressLeft];
        };
        [themeView addSubview:leftButton];
    }
    
    UIButton *okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    okButton.frame = CGRectMake(themeView.av_width - 20 - 80, 0, 80, kThemeHeight);
    okButton.av_centerY = themeView.av_centerY;
    [okButton setTitle:AUILiveCommonString(@"确定") forState:UIControlStateNormal];
    okButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    okButton.titleLabel.font = AVGetRegularFont(15);
    [okButton setTitleColor:AUILiveCommonColor(@"ir_sheet_button") forState:UIControlStateNormal];
    [okButton addTarget:self action:@selector(pressOK) forControlEvents:UIControlEventTouchUpInside];
    [themeView addSubview:okButton];
    
    return themeView;
}

- (void)pressCancel {
    [self hide];
    self.settingType = AUILiveMoreSettingTypeAll;
    self.refreshStatus = NO;
}

- (void)pressLeft {
    self.settingType = AUILiveMoreSettingTypeAll;
    self.tableView.tableHeaderView = [self getThemeView];
    [self.tableView reloadData];
    [self updatePreviewDisplayModeDisplay];
}

- (void)pressOK {
    if (self.newConfigAction) {
        self.newConfigAction(self.tempConfig);
    }
    [self hide];
    self.settingType = AUILiveMoreSettingTypeAll;
    self.refreshStatus = YES;
}

- (NSArray *)getAllSettingSourceArray {
    __weak typeof(self) weakSelf = self;
    
    AlivcLiveParamModel *blankSegmentModel = [[AlivcLiveParamModel alloc] init];
    blankSegmentModel.reuseId = AlivcLiveParamModelReuseCellSliderHeader;
    blankSegmentModel.title = @"";
    
    AlivcLiveParamModel *targetBitrateModel = [[AlivcLiveParamModel alloc] init];
    targetBitrateModel.title = AUILiveCommonString(@"视频目标码率");
    targetBitrateModel.placeHolder = AUILiveCameraPushString(@"请输入");
    targetBitrateModel.defaultValue = self.tempConfig.targetVideoBitrate;
    targetBitrateModel.infoText = @"/kbps";
    targetBitrateModel.inputNotEnable = self.tempConfig.qualityMode != AlivcLivePushQualityModeCustom;
    targetBitrateModel.infoColor = AUIFoundationColor(@"text_strong");
    targetBitrateModel.reuseId = AlivcLiveParamModelReuseCellInput;
    targetBitrateModel.valueBlock = ^(int value) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.tempConfig.targetVideoBitrate = value;
    };
    
    AlivcLiveParamModel *minBitrateModel = [[AlivcLiveParamModel alloc] init];
    minBitrateModel.title = AUILiveCommonString(@"视频最小码率");
    minBitrateModel.placeHolder = AUILiveCameraPushString(@"请输入");
    minBitrateModel.defaultValue = self.tempConfig.minVideoBitrate;
    minBitrateModel.inputNotEnable = self.tempConfig.qualityMode != AlivcLivePushQualityModeCustom;
    minBitrateModel.infoText = @"/kbps";
    minBitrateModel.infoColor = AUIFoundationColor(@"text_strong");
    minBitrateModel.reuseId = AlivcLiveParamModelReuseCellInput;
    minBitrateModel.valueBlock = ^(int value) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.tempConfig.minVideoBitrate = value;
    };

    AlivcLiveParamModel *pushMirrorModel = [[AlivcLiveParamModel alloc] init];
    pushMirrorModel.title = AUILiveCommonString(@"推流镜像");
    pushMirrorModel.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    pushMirrorModel.defaultValue = self.tempConfig.pushMirror;
    pushMirrorModel.defaultValueAppose = 0;
    pushMirrorModel.switchBlock = ^(int index, BOOL open) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.tempConfig.pushMirror = open;
    };

    AlivcLiveParamModel *previewMirrorModel = [[AlivcLiveParamModel alloc] init];
    previewMirrorModel.title = AUILiveCommonString(@"预览镜像");
    previewMirrorModel.defaultValue = self.tempConfig.previewMirror;
    previewMirrorModel.defaultValueAppose = 0;
    previewMirrorModel.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    previewMirrorModel.switchBlock = ^(int index, BOOL open) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.tempConfig.previewMirror = open;
    };

    NSArray *previewDisplayModeTitleArray = @[AUILiveCameraPushString(@"拉伸"), AUILiveCameraPushString(@"适合"), AUILiveCameraPushString(@"裁剪")];
    AlivcLiveParamModel *previewDisplayModeModel = [[AlivcLiveParamModel alloc] init];
    previewDisplayModeModel.title = AUILiveCameraPushString(@"显示模式");
    previewDisplayModeModel.pickerPanelTextArray = previewDisplayModeTitleArray;
    previewDisplayModeModel.defaultValue = self.tempConfig.previewDisplayMode;
    previewDisplayModeModel.reuseId = AlivcLiveParamModelReuseCellSelectCustomOpen;
    
    previewDisplayModeModel.selectCustomOpenBlock = ^{
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.settingType = AUILiveMoreSettingTypePreviewDisplayMode;
        strongSelf.tableView.tableHeaderView = [self getThemeView];
        strongSelf.previewDisplayModeSettingArray = [self getPreviewDisplayModeSettingSourceArray];
        [strongSelf.tableView reloadData];
        [strongSelf updatePreviewDisplayModeSettingDisplay];
    };
    
    if (self.tempConfig.qualityMode == AlivcLivePushQualityModeCustom) {
        return @[blankSegmentModel, targetBitrateModel, minBitrateModel, pushMirrorModel, previewMirrorModel];
    } else {
        return @[blankSegmentModel, pushMirrorModel, previewMirrorModel];
    }
}

- (void)updateAllSettingDisplay {
    if (self.tempConfig.qualityMode == AlivcLivePushQualityModeCustom) {
        AUILiveParamTableViewCell *targetBitrateCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        [targetBitrateCell updateDefaultValue:self.tempConfig.targetVideoBitrate enable:self.tempConfig.qualityMode == AlivcLivePushQualityModeCustom];
        
        AUILiveParamTableViewCell *minBitrateCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        [minBitrateCell updateDefaultValue:self.tempConfig.minVideoBitrate enable:self.tempConfig.qualityMode == AlivcLivePushQualityModeCustom];
        
        AUILiveParamTableViewCell *pushMirrorCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
        [pushMirrorCell updateDefaultValue:self.tempConfig.pushMirror enable:YES];
        
        AUILiveParamTableViewCell *previewMirrorCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
        [previewMirrorCell updateDefaultValue:self.tempConfig.previewMirror enable:YES];
    } else {
        AUILiveParamTableViewCell *pushMirrorCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        [pushMirrorCell updateDefaultValue:self.tempConfig.pushMirror enable:YES];
        
        AUILiveParamTableViewCell *previewMirrorCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        [previewMirrorCell updateDefaultValue:self.tempConfig.previewMirror enable:YES];
    }
    
    // [self updatePreviewDisplayModeDisplay];
}

- (void)updatePreviewDisplayModeDisplay {
    AUILiveParamTableViewCell *previewDisplayModeCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
    [previewDisplayModeCell updateDefaultValue:(int)self.tempConfig.previewDisplayMode enable:YES];
}

- (NSArray *)getPreviewDisplayModeSettingSourceArray {
    __weak typeof(self) weakSelf = self;
    AlivcLiveParamModel *blankSegmentModel = [[AlivcLiveParamModel alloc] init];
    blankSegmentModel.reuseId = AlivcLiveParamModelReuseCellSliderHeader;
    blankSegmentModel.title = @"";
    
    AlivcLiveParamModel *scaleFillModeModel = [[AlivcLiveParamModel alloc] init];
    scaleFillModeModel.title = AUILiveCameraPushString(@"拉伸");
    scaleFillModeModel.defaultValue = self.tempConfig.previewDisplayMode == ALIVC_LIVE_PUSHER_PREVIEW_SCALE_FILL;
    scaleFillModeModel.reuseId = AlivcLiveParamModelReuseCellTick;
    scaleFillModeModel.tickBlock = ^{
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.tempConfig.previewDisplayMode = ALIVC_LIVE_PUSHER_PREVIEW_SCALE_FILL;
        [strongSelf updatePreviewDisplayModeSettingDisplay];
    };
    
    AlivcLiveParamModel *aspectFitModeModel = [[AlivcLiveParamModel alloc] init];
    aspectFitModeModel.title = AUILiveCameraPushString(@"适合");
    aspectFitModeModel.defaultValue = self.tempConfig.previewDisplayMode == ALIVC_LIVE_PUSHER_PREVIEW_ASPECT_FIT;
    aspectFitModeModel.reuseId = AlivcLiveParamModelReuseCellTick;
    aspectFitModeModel.tickBlock = ^{
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.tempConfig.previewDisplayMode = ALIVC_LIVE_PUSHER_PREVIEW_ASPECT_FIT;
        [strongSelf updatePreviewDisplayModeSettingDisplay];
    };

    AlivcLiveParamModel *aspectFillModeModel = [[AlivcLiveParamModel alloc] init];
    aspectFillModeModel.title = AUILiveCameraPushString(@"裁剪");
    aspectFillModeModel.defaultValue = self.tempConfig.previewDisplayMode == ALIVC_LIVE_PUSHER_PREVIEW_ASPECT_FILL;
    aspectFillModeModel.reuseId = AlivcLiveParamModelReuseCellTick;
    aspectFillModeModel.tickBlock = ^{
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.tempConfig.previewDisplayMode = ALIVC_LIVE_PUSHER_PREVIEW_ASPECT_FILL;
        [strongSelf updatePreviewDisplayModeSettingDisplay];
    };
    
    return @[blankSegmentModel, scaleFillModeModel, aspectFitModeModel, aspectFillModeModel];
}

- (void)updatePreviewDisplayModeSettingDisplay {
    AUILiveParamTableViewCell *scaleFillModeCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [scaleFillModeCell updateDefaultValue:self.tempConfig.previewDisplayMode == ALIVC_LIVE_PUSHER_PREVIEW_SCALE_FILL enable:YES];
    
    AUILiveParamTableViewCell *aspectFitModeCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    [aspectFitModeCell updateDefaultValue:self.tempConfig.previewDisplayMode == ALIVC_LIVE_PUSHER_PREVIEW_ASPECT_FIT enable:YES];
    
    AUILiveParamTableViewCell *aspectFillModeCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    [aspectFillModeCell updateDefaultValue:self.tempConfig.previewDisplayMode == ALIVC_LIVE_PUSHER_PREVIEW_ASPECT_FILL enable:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.settingType == AUILiveMoreSettingTypeAll) {
        return self.allSettingArray.count;
    } else {
        return self.previewDisplayModeSettingArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = (NSUInteger) indexPath.row;
    
    AlivcLiveParamModel *paramModel = nil;
    if (self.settingType == AUILiveMoreSettingTypeAll) {
        paramModel = self.allSettingArray[index];
    } else {
        paramModel = self.previewDisplayModeSettingArray[index];
    }
    
    NSString *cellIdentifier = [NSString stringWithFormat:@"AUILiveMoreSettingIdentifier%ld%ld", (long)index, (long) self.settingType];
    AUILiveParamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[AUILiveParamTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell configureCellModel:paramModel];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = (NSUInteger) indexPath.row;
    AlivcLiveParamModel *paramModel = nil;
    if (self.settingType == AUILiveMoreSettingTypeAll) {
        paramModel = self.allSettingArray[index];
    } else {
        paramModel = self.previewDisplayModeSettingArray[index];
    }
    return [paramModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellSliderHeader] ? kHeaderHeight : kCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self endEditing:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self endEditing:YES];
}

- (UITableView *)tableView {
    if (!_tableView) {
        CGFloat tableHeight = kThemeHeight + kHeaderHeight + kCellHeight * 6;
        CGRect frame = CGRectMake(0, self.av_height - tableHeight, self.av_width, tableHeight);
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        _tableView.backgroundColor = AUIFoundationColor(@"bg_weak");
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [_tableView setBackgroundColor:AUIFoundationColor(@"bg_weak")];
        [_tableView setShowsVerticalScrollIndicator:NO];
    }
    return _tableView;
}

- (AlivcLiveSettingConfig *)tempConfig {
    if (!_tempConfig) {
        _tempConfig = [[AlivcLiveSettingConfig alloc] init];
    }
    return _tempConfig;
}

@end
