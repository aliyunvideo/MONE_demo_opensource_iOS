//
//  AUILiveRtsPlayModule.m
//  AlivcLiveDemo
//
//  Created by ISS013602000846 on 2022/7/22.
//

#import "AUILiveRtsPlayModule.h"

#ifdef ALIVC_LIVE_DEMO_ENABLE_RTSPLAY
#import "AUILiveRtsPlayInputViewController.h"
#endif

@interface AUILiveRtsPlayModule ()

@property (nonatomic, strong) UIViewController *sourceVC;

@end

@implementation AUILiveRtsPlayModule

- (instancetype)initWithSourceViewController:(UIViewController *)sourceVC {
    if (self = [super init]) {
        self.sourceVC = sourceVC;
    }
    return self;
}

- (void)open {
#ifdef ALIVC_LIVE_DEMO_ENABLE_RTSPLAY
    AUILiveRtsPlayInputViewController *vc = [[AUILiveRtsPlayInputViewController alloc] init];
    [self.sourceVC.navigationController pushViewController:vc animated:YES];
#else
    [AVToastView show:AlivcLiveString(@"未集成该组件") view:self.sourceVC.view position:AVToastViewPositionMid];
#endif
}

@end
