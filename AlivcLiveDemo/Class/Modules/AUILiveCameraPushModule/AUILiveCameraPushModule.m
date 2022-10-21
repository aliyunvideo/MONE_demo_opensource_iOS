//
//  AUILiveCameraPushModule.m
//  AlivcLiveDemo
//
//  Created by zzy on 2022/6/1.
//

#import "AUILiveCameraPushModule.h"
#import "AliveLiveDemoUtil.h"

@interface AUILiveCameraPushModule ()

@property (nonatomic, strong) UIViewController *sourceVC;
@property (nonatomic, assign) BOOL canOpen;

@end

@implementation AUILiveCameraPushModule

- (instancetype)initWithSourceViewController:(UIViewController *)sourceVC {
    if (self = [super init]) {
        self.sourceVC = sourceVC;
        self.canOpen = [AUILiveCameraPushModule checkCanOpen];
    }
    return self;
}

+ (BOOL)checkCanOpen {
    Class viewControllerClass = NSClassFromString(@"AUILivePushConfigViewController");
    UIViewController *vc = [[viewControllerClass alloc] init];
    if (vc) {
        return YES;
    } else {
        return NO;
    }
}

- (void)open {
    if (self.canOpen) {
        if (![AliveLiveDemoUtil getEssentialRights]) {
            return;
        }
        Class viewControllerClass = NSClassFromString(@"AUILivePushConfigViewController");
        UIViewController *vc = [[viewControllerClass alloc] init];
        [self.sourceVC.navigationController pushViewController:vc animated:YES];
    } else {
        [AVToastView show:@"未集成该功能" view:self.sourceVC.view position:AVToastViewPositionMid];
    }
}

@end
