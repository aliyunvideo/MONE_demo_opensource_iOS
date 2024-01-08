//
//  AUILiveBgMusicSettingViewController.m
//  AlivcLiveDemo
//
//  Created by ISS013602000846 on 2022/7/5.
//

#import "AUILiveBgMusicSettingView.h"
#import "AlivcLiveParamModel.h"
#import "AlivcLiveMusicInfoModel.h"
#import "AUILiveParamTableViewCell.h"
#import "AUILiveBgMusicPlaySettingCell.h"
#import "AlivcLiveSettingManager.h"

#define kThemeHeight 44
#define kHeaderHeight 39
#define kMusicPlayCellHeight 364
#define kCellHeight 46

typedef NS_ENUM(NSInteger, AUILiveBgMusicSettingCellSectionType) {
    AUILiveBgMusicSettingCellSectionTypeFuction = 0,
    AUILiveBgMusicSettingCellSectionTypeMusicPlay,
    AUILiveBgMusicSettingCellSectionTypeMusicList,
};

@interface AUILiveBgMusicSettingView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AlivcLiveSettingConfig *tempConfig;
@property (nonatomic, strong) AlivcLiveSettingManager *manager;
@property (nonatomic, copy) NSArray *fuctionSettingArray;
@property (nonatomic, copy) NSArray *musicListSettingArray;
@property (nonatomic, assign) BOOL refreshStatus;

@end

@implementation AUILiveBgMusicSettingView

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

- (void)show:(AlivcLivePushConfig *)config {
    [self.tempConfig convert:config];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.av_top = 0;
        self.av_height = AlivcScreenHeight;
    }];
    
    BOOL initStatus = !self.tableView.superview;
    if (initStatus) {
        [self addSubview:self.tableView];
        self.tableView.tableHeaderView = [self getThemeView];
        
        self.fuctionSettingArray = [self getFuctionSettingSourceArray];
        self.musicListSettingArray = [self getMusicListSettingSourceArray];
    }

    if (!self.refreshStatus) {
        [self startMusicPlay];
        NSIndexPath *selectIndex = [NSIndexPath indexPathForRow:0 inSection:AUILiveBgMusicSettingCellSectionTypeMusicPlay];
        [self.tableView selectRowAtIndexPath:selectIndex animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
    
    if (!initStatus) {
        [self updateFuctionSettingDisplay];
        [self updateMusicListSettingDisplay:NO];
        [self.tableView reloadData];
    }
}

- (void)hide {
    [UIView animateWithDuration:0.3 animations:^{
        self.av_top = AlivcScreenHeight;
        self.av_height = 0;
    }];
}

- (UIView *)getThemeView {
    UIView *themeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.av_width, kThemeHeight)];
    themeView.backgroundColor = AUIFoundationColor(@"bg_weak");
    
    UILabel *themeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, kThemeHeight)];
    themeLabel.text = AUILiveCameraPushString(@"背景音乐");
    themeLabel.textColor = AUIFoundationColor(@"text_strong");
    themeLabel.font = AVGetRegularFont(15);
    themeLabel.center = themeView.center;
    [themeView addSubview:themeLabel];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(20, 0, 80, kThemeHeight);
    cancelButton.av_centerY = themeView.av_centerY;
    [cancelButton setTitle:AUILiveCommonString(@"取消") forState:UIControlStateNormal];
    cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    cancelButton.titleLabel.font = AVGetRegularFont(15);
    [cancelButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(pressCancel) forControlEvents:UIControlEventTouchUpInside];
    [themeView addSubview:cancelButton];
    
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
    [self forceCloseEarBack];
    [self forceCloseDenoise];
    [self forceIntelligentDenoise];
    [self forceCloseMusicPlay];
    [self forceCloseMuted];
    [self forceOpenLoop];
    [self forceResetDefaultAccompaniment];
    [self forceResetDefaultHumanVoice];
    [self hide];
    self.refreshStatus = NO;
    [self.manager resetMusic];
}

- (void)forceCloseEarBack {
    if (self.manager.musicEarBack) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(musicOnClickEarBackButton:)]) {
            [self.delegate musicOnClickEarBackButton:NO];
        }
        self.manager.musicEarBack = NO;
    }
}

