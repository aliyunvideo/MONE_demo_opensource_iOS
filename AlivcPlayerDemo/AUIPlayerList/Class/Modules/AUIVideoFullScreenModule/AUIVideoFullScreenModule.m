//
//  AUIVideoFullScreenModule.m
//  AlivcPlayerDemo
//
//  Created by ISS013602000846 on 2022/6/2.
//

#import "AUIVideoFullScreenModule.h"
#import "AVActivityIndicator.h"

#ifdef ALIVC_PLAYER_DEMO_ENABLE_VIDEOFULLSCREEN
#import "AUIPlayerFullScreenPlayViewController.h"
#endif

@interface AUIVideoFullScreenModule ()

@property (nonatomic, strong) UIViewController *sourceVC;
@property (nonatomic, strong) AVActivityIndicator *indicator;

@end

@implementation AUIVideoFullScreenModule

- (instancetype)initWithSourceViewController:(UIViewController *)sourceVC {
    if (self = [super init]) {
        self.sourceVC = sourceVC;
    }
    return self;
}

- (void)open {
#ifdef ALIVC_PLAYER_DEMO_ENABLE_VIDEOFULLSCREEN
    AUIPlayerFullScreenPlayViewController *vc = [[AUIPlayerFullScreenPlayViewController alloc] init];
    self.indicator = [AVActivityIndicator start:self.sourceVC.view];
    __weak typeof(self) weakSelf = self;
    [vc requestURL:^(BOOL success) {
        __strong typeof(self) strongSelf = weakSelf;
        [AVActivityIndicator stop:strongSelf.indicator];
        if (success) {
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [strongSelf.sourceVC presentViewController:vc animated:YES completion:nil];
        } else {
            [AVToastView show:AlivcPlayerString(@"获取到播放地址失败") view:self.sourceVC.view position:AVToastViewPositionMid];
        }
    }];
#else
    [AVToastView show:AlivcPlayerString(@"未集成该组件") view:self.sourceVC.view position:AVToastViewPositionMid];
#endif
}

@end
