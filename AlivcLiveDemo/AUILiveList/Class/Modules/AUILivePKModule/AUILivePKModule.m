//
//  AUILivePKModule.m
//  AlivcLiveDemo
//
//  Created by ISS013602000846 on 2022/7/22.
//

#import "AUILivePKModule.h"

#ifdef ALIVC_LIVE_DEMO_ENABLE_PK
#import "AUILiveURLConfigManager.h"
#import "AUILiveInteractiveURLConfigViewController.h"
#import "AUILivePKConfigViewController.h"
#endif

@interface AUILivePKModule ()

@property (nonatomic, strong) UIViewController *sourceVC;

@end

@implementation AUILivePKModule

- (instancetype)initWithSourceViewController:(UIViewController *)sourceVC {
    if (self = [super init]) {
        self.sourceVC = sourceVC;
    }
    return self;
}

- (void)open {
#ifdef ALIVC_LIVE_DEMO_ENABLE_PK
    if (![AliveLiveDemoUtil getEssentialRights]) {
        return;
    }
    
    if ([[AUILiveURLConfigManager manager] haveConfig]) {
        AUILivePKConfigViewController *vc = [[AUILivePKConfigViewController alloc] init];
        [self.sourceVC.navigationController pushViewController:vc animated:YES];
    } else {
        AUILiveInteractiveURLConfigViewController *vc = [[AUILiveInteractiveURLConfigViewController alloc] init];
        vc.type = AUILiveInteractiveURLConfigTypePK;
        [self.sourceVC.navigationController pushViewController:vc animated:YES];
    }
#else
    [AVToastView show:AlivcLiveString(@"未集成该组件") view:self.sourceVC.view position:AVToastViewPositionMid];
#endif
}

@end
