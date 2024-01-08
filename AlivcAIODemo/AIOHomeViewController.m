//
//  AIOHomeViewController.m
//  AlivcAIO_Demo
//
//  Created by Bingo on 2022/3/28.
//

#import "AIOHomeViewController.h"
#import "AIOSdkHeader.h"


#ifdef AIO_DEMO_ENABLE_PLAYER
#import "AUIPlayerViewController.h"
#endif

#ifdef AIO_DEMO_ENABLE_UGSV
#import "AUIUgsvViewController.h"
#endif

#ifdef AIO_DEMO_ENABLE_LIVE
#import "AUILiveViewController.h"
#endif

#ifdef AIO_DEMO_ENABLE_RTC
#import "AUIRtcViewController.h"
#endif

#define AIOGetImage(key) AVGetImage((key), @"AIO")
#define AIOGetColor(key) AVGetColor((key), @"AIO")
#define AIOGetString(key) AVGetString((key), @"AIO")

typedef NS_ENUM(NSUInteger, AIOEntranceType) {
    AIOEntranceTypeUgsv,
    AIOEntranceTypePlayer,
    AIOEntranceTypeLive,
    AIOEntranceTypeRtc,
    AIOEntranceTypeMore,
};

@interface AIOEntranceItem : AVCommonListItem

@property (nonatomic, assign) AIOEntranceType type;
@property (nonatomic, strong) UIImage *viewIcon;

@end

@implementation AIOEntranceItem

@end


@interface AIOEntranceCell : AVCommonListItemCell

@end

@implementation AIOEntranceCell


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 12.0;
        [self av_setLayerBorderColor:AUIFoundationColor(@"border_weak") borderWidth:1.0];
        self.infoLabel.textColor = AUIFoundationColor(@"text_ultraweak");
        self.infoLabel.font = AVGetRegularFont(12);
        self.infoLabel.numberOfLines = 2;
        self.titleLabel.font = AVGetRegularFont(16);

    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.iconView.frame = CGRectMake(20, 20, 40, 40);
    self.titleLabel.frame = CGRectMake(20, 72, self.contentView.av_width - 40, 24);
    self.infoLabel.frame = CGRectMake(20, 100, self.contentView.av_width - 40, 36);
    self.viewIconView.frame = CGRectMake(20, self.contentView.av_height - 20 - 18, 40, 18);
}

- (void)updateItem:(AIOEntranceItem *)item {
    [super updateItem:item];
    self.viewIconView.image = item.viewIcon;
}

@end


@interface AIOHomeViewController ()

@end

@implementation AIOHomeViewController

