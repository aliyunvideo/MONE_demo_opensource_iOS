//
//  AUIUgsvInfoViewController.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/28.
//

#import "AUIUgsvInfoViewController.h"
#import "AUIUgsvMacro.h"
#import "Masonry.h"
#import "AlivcUgsvSDKHeader.h"

@interface AUIUgsvInfoViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray<NSString *> *infoList;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AVBaseButton *uploadLogBtn;
@end

#define kCellIdentifier @"UgsvInfoTableViewCellIdentifier"

@implementation AUIUgsvInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup {
    // clear
    [_tableView removeFromSuperview];
    [_uploadLogBtn removeFromSuperview];
    
    // create
    _tableView = [UITableView new];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = UIColor.clearColor;
    [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:kCellIdentifier];
    [self.contentView addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    __weak typeof(self) weakSelf = self;
    _uploadLogBtn = [AVBaseButton TextButton];
    _uploadLogBtn.title = AUIUgsvGetString(@"提取日志");
    _uploadLogBtn.font = AVGetRegularFont(16.0);
    _uploadLogBtn.layer.cornerRadius = 8.0;
    _uploadLogBtn.layer.masksToBounds = YES;
    _uploadLogBtn.backgroundColor = AUIFoundationColor(@"colourful_fg_strong");
    _uploadLogBtn.action = ^(AVBaseButton * _Nonnull btn) {
        [weakSelf doUploadLogAction];
    };
    [self.contentView addSubview:_uploadLogBtn];
    [_uploadLogBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(130.0);
        make.height.mas_equalTo(44.0);
        make.centerX.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).inset(AVSafeBottom + 20.0);
    }];

    // update
    [self update];
}