- (void)forceCloseDenoise {
    if (self.manager.musicDenoise) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(musicOnClickDenoiseButton:)]) {
            [self.delegate musicOnClickDenoiseButton:NO];
        }
        self.manager.musicDenoise = NO;
    }
}

- (void)forceIntelligentDenoise {
    if (self.manager.musicIntelligentDenoise) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(musicOnClickIntelligentDenoiseButton:)]) {
            [self.delegate musicOnClickIntelligentDenoiseButton:NO];
        }
        self.manager.musicIntelligentDenoise = NO;
    }
}

- (void)forceCloseMusicPlay {
    if (self.manager.musicPlay) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(musicOnClickPlayButton:musicPath:)]) {
            [self.delegate musicOnClickPlayButton:NO musicPath:@""];
        }
        self.manager.musicPlay = NO;
    }
}

- (void)forceCloseMuted {
    if (self.manager.musicMuted) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(musicOnClickMuteButton:)]) {
            [self.delegate musicOnClickMuteButton:NO];
        }
        self.manager.musicMuted = NO;
    }
}

- (void)forceOpenLoop {
    if (!self.manager.musicLoop) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(musicOnClickLoopButton:)]) {
            [self.delegate musicOnClickLoopButton:YES];
        }
        self.manager.musicLoop = YES;
    }
}

- (void)forceResetDefaultAccompaniment {
    if (self.manager.musicAccompanimentValue != 50) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(musicOnSliderAccompanyValueChanged:)]) {
            [self.delegate musicOnSliderAccompanyValueChanged:50];
        }
        self.manager.musicAccompanimentValue = 50;
    }
}

- (void)forceResetDefaultHumanVoice {
    if (self.manager.musicHumanvoiceValue != 50) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(musicOnSliderVoiceValueChanged:)]) {
            [self.delegate musicOnSliderVoiceValueChanged:50];
        }
        self.manager.musicHumanvoiceValue = 50;
    }
}

- (void)pressOK {
    [self hide];
    self.refreshStatus = YES;
}

- (NSArray *)getFuctionSettingSourceArray {
    __weak typeof(self) weakSelf = self;
    AlivcLiveParamModel *blankSegmentModel = [[AlivcLiveParamModel alloc] init];
    blankSegmentModel.reuseId = AlivcLiveParamModelReuseCellSliderHeader;
    blankSegmentModel.title = @"";
    
    AlivcLiveParamModel *earBackModel = [[AlivcLiveParamModel alloc] init];
    earBackModel.title = AUILiveCameraPushString(@"耳返");
    earBackModel.defaultValue = 0;
    earBackModel.defaultValueAppose = 0;
    earBackModel.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    earBackModel.switchBlock = ^(int index, BOOL open) {
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(musicOnClickEarBackButton:)]) {
            [strongSelf.delegate musicOnClickEarBackButton:open];
            strongSelf.manager.musicEarBack = open;
        }
    };
    
    AlivcLiveParamModel *denoiseModel = [[AlivcLiveParamModel alloc] init];
    denoiseModel.title = AUILiveCameraPushString(@"降噪");
    denoiseModel.defaultValue = self.tempConfig.audioScene == AlivcLivePusherAudioScenarioDefaultMode;
    denoiseModel.defaultValueAppose = 0;
    denoiseModel.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    denoiseModel.switchBlock = ^(int index, BOOL open) {
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(musicOnClickDenoiseButton:)]) {
            [strongSelf.delegate musicOnClickDenoiseButton:open];
            strongSelf.manager.musicDenoise = open;
        }
    };
    
    AlivcLiveParamModel *intelligentDenoiseModel = [[AlivcLiveParamModel alloc] init];
    intelligentDenoiseModel.title = AUILiveCameraPushString(@"智能降噪");
    intelligentDenoiseModel.defaultValue = NO;
    intelligentDenoiseModel.defaultValueAppose = 0;
    intelligentDenoiseModel.reuseId = AlivcLiveParamModelReuseCellSwitchButton;
    intelligentDenoiseModel.switchBlock = ^(int index, BOOL open) {
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(musicOnClickIntelligentDenoiseButton:)]) {
            [strongSelf.delegate musicOnClickIntelligentDenoiseButton:open];
            strongSelf.manager.musicIntelligentDenoise = open;
        }
    };

    return @[blankSegmentModel, earBackModel, denoiseModel, intelligentDenoiseModel];
}

