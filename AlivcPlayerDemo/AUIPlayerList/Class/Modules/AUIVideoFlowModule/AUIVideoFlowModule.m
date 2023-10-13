//
//  AUIVideoFlowModule.m
//  AlivcPlayerDemo
//
//  Created by ISS013602000846 on 2022/6/2.
//

#import "AUIVideoFlowModule.h"
#import "AVToastView.h"

#ifdef ALIVC_PLAYER_DEMO_ENABLE_VIDEOFLOW
#import "AUIVideoFlowViewController.h"
#endif

@interface AUIVideoFlowModule ()

@property (nonatomic, strong) UIViewController *sourceVC;

@end

@implementation AUIVideoFlowModule

- (instancetype)initWithSourceViewController:(UIViewController *)sourceVC {
    if (self = [super init]) {
        self.sourceVC = sourceVC;
    }
    return self;
}

- (void)open {
#ifdef ALIVC_PLAYER_DEMO_ENABLE_VIDEOFLOW
    AUIVideoFlowViewController *vc = [[AUIVideoFlowViewController alloc] init];
    [self.sourceVC.navigationController pushViewController:vc animated:YES];
#else
    [AVToastView show:AlivcPlayerString(@"No Mudule Tip") view:self.sourceVC.view position:AVToastViewPositionMid];
#endif
}

@end
