//
//  AUILiveViewController.m
//  AlivcLivePusherDemo
//
//  Created by zzy on 2022/5/31.
//  Copyright © 2022 TripleL. All rights reserved.
//

#import "AUILiveViewController.h"
#import "AUILiveCameraPushModule.h"
#import "AUILiveRecordPushModule.h"
#import "AUILivePlayModule.h"
#import "AUILiveRtsPlayModule.h"
#import "AUILiveLinkMicModule.h"
#import "AUILivePKModule.h"

typedef NS_ENUM(NSUInteger, AUILiveModuleIndex) {
    AUILiveModuleIndexCameraPush = 1,
    AUILiveModuleIndexRecordPush,
    AUILiveModuleIndexPlayPull,
    AUILiveModuleIndexPlayRts,
    AUILiveModuleIndexLinkMic,
    AUILiveModuleIndexLinkPK,
};

@interface AUILiveViewController ()

@end

@implementation AUILiveViewController

- (instancetype)init {
    NSMutableArray *list = [NSMutableArray array];
   
    AVCommonListItem *item1 = [AVCommonListItem new];
    item1.title = AlivcLiveString(@"摄像头推流");
    item1.info = AlivcLiveString(@"手机摄像头/麦克风采集，支持参数设置、基础特效");
    item1.icon = AlivcLiveImage(@"zhibo_ic_tuiliu");
    item1.tag = AUILiveModuleIndexCameraPush;
    [list addObject:item1];
   
#ifdef ALIVC_LIVE_DEMO_ENABLE_RECORDPUSH
    AVCommonListItem *item2 = [AVCommonListItem new];
    item2.title = AlivcLiveString(@"录屏推流");
    item2.info = AlivcLiveString(@"手机屏幕采集，支持参数设置");
    item2.icon = AlivcLiveImage(@"zhibo_ic_luping");
    item2.tag = AUILiveModuleIndexRecordPush;
    [list addObject:item2];
#endif

    AVCommonListItem *item3 = [AVCommonListItem new];
    item3.title = AlivcLiveString(@"拉流播放");
    item3.info = AlivcLiveString(@"支持常见协议，如FLV、RTMP、HLS、RTS等");
    item3.icon = AlivcLiveImage(@"zhibo_ic_laliu");
    item3.tag = AUILiveModuleIndexPlayPull;
    [list addObject:item3];

#ifdef ALIVC_LIVE_DEMO_ENABLE_RTSPLAY
    AVCommonListItem *item4 = [AVCommonListItem new];
    item4.title = AlivcLiveString(@"超低延时直播");
    item4.info = AlivcLiveString(@"超低延时、高并发、高清流畅");
    item4.icon = AlivcLiveImage(@"zhibo_ic_laliu");
    item4.tag = AUILiveModuleIndexPlayRts;
    [list addObject:item4];
#endif

#ifdef ALIVC_LIVE_DEMO_ENABLE_LINKMIC
    AVCommonListItem *item5 = [AVCommonListItem new];
    item5.title = AlivcLiveString(@"连麦互动");
    item5.info = AlivcLiveString(@"主播与观众的在线视频连麦互动");
    item5.icon = AlivcLiveImage(@"zhibo_ic_linkmic");
    item5.tag = AUILiveModuleIndexLinkMic;
    [list addObject:item5];
#endif

#ifdef ALIVC_LIVE_DEMO_ENABLE_PK
    AVCommonListItem *item6 = [AVCommonListItem new];
    item6.title = AlivcLiveString(@"PK互动");
    item6.info = AlivcLiveString(@"主播之间的在线视频连麦互动");
    item6.icon = AlivcLiveImage(@"zhibo_ic_pk");
    item6.tag = AUILiveModuleIndexLinkPK;
    [list addObject:item6];
#endif

   self = [super initWithItemList:list];
   if (self) {
   }
   return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.hiddenMenuButton = YES;
    self.titleView.text = AlivcLiveString(@"直播推流");
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AVCommonListItem *item = [self.itemList objectAtIndex:indexPath.row];
    if (item.tag == AUILiveModuleIndexCameraPush) {
        [self openCameraPush];
    }
    else if (item.tag == AUILiveModuleIndexRecordPush) {
        [self openRecordPush];
    }
    else if (item.tag == AUILiveModuleIndexPlayPull) {
        [self openPlay];
    }
    else if (item.tag == AUILiveModuleIndexPlayRts) {
        [self openRtsPlay];
    }
    else if (item.tag == AUILiveModuleIndexLinkMic) {
        [self openLinkMic];
    }
    else if (item.tag == AUILiveModuleIndexLinkPK) {
        [self openPK];
    }
}

- (void)openCameraPush {
    AUILiveCameraPushModule *module = [[AUILiveCameraPushModule alloc] initWithSourceViewController:self];
    [module open];
}

- (void)openRecordPush {
    AUILiveRecordPushModule *module = [[AUILiveRecordPushModule alloc] initWithSourceViewController:self];
    [module open];
}

- (void)openPlay {
    AUILivePlayModule *module = [[AUILivePlayModule alloc] initWithSourceViewController:self];
    [module open];
}

- (void)openRtsPlay {
    AUILiveRtsPlayModule *module = [[AUILiveRtsPlayModule alloc] initWithSourceViewController:self];
    [module open];
}

- (void)openLinkMic {
    AUILiveLinkMicModule *module = [[AUILiveLinkMicModule alloc] initWithSourceViewController:self];
    [module open];
}

- (void)openPK {
    AUILivePKModule *module = [[AUILivePKModule alloc] initWithSourceViewController:self];
    [module open];
}

@end
