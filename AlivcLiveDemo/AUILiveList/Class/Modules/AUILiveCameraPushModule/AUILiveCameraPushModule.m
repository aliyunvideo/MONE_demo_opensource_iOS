//
//  AUILiveCameraPushModule.m
//  AlivcLiveDemo
//
//  Created by zzy on 2022/6/1.
//

#import "AUILiveCameraPushModule.h"

#ifdef ALIVC_LIVE_DEMO_ENABLE_CAMERAPUSH
#import "AUILivePushConfigViewController.h"
#endif

@interface AUILiveCameraPushModule ()

@property (nonatomic, strong) UIViewController *sourceVC;

@end

@implementation AUILiveCameraPushModule

- (instancetype)initWithSourceViewController:(UIViewController *)sourceVC {
    if (self = [super init]) {
        self.sourceVC = sourceVC;
    }
    return self;
}

- (void)open {
#ifdef ALIVC_LIVE_DEMO_ENABLE_CAMERAPUSH
    if (![AliveLiveDemoUtil getEssentialRights]) {
        return;
    }
    
    AUILivePushConfigViewController *vc = [[AUILivePushConfigViewController alloc] init];
    [self.sourceVC.navigationController pushViewController:vc animated:YES];
#else
    [AVToastView show:AlivcLiveString(@"未集成该组件") view:self.sourceVC.view position:AVToastViewPositionMid];
#endif
}

@end
