//
//  AUILivePlayModule.m
//  AlivcLiveDemo
//
//  Created by zzy on 2022/6/1.
//

#import "AUILivePlayModule.h"

#ifdef ALIVC_LIVE_DEMO_ENABLE_PULLPLAY
#import "AUILivePullTestViewController.h"
#endif

@interface AUILivePlayModule ()

@property (nonatomic, strong) UIViewController *sourceVC;

@end

@implementation AUILivePlayModule

- (instancetype)initWithSourceViewController:(UIViewController *)sourceVC {
    if (self = [super init]) {
        self.sourceVC = sourceVC;
    }
    return self;
}

- (void)open {
#ifdef ALIVC_LIVE_DEMO_ENABLE_PULLPLAY
    if (![AliveLiveDemoUtil getEssentialRights]) {
        return;
    }
    
    AUILivePullTestViewController *vc = [[AUILivePullTestViewController alloc] init];
    [self.sourceVC.navigationController pushViewController:vc animated:YES];
#else
    [AVToastView show:AlivcLiveString(@"未集成该组件") view:self.sourceVC.view position:AVToastViewPositionMid];
#endif
}

@end