- (instancetype)init {
    
    UIImage *viewIcon = AVLocalization.isInternational ? AIOGetImage(@"ic_view_en") : AIOGetImage(@"ic_view");
    UIImage *viewIcon2 = AVLocalization.isInternational ? AIOGetImage(@"ic_view2_en") : AIOGetImage(@"ic_view2");

    AIOEntranceItem *ugsv = [AIOEntranceItem new];
    ugsv.type = AIOEntranceTypeUgsv;
    ugsv.title = AIOGetString(@"短视频");
    ugsv.info = AIOGetString(@"短视频拍摄、剪辑、特效");
    ugsv.icon = AIOGetImage(@"ic_ugc");
    ugsv.viewIcon = viewIcon;
    
    AIOEntranceItem *player = [AIOEntranceItem new];
    player.type = AIOEntranceTypePlayer;
    player.title = AIOGetString(@"播放器");
    player.info = AIOGetString(@"常见播放样式");
    player.icon = AIOGetImage(@"ic_player");
    player.viewIcon = viewIcon;
    
    AIOEntranceItem *live = [AIOEntranceItem new];
    live.type = AIOEntranceTypeLive;
    live.title = AIOGetString(@"直播");
    live.info = AIOGetString(@"直播推流、播放");
    live.icon = AIOGetImage(@"ic_live");
    live.viewIcon = viewIcon;
    
    AIOEntranceItem *rtc = [AIOEntranceItem new];
    rtc.type = AIOEntranceTypeRtc;
    rtc.title = AIOGetString(@"互动直播");
    rtc.info = AIOGetString(@"音视频通话、在线ktv");
    rtc.icon = AIOGetImage(@"ic_rtc");
    rtc.viewIcon = viewIcon;
    
    AIOEntranceItem *more = [AIOEntranceItem new];
    more.type = AIOEntranceTypeMore;
    more.title = AIOGetString(@"场景化应用");
    more.info = AIOGetString(@"常见解决方案");
    more.icon = AIOGetImage(@"ic_more");
    more.viewIcon = viewIcon2;
    
    NSArray *itemList = @[live, ugsv, player, rtc, more];
    if ([AVLocalization isInternational]) {
        itemList = @[live, ugsv, player, more];
    }
    
    self = [super initWithItemList:itemList];
    if (self) {
        
        
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *aliLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.av_width - 20 - 20, 0)];
    aliLabel.font = AVGetMediumFont(32);
    aliLabel.textColor = AUIFoundationColor(@"text_strong");
    aliLabel.text = AIOGetString(@"音视频终端SDK");
    aliLabel.numberOfLines = 0;
    [aliLabel sizeToFit];
    aliLabel.frame = CGRectMake(20, 10, aliLabel.av_width, aliLabel.av_height);
    [self.contentView addSubview:aliLabel];
    
    self.hiddenBackButton = YES;
    self.collectionView.frame = CGRectMake(0, aliLabel.av_bottom + 5, self.contentView.av_width, self.contentView.av_height - aliLabel.av_bottom - 5);
    [self.collectionView registerClass:AIOEntranceCell.class forCellWithReuseIdentifier:AVCollectionViewCellIdentifier];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.itemList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AIOEntranceCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:AVCollectionViewCellIdentifier forIndexPath:indexPath];
    [cell updateItem:self.itemList[indexPath.row]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((self.collectionView.av_width - 20 - 20 - 15) / 2.0, 192.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 15.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 15.0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(15, 20, 15 + AVSafeBottom, 20);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AIOEntranceItem *item = (AIOEntranceItem *)self.itemList[indexPath.row];
    switch (item.type) {
        case AIOEntranceTypeUgsv:
        {
            [self openSVideo];
        }
            break;
        case AIOEntranceTypePlayer:
        {
            [self openPlayer];
        }
            break;
        case AIOEntranceTypeLive:
        {
            [self openLive];
        }
            break;
        case AIOEntranceTypeRtc:
        {
            [self openRtc];
        }
            break;
        case AIOEntranceTypeMore:
        {
            [self openMore];
        }
            break;
        default:
            break;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    //设置(Highlight)高亮下的颜色
    AIOEntranceCell* cell = (AIOEntranceCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:AIOEntranceCell.class]) {
        [cell av_setLayerBorderColor:AUIFoundationColor(@"colourful_border_strong")];
    }
}
 
- (void)collectionView:(UICollectionView *)collectionView  didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    //设置(Nomal)正常状态下的颜色
    AIOEntranceCell* cell = (AIOEntranceCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:AIOEntranceCell.class]) {
        [cell av_setLayerBorderColor:AUIFoundationColor(@"border_weak")];
    }
}

