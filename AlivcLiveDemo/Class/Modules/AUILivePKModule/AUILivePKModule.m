//
//  AUILivePKModule.m
//  AlivcLiveDemo
//
//  Created by ISS013602000846 on 2022/7/22.
//

#import "AUILivePKModule.h"
#import "AliveLiveDemoUtil.h"
#import "AUILiveURLConfigManager.h"

@interface AUILivePKModule ()

@property (nonatomic, strong) UIViewController *sourceVC;
@property (nonatomic, assign) BOOL canOpen;

@end

@implementation AUILivePKModule

- (instancetype)initWithSourceViewController:(UIViewController *)sourceVC {
    if (self = [super init]) {
        self.sourceVC = sourceVC;
        self.canOpen = [AUILivePKModule checkCanOpen];
    }
    return self;
}

+ (BOOL)checkCanOpen {
    Class viewControllerClass = NSClassFromString(@"AUILivePKConfigViewController");
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
            Class viewControllerClass = NSClassFromString(@"AUILivePKConfigViewController");
            UIViewController *vc = [[viewControllerClass alloc] init];
            [self.sourceVC.navigationController pushViewController:vc animated:YES];
        } else {
            Class viewControllerClass = NSClassFromString(@"AUILiveInteractiveURLConfigViewController");
            UIViewController *vc = [[viewControllerClass alloc] init];
            [vc setValue:@(1) forKey:@"type"];
            [self.sourceVC.navigationController pushViewController:vc animated:YES];
        }
    } else {
        [AVToastView show:@"未集成该功能" view:self.sourceVC.view position:AVToastViewPositionMid];
    }
}

@end
