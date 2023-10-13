//
//  AUIVideoListModule.m
//  AlivcPlayerDemo
//
//  Created by ISS013602000846 on 2022/5/30.
//

#import "AUIVideoListModule.h"
#import "AVToastView.h"

#ifdef ALIVC_PLAYER_DEMO_ENABLE_ENABLE_VIDEOLIST_FUNCTIONLIST
#import "AUIVideoFunctionListView.h"
#endif

#ifdef ALIVC_PLAYER_DEMO_ENABLE_ENABLE_VIDEOLIST_STANDRADLIST
#import "AUIVideoStandradListView.h"
#endif

@interface AUIVideoListModule ()

@property (nonatomic, strong) UIViewController *sourceVC;

@end

@implementation AUIVideoListModule

- (instancetype)initWithSourceViewController:(UIViewController *)sourceVC {
    if (self = [super init]) {
        self.sourceVC = sourceVC;
    }
    return self;
}

- (void)openFunctionListPage {
#ifdef ALIVC_PLAYER_DEMO_ENABLE_ENABLE_VIDEOLIST_FUNCTIONLIST
    AUIVideoFunctionListView *vc = [[AUIVideoFunctionListView alloc] init];
    [self.sourceVC.navigationController pushViewController:vc animated:YES];
#else
    [AVToastView show:AlivcPlayerString(@"No Mudule Tip") view:self.sourceVC.view position:AVToastViewPositionMid];
#endif
}

- (void)openStandradListPage {
#ifdef ALIVC_PLAYER_DEMO_ENABLE_ENABLE_VIDEOLIST_STANDRADLIST
    AUIVideoStandradListView *vc = [[AUIVideoStandradListView alloc] init];
    [self.sourceVC.navigationController pushViewController:vc animated:YES];
#else
    [AVToastView show:AlivcPlayerString(@"No Mudule Tip") view:self.sourceVC.view position:AVToastViewPositionMid];
#endif
}

@end
