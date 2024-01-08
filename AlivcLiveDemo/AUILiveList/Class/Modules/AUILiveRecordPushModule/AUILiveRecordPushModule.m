//
//  AUILiveRecordPushModule.m
//  AlivcLiveDemo
//
//  Created by zzy on 2022/6/1.
//

#import "AUILiveRecordPushModule.h"

#ifdef ALIVC_LIVE_DEMO_ENABLE_RECORDPUSH
#import "AUILiveRecordPushManager.h"
#import "AUILivePushReplayKitTipViewController.h"
#import "AUILivePushReplayKitConfigViewController.h"
#endif

@interface AUILiveRecordPushModule ()

@property (nonatomic, strong) UIViewController *sourceVC;

@end

@implementation AUILiveRecordPushModule

- (instancetype)initWithSourceViewController:(UIViewController *)sourceVC {
    if (self = [super init]) {
        self.sourceVC = sourceVC;
    }
    return self;
}

- (void)open {
#ifdef ALIVC_LIVE_DEMO_ENABLE_RECORDPUSH
    if (![AliveLiveDemoUtil getEssentialRights]) {
        return;
    }
    
    if ([AUILiveRecordPushManager isTipPageShow]) {
        AUILivePushReplayKitTipViewController *tipVC = [[AUILivePushReplayKitTipViewController alloc] init];
        [self.sourceVC av_presentFullScreenViewController:tipVC animated:YES completion:nil];
    } else {
        AUILivePushReplayKitConfigViewController *configVC = [[AUILivePushReplayKitConfigViewController alloc] init];
        [self.sourceVC.navigationController pushViewController:configVC animated:YES];
    }
#else
    [AVToastView show:AlivcLiveString(@"未集成该组件") view:self.sourceVC.view position:AVToastViewPositionMid];
#endif
}

@end