- (void)updateFuctionSettingDisplay {
    AUILiveParamTableViewCell *earBackCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:AUILiveBgMusicSettingCellSectionTypeFuction]];
    [earBackCell updateDefaultValue:self.manager.musicEarBack enable:YES];
    
    AUILiveParamTableViewCell *denoiseCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:AUILiveBgMusicSettingCellSectionTypeFuction]];
    [denoiseCell updateDefaultValue:self.tempConfig.audioScene == AlivcLivePusherAudioScenarioDefaultMode enable:YES];
}

- (NSArray *)getMusicListSettingSourceArray {
    NSMutableArray *sourceArray = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;
    AlivcLiveParamModel *titleResolutionModel = [[AlivcLiveParamModel alloc] init];
    titleResolutionModel.reuseId = AlivcLiveParamModelReuseCellSliderHeader;
    titleResolutionModel.title = AUILiveCameraPushString(@"音乐列表");
    [sourceArray addObject:titleResolutionModel];
    
    NSArray *musicDataArray = self.manager.musicData;
    for (int i = 0; i < musicDataArray.count; i++) {
        AlivcLiveMusicInfoModel *music = musicDataArray[i];
        AlivcLiveParamModel *musicListModel = [[AlivcLiveParamModel alloc] init];
        musicListModel.title = music.name;
        musicListModel.defaultValue = self.manager.currentMusicPlayIndex == i;
        musicListModel.reuseId = AlivcLiveParamModelReuseCellTick;
        musicListModel.tickBlock = ^{
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf updateMusicListSettingDisplay:YES];
            [self startMusicPlay];
        };
        [sourceArray addObject:musicListModel];
    }
    return sourceArray.mutableCopy;
}

- (void)updateMusicListSettingDisplay:(BOOL)tick {
    NSArray *musicDataArray = self.manager.musicData;
    for (int i = 0; i < musicDataArray.count; i++) {
        AUILiveParamTableViewCell *musicListCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i + 1 inSection:AUILiveBgMusicSettingCellSectionTypeMusicList]];
        if (tick) {
            if (musicListCell.selected) {
                self.manager.currentMusicPlayIndex = i;
                [musicListCell updateDefaultValue:YES enable:YES];
            } else {
                [musicListCell updateDefaultValue:NO enable:YES];
            }
        } else {
            [musicListCell updateDefaultValue:i == self.manager.currentMusicPlayIndex enable:YES];
        }
    }
}

- (void)startMusicPlay {
    AlivcLiveMusicInfoModel *music = self.manager.currentMusicPlayModel;
    if (music.path.length == 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(musicOnClickPlayButton:musicPath:)]) {
            [self.delegate musicOnClickPlayButton:NO musicPath:nil];
        }
        [self.tableView reloadData];
    } else {
        [self.tableView reloadData];
        AUILiveBgMusicPlaySettingCell *musicPlayCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:AUILiveBgMusicSettingCellSectionTypeMusicPlay]];
        [musicPlayCell startPlayWithModel:music];
    }
}

- (void)updateMusicPlayProgressTime:(long)progressTime durationTime:(long)durationTime {
    dispatch_async(dispatch_get_main_queue(), ^{
        AUILiveBgMusicPlaySettingCell *musicPlayCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:AUILiveBgMusicSettingCellSectionTypeMusicPlay]];
        [musicPlayCell updatePlayProgressTime:progressTime durationTime:durationTime];
    });
}