static NSString * s_formatTime(NSTimeInterval time)
{
    NSDateFormatter *dateFormat = [NSDateFormatter new];
    dateFormat.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [dateFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
}

static NSString * s_featureName(AliyunVideoFeatureType type)
{
    switch (type) {
        case AliyunVideoFeatureTypeMV: return AUIUgsvGetString(@"MV");
        case AliyunVideoFeatureTypeSticker: return AUIUgsvGetString(@"动态贴纸");
        case AliyunVideoFeatureTypeCropCompose: return AUIUgsvGetString(@"剪裁压缩");
        case AliyunVideoFeatureTypeCaption: return AUIUgsvGetString(@"字幕");
        case AliyunVideoFeatureTypeAETemplate: return AUIUgsvGetString(@"剪同款");
        default: return AUIUgsvGetString(@"未知");
    }
}

- (void)update {
    // base
    self.titleView.text = AUIUgsvGetString(@"SDK版本信息");
    [self.menuButton setImage:AUIUgsvGetImage(@"ic_refresh") forState:UIControlStateNormal];

    // info list
    _infoList = @[].mutableCopy;
    
    // app
    NSString *appVersion = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [_infoList addObject:[NSString stringWithFormat:@"APP_VERSION：%@", appVersion]];
    
    // sdk
    [_infoList addObject:[NSString stringWithFormat:@"VERSION：%@", AliyunVideoSDKInfo.version]];
    [_infoList addObject:[NSString stringWithFormat:@"BUILD_ID：%@", AliyunVideoSDKInfo.videoSDKBuildId]];
    [_infoList addObject:[NSString stringWithFormat:@"MEDIA_CORE_COMMIT_ID：%@", AliyunVideoSDKInfo.mediaCoreCommitId]];
    [_infoList addObject:[NSString stringWithFormat:@"ALIVC_COMMIT_ID：%@", AliyunVideoSDKInfo.alivcCommitId]];
    [_infoList addObject:[NSString stringWithFormat:@"VIDEO_SDK_COMMIT_ID：%@", AliyunVideoSDKInfo.videoSDKCommitId]];
    
    // license
    AliyunVideoLicense *license = AliyunVideoLicenseManager.CurrentLicense;
    [_infoList addObject:AUIUgsvGetString(@"许可证信息")];
    [_infoList addObject:[NSString stringWithFormat:@"%@: %@", AUIUgsvGetString(@"许可证签发时间"), s_formatTime(license.certSignTime)]];
    [_infoList addObject:[NSString stringWithFormat:@"%@: %@", AUIUgsvGetString(@"许可证有效时间"), s_formatTime(license.certExpireTime)]];
    [_infoList addObject:[NSString stringWithFormat:@"%@: %@", AUIUgsvGetString(@"业务到期时间"), s_formatTime(license.expireTime)]];
    [_infoList addObject:AUIUgsvGetString(@"增值服务")];
    for (AliyunVideoLicenseFeature *feature in license.features) {
        [_infoList addObject:s_featureName(feature.feature)];
        [_infoList addObject:[NSString stringWithFormat:@"[%@] - [%@]",
                                    s_formatTime(feature.startTime),
                                    s_formatTime(feature.endTime)]];
    }

    [_tableView reloadData];
}

static NSString * s_formatLicenseRefreshRespCode(AliyunVideoLicenseRefreshCode code) {
    switch (code) {
        case AliyunVideoLicenseRefreshCodeUninitialized: return AUIUgsvGetString(@"SDK初始化中...");
        case AliyunVideoLicenseRefreshCodeSuccess: return AUIUgsvGetString(@"成功");
        case AliyunVideoLicenseRefreshCodeInvalid: return AUIUgsvGetString(@"证书无效");
        case AliyunVideoLicenseRefreshCodeServerError: return AUIUgsvGetString(@"服务端出错，请稍后重试");
        case AliyunVideoLicenseRefreshCodeNetworkError: return AUIUgsvGetString(@"网络出错，请检查本地网络");
        default: return AUIUgsvGetString(@"未知错误");
    }
}

- (void)doUploadLogAction {
    NSString *logPath = AliyunVideoSDKInfo.logPath;
    NSString *targetPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    targetPath = [targetPath stringByAppendingPathComponent:@"MockUploadLog"];
    BOOL isDirectory = NO;
    if ([NSFileManager.defaultManager fileExistsAtPath:targetPath isDirectory:&isDirectory] && isDirectory) {
        [NSFileManager.defaultManager removeItemAtPath:targetPath error:nil];
    }
    
    NSError *copyError = nil;
    if ([NSFileManager.defaultManager copyItemAtPath:logPath toPath:targetPath error:&copyError]) {
        [AVProgressHUD ShowMessage:AUIUgsvGetString(@"提取日志成功") inView:self.view];
    }
    else {
        NSLog(@"copy log error: %@", copyError);
        [AVProgressHUD ShowMessage:AUIUgsvGetString(@"提取日志失败") inView:self.view];
    }
}

- (void)onMenuClicked:(UIButton *)sender {
    AVProgressHUD *hud = [AVProgressHUD ShowHUDAddedTo:self.contentView animated:YES];
    hud.labelText = AUIUgsvGetString(@"证书更新中");
    [AliyunVideoLicenseManager Refresh:^(AliyunVideoLicenseRefreshCode retCode) {
        if (retCode == AliyunVideoLicenseRefreshCodeSuccess) {
            hud.iconType = AVProgressHUDIconTypeSuccess;
            hud.labelText = AUIUgsvGetString(@"证书更新成功");
        }
        else {
            hud.iconType = AVProgressHUDIconTypeWarn;
            hud.labelText = s_formatLicenseRefreshRespCode(retCode);
        }
        [hud hideAnimated:YES afterDelay:2.0];
    }];
}

// MARK: - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 26.0;
}

// MARK: - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.infoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    cell.textLabel.text = self.infoList[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = AVGetRegularFont(14.0);
    cell.textLabel.textColor = AUIFoundationColor(@"text_strong");
    return cell;
}

@end
