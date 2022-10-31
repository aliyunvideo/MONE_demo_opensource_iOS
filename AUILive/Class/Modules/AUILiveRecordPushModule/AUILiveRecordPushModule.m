//
//  AUILiveRecordPushModule.m
//  AlivcLiveDemo
//
//  Created by zzy on 2022/6/1.
//

#import "AUILiveRecordPushModule.h"
#import "AliveLiveDemoUtil.h"

#define AlivcPlayerFirstLaunch_AUILiveRecordPush_firshOpenKey @"AlivcPlayerFirstLaunch_AUILiveRecordPush_firshOpenKey"

@interface AUILiveRecordPushModule ()

@property (nonatomic, strong) UIViewController *sourceVC;
@property (nonatomic, assign) BOOL canOpen;

@end

@implementation AUILiveRecordPushModule

- (instancetype)initWithSourceViewController:(UIViewController *)sourceVC {
    if (self = [super init]) {
        self.sourceVC = sourceVC;
        self.canOpen = [AUILiveRecordPushModule checkCanOpen];
    }
    return self;
}

+ (BOOL)checkCanOpen {
    Class tipViewControllerClass = NSClassFromString(@"AUILivePushReplayKitTipViewController");
    UIViewController *tipVC = [[tipViewControllerClass alloc] init];
    Class configViewControllerClass = NSClassFromString(@"AUILivePushReplayKitConfigViewController");
    UIViewController *configVC = [[configViewControllerClass alloc] init];
    if (tipVC && configVC) {
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
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:AlivcPlayerFirstLaunch_AUILiveRecordPush_firshOpenKey]) {
            Class tipViewControllerClass = NSClassFromString(@"AUILivePushReplayKitTipViewController");
            UIViewController *tipVC = [[tipViewControllerClass alloc] init];
            [self.sourceVC av_presentFullScreenViewController:tipVC animated:YES completion:nil];
        } else {
            Class configViewControllerClass = NSClassFromString(@"AUILivePushReplayKitConfigViewController");
            UIViewController *configVC = [[configViewControllerClass alloc] init];
            [self.sourceVC.navigationController pushViewController:configVC animated:YES];
        }
    } else {
        [AVToastView show:@"未集成该功能" view:self.sourceVC.view position:AVToastViewPositionMid];
    }
}

@end
