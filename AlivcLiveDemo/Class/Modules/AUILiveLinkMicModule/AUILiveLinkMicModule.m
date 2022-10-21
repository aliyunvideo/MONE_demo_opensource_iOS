//
//  AUILiveLinkMicModule.m
//  AlivcLiveDemo
//
//  Created by ISS013602000846 on 2022/7/22.
//

#import "AUILiveLinkMicModule.h"
#import "AliveLiveDemoUtil.h"
#import "AUILiveURLConfigManager.h"

@interface AUILiveLinkMicModule ()

@property (nonatomic, strong) UIViewController *sourceVC;
@property (nonatomic, assign) BOOL canOpen;

@end

@implementation AUILiveLinkMicModule

- (instancetype)initWithSourceViewController:(UIViewController *)sourceVC {
    if (self = [super init]) {
        self.sourceVC = sourceVC;
        self.canOpen = [AUILiveLinkMicModule checkCanOpen];
    }
    return self;
}

+ (BOOL)checkCanOpen {
    Class viewControllerClass = NSClassFromString(@"AUILiveLinkMicConfigViewController");
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
        
        if ([[AUILiveURLConfigManager manager] haveConfig]) {
            Class viewControllerClass = NSClassFromString(@"AUILiveLinkMicConfigViewController");
            UIViewController *vc = [[viewControllerClass alloc] init];
            [self.sourceVC.navigationController pushViewController:vc animated:YES];
        } else {
            Class viewControllerClass = NSClassFromString(@"AUILiveInteractiveURLConfigViewController");
            UIViewController *vc = [[viewControllerClass alloc] init];
            [vc setValue:@(0) forKey:@"type"];
            [self.sourceVC.navigationController pushViewController:vc animated:YES];
        }
    } else {
        [AVToastView show:@"未集成该功能" view:self.sourceVC.view position:AVToastViewPositionMid];
    }
}

@end
