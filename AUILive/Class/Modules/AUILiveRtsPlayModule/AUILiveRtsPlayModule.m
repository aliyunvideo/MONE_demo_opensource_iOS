//
//  AUILiveRtsPlayModule.m
//  AlivcLiveDemo
//
//  Created by ISS013602000846 on 2022/7/22.
//

#import "AUILiveRtsPlayModule.h"

@interface AUILiveRtsPlayModule ()

@property (nonatomic, strong) UIViewController *sourceVC;
@property (nonatomic, assign) BOOL canOpen;

@end

@implementation AUILiveRtsPlayModule

- (instancetype)initWithSourceViewController:(UIViewController *)sourceVC {
    if (self = [super init]) {
        self.sourceVC = sourceVC;
        self.canOpen = [AUILiveRtsPlayModule checkCanOpen];
    }
    return self;
}

+ (BOOL)checkCanOpen {
    Class viewControllerClass = NSClassFromString(@"AUILiveRtsPlayInputViewController");
    UIViewController *vc = [[viewControllerClass alloc] init];
    if (vc) {
        return YES;
    } else {
        return NO;
    }
}

- (void)open {
    if (self.canOpen) {
        Class viewControllerClass = NSClassFromString(@"AUILiveRtsPlayInputViewController");
        UIViewController *vc = [[viewControllerClass alloc] init];
        [self.sourceVC.navigationController pushViewController:vc animated:YES];
    } else {
        [AVToastView show:@"未集成该功能" view:self.sourceVC.view position:AVToastViewPositionMid];
    }
}

@end
