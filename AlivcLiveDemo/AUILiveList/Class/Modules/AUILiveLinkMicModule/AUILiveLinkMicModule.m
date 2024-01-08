//
//  AUILiveLinkMicModule.m
//  AlivcLiveDemo
//
//  Created by ISS013602000846 on 2022/7/22.
//

#import "AUILiveLinkMicModule.h"

#ifdef ALIVC_LIVE_DEMO_ENABLE_LINKMIC
#import "AUILiveURLConfigManager.h"
#import "AUILiveInteractiveURLConfigViewController.h"
#import "AUILiveLinkMicConfigViewController.h"
#endif

@interface AUILiveLinkMicModule ()

@property (nonatomic, strong) UIViewController *sourceVC;

@end

@implementation AUILiveLinkMicModule

- (instancetype)initWithSourceViewController:(UIViewController *)sourceVC {
    if (self = [super init]) {
        self.sourceVC = sourceVC;
    }
    return self;
}

- (void)open {
#ifdef ALIVC_LIVE_DEMO_ENABLE_LINKMIC
    if (![AliveLiveDemoUtil getEssentialRights]) {
        return;
    }
    
    if ([[AUILiveURLConfigManager manager] haveConfig]) {
        AUILiveLinkMicConfigViewController *vc = [[AUILiveLinkMicConfigViewController alloc] init];
        [self.sourceVC.navigationController pushViewController:vc animated:YES];
    } else {
        AUILiveInteractiveURLConfigViewController *vc = [[AUILiveInteractiveURLConfigViewController alloc] init];
        vc.type = AUILiveInteractiveURLConfigTypeLinkMic;
        [self.sourceVC.navigationController pushViewController:vc animated:YES];
    }
#else
    [AVToastView show:AlivcLiveString(@"未集成该组件") view:self.sourceVC.view position:AVToastViewPositionMid];
#endif
}

@end