- (void)resetMusicPlayStatusWithError {
    AUILiveBgMusicPlaySettingCell *musicPlayCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:AUILiveBgMusicSettingCellSectionTypeMusicPlay]];
    [musicPlayCell resetPlayStatusWithError];
    self.manager.musicPlay = NO;
    [self forceCloseMuted];
    [self forceOpenLoop];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case AUILiveBgMusicSettingCellSectionTypeFuction:
            return self.fuctionSettingArray.count;
            break;
        case AUILiveBgMusicSettingCellSectionTypeMusicPlay:
        {
            AlivcLiveMusicInfoModel *currentMusic = self.manager.currentMusicPlayModel;
            if (currentMusic.path.length != 0) {
                return 1;
            } else {
                return 0;
            }
        }
            break;
        default:
            return self.musicListSettingArray.count;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"AUILiveMoreSettingIdentifier%ld%ld", (long)indexPath.row, indexPath.section];
    
    switch (indexPath.section) {
        case AUILiveBgMusicSettingCellSectionTypeFuction:
        case AUILiveBgMusicSettingCellSectionTypeMusicList:
        {
            AlivcLiveParamModel *paramModel = nil;
            if (indexPath.section == AUILiveBgMusicSettingCellSectionTypeFuction) {
                paramModel = self.fuctionSettingArray[indexPath.row];
            } else {
                paramModel = self.musicListSettingArray[indexPath.row];
            }
            
            AUILiveParamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[AUILiveParamTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                [cell configureCellModel:paramModel];
            }
            return cell;
        }
            break;
            
        default:
        {
            AUILiveBgMusicPlaySettingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[AUILiveBgMusicPlaySettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                
                __weak typeof(self) weakSelf = self;
                cell.switchMuteAction = ^(BOOL open) {
                    __strong typeof(self) strongSelf = weakSelf;
                    if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(musicOnClickMuteButton:)]) {
                        [strongSelf.delegate musicOnClickMuteButton:open];
                        strongSelf.manager.musicMuted = open;
                    }
                };
                
                cell.switchPlayAction = ^(AUILiveBgMusicPlayStatus status, NSString * _Nonnull playPath) {
                    __strong typeof(self) strongSelf = weakSelf;
                    switch (status) {
                        case AUILiveBgMusicPlayStatusStart:
                        {
                            if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(musicOnClickPlayButton:musicPath:)]) {
                                [strongSelf.delegate musicOnClickPlayButton:YES musicPath:playPath];
                                strongSelf.manager.musicPlay = YES;
                            }
                        }
                            break;
                        case AUILiveBgMusicPlayStatusPause:
                        {
                            if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(musicOnClickPauseButton:)]) {
                                [strongSelf.delegate musicOnClickPauseButton:YES];
                                strongSelf.manager.musicPlay = YES;
                            }
                        }
                            break;
                        case AUILiveBgMusicPlayStatusResume:
                        {
                            if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(musicOnClickPauseButton:)]) {
                                [strongSelf.delegate musicOnClickPauseButton:NO];
                                strongSelf.manager.musicPlay = YES;
                            }
                        }
                            break;
                        default:
                            break;
                    }
                };
                
                cell.switchLoopAction = ^(BOOL open) {
                    __strong typeof(self) strongSelf = weakSelf;
                    if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(musicOnClickLoopButton:)]) {
                        [strongSelf.delegate musicOnClickLoopButton:open];
                        strongSelf.manager.musicLoop = open;
                    }
                };
                
                cell.accompanimentChangeAction = ^(int value) {
                    __strong typeof(self) strongSelf = weakSelf;
                    if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(musicOnSliderAccompanyValueChanged:)]) {
                        [strongSelf.delegate musicOnSliderAccompanyValueChanged:value];
                        strongSelf.manager.musicAccompanimentValue = value;
                    }
                };
                
                cell.humanVoiceChangeAction = ^(int value) {
                    __strong typeof(self) strongSelf = weakSelf;
                    if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(musicOnSliderVoiceValueChanged:)]) {
                        [strongSelf.delegate musicOnSliderVoiceValueChanged:value];
                        strongSelf.manager.musicHumanvoiceValue = value;
                    }
                };
            }
            
            return cell;
        }
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case AUILiveBgMusicSettingCellSectionTypeFuction:
        case AUILiveBgMusicSettingCellSectionTypeMusicList:
        {
            AlivcLiveParamModel *paramModel = nil;
            if (indexPath.section == AUILiveBgMusicSettingCellSectionTypeFuction) {
                paramModel = self.fuctionSettingArray[indexPath.row];
            } else {
                paramModel = self.musicListSettingArray[indexPath.row];
            }
            
            return [paramModel.reuseId isEqualToString:AlivcLiveParamModelReuseCellSliderHeader] ? kHeaderHeight : kCellHeight;
        }
            break;
            
        default:
        {
            return kMusicPlayCellHeight;
        }
            break;
    }
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
        CGFloat tableHeight = self.av_height - AVSafeTop - 44 * 2;
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
