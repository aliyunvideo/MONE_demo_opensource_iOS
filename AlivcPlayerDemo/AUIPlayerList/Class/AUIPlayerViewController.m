//
//  AUIPlayerViewController.m
//  AlivcPlayerDemo
//
//  Created by zzy on 2022/5/26.
//

#import "AUIPlayerViewController.h"
#import "AUIVideoFlowModule.h"
#import "AUIVideoListModule.h"
#import "AUIVideoFullScreenModule.h"
#import "AUIShortEpisodeViewController.h"
#import "AUIVideoCacheGlobalSetting.h"

@interface AUIPlayerViewController ()

@end

@implementation AUIPlayerViewController

- (instancetype)init {
   AVCommonListItem *item1 = [AVCommonListItem new];
   item1.title = AlivcPlayerString(@"信息流播放");
   item1.info = AlivcPlayerString(@"适用于新闻资讯、社区互动等短视频场景");
   item1.icon = AlivcPlayerImage(@"bofangqi_ic_xinxi");
   
   AVCommonListItem *item2 = [AVCommonListItem new];
   item2.title = AlivcPlayerString(@"沉浸式播放");
   item2.info = AlivcPlayerString(@"竖屏短视频场景，全屏秒开最佳实践");
   item2.icon = AlivcPlayerImage(@"bofangqi_ic_chenjin");
    
   AVCommonListItem *item3 = [AVCommonListItem new];
   item3.title = AlivcPlayerString(@"沉浸式播放");
   item3.info = AlivcPlayerString(@"竖屏短视频场景，标准实现");
   item3.icon = AlivcPlayerImage(@"bofangqi_ic_chenjin");
    
    AVCommonListItem *item4 = [AVCommonListItem new];
    item4.title = AlivcPlayerString(@"短剧播放");
    item4.info = AlivcPlayerString(@"适用于多个视频间流畅切换的短视频场景");
    item4.icon = AlivcPlayerImage(@"bofangqi_ic_quanping");
   
   AVCommonListItem *item5 = [AVCommonListItem new];
    item5.title = AlivcPlayerString(@"全屏播放");
    item5.info = AlivcPlayerString(@"适用于版权视频等长视频场景");
    item5.icon = AlivcPlayerImage(@"bofangqi_ic_zidingyi");
   
   NSArray *list = @[item1, item2, item3, item4, item5];
   
   self = [super initWithItemList:list];
   if (self) {
   }
   return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    self.hiddenMenuButton = NO;
    self.menuButton.av_left = self.headerView.av_width - 20 - 80;
    self.menuButton.av_width = 80;
    [self.menuButton setImage:nil forState:UIControlStateNormal];
    [self.menuButton setTitle:AlivcPlayerString(@"清空缓存") forState:UIControlStateNormal];

   self.titleView.text = AlivcPlayerString(@"播放器");
}

- (void)onMenuClicked:(UIButton *)sender {
    [AUIVideoCacheGlobalSetting clearCaches];
    [AVToastView show:@"已清除缓存" view:self.view position:AVToastViewPositionMid];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.item) {
        case 0:
        {
            [self openVideoFlow];
        }
            break;
        case 1:
        {
            [self openVideoFunctionList];
        }
            break;
        case 2:
        {
            [self openVideoStandradList];
        }
            break;
        case 3:
        {
            [self openVideoShortEpisode];
        }
            break;
        case 4:
        {
            [self openVideoFullScreen];
        }
            break;
        default:
            break;
    }
}

- (void)openVideoFlow {
    AUIVideoFlowModule *module = [[AUIVideoFlowModule alloc] initWithSourceViewController:self];
    [module open];
}

- (void)openVideoFunctionList {
    AUIVideoListModule *module = [[AUIVideoListModule alloc] initWithSourceViewController:self];
    [module openFunctionListPage];
}

- (void)openVideoStandradList {
    AUIVideoListModule *module = [[AUIVideoListModule alloc] initWithSourceViewController:self];
    [module openStandradListPage];
}

- (void)openVideoShortEpisode {
    AUIShortEpisodeViewController *vc = [[AUIShortEpisodeViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)openVideoFullScreen {
    AUIVideoFullScreenModule *module = [[AUIVideoFullScreenModule alloc] initWithSourceViewController:self];
    [module open];
}

@end