- (void)openSVideo {
#ifdef AIO_DEMO_ENABLE_UGSV
    AUIUgsvViewController *vc = [[AUIUgsvViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
#else
    [AVAlertController show:AIOGetString(@"当前SDK不支持")];
#endif
}

- (void)openPlayer {
#ifdef AIO_DEMO_ENABLE_PLAYER
    AUIPlayerViewController *vc = [[AUIPlayerViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
#else
    [AVAlertController show:AIOGetString(@"当前SDK不支持")];
#endif
}

- (void)openLive {
#ifdef AIO_DEMO_ENABLE_LIVE
    AUILiveViewController *vc = [[AUILiveViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
#else
    [AVAlertController show:AIOGetString(@"当前SDK不支持")];
#endif
}

- (void)openRtc {
#ifdef AIO_DEMO_ENABLE_RTC
    AUIRtcViewController *vc = [[AUIRtcViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
#else
    [AVAlertController show:AIOGetString(@"当前SDK不支持")];
#endif
}

- (void)openSolution:(NSString *)appScheme webUrl:(NSString *)webUrl {
    NSURL *url = [NSURL URLWithString:appScheme];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
    else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:webUrl] options:@{} completionHandler:nil];
    }
}

- (void)openMore {
    
    AVCommonListItem *item1 = [AVCommonListItem new];
    item1.title = AIOGetString(@"短视频解决方案");
    item1.info = AIOGetString(@"适用于从生产到消费的短视频解决方案");
    item1.icon = AIOGetImage(@"ic_ugc");
    item1.tag = 0;
    item1.clickBlock = ^{
        [AVAlertController show:AIOGetString(@"敬请期待！")];
    };
    
    AVCommonListItem *item2 = [AVCommonListItem new];
    item2.title = AIOGetString(@"互动直播解决方案");
    item2.info = AIOGetString(@"适用于各种直播解决方案");
    item2.icon = AIOGetImage(@"ic_live");
    item2.tag = 1;
    item2.clickBlock = ^{
        [self openSolution:@"auilive://" webUrl:@"https://alivc-demo-cms.alicdn.com/versionProduct/installPackage/AUI_interaction/installPackage-AUI.html"];
    };
    NSArray *list = @[item1, item2];
    
    AVCommonListViewController *vc = [[AVCommonListViewController alloc] initWithItemList:list];
    vc.hiddenMenuButton = YES;
    vc.title = AIOGetString(@"场景化应用");
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onMenuClicked:(UIButton *)sender {
    NSString *appVersion = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSArray<NSString *> *infos = @[
        [NSString stringWithFormat:@"%@: %@", AIOGetString(@"App版本"), appVersion],
#ifdef AIO_DEMO_USING_ALIVCSDK
        [NSString stringWithFormat:@"%@: %@", AIOGetString(@"SDK版本号"), AliVCSDKInfo.version],
        [NSString stringWithFormat:@"%@: %@", AIOGetString(@"SDK构建id"), AliVCSDKInfo.buildId],
        [NSString stringWithFormat:@"%@: %@", AIOGetString(@"SDKCommitId"), AliVCSDKInfo.commitId],
        [NSString stringWithFormat:@"%@: %@", AIOGetString(@"SDK所有组件名"), AliVCSDKInfo.componentName],
        [NSString stringWithFormat:@"%@: %@", AIOGetString(@"SDK所有组件ID"), AliVCSDKInfo.componentId],
#endif

#ifdef AIO_DEMO_ENABLE_PLAYER
        [NSString stringWithFormat:@"%@: %@", AIOGetString(@"播放器组件版本"), AliPlayer.getSDKVersion],
#endif
        
#ifdef AIO_DEMO_ENABLE_UGSV
        [NSString stringWithFormat:@"%@: %@", AIOGetString(@"短视频组件版本"), AliyunVideoSDKInfo.version],
#endif
        
#ifdef AIO_DEMO_ENABLE_LIVE
        [NSString stringWithFormat:@"%@: %@", AIOGetString(@"直播推流组件版本"), AlivcLiveBase.getSDKVersion],
#endif
        
#ifdef AIO_DEMO_ENABLE_QUEEN
        [NSString stringWithFormat:@"%@: %@", AIOGetString(@"美颜组件版本"), QueenEngine.getVersion],
#endif
    ];
    
    NSString *message = [infos componentsJoinedByString:@"\n"];
    [AVAlertController show:message];
}

@end
