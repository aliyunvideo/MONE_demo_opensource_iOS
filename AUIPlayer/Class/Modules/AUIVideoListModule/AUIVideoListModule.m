//
//  AUIVideoListModule.m
//  AlivcPlayerDemo
//
//  Created by ISS013602000846 on 2022/5/30.
//

#import "AUIVideoListModule.h"
#import "AVToastView.h"

#if __has_include("AUIVideoCachePreloadTool.h")
#import "AUIVideoCachePreloadTool.h"
#define AUIVIDEOLIST_DEMO_ENABLE_CACHEPROLOAD
#endif

#if __has_include("AUIVideoFunctionListView.h")
#import "AUIVideoFunctionListView.h"
#define AUIVIDEOLIST_DEMO_ENABLE_FUNCTIONLIST
#endif

#if __has_include("AUIVideoStandradListView.h")
#import "AUIVideoStandradListView.h"
#define AUIVIDEOLIST_DEMO_ENABLE_STANDRADLIST
#endif

@interface AUIVideoListModule ()

@property (nonatomic, strong) UIViewController *sourceVC;

@end

@implementation AUIVideoListModule

- (instancetype)initWithSourceViewController:(UIViewController *)sourceVC {
    if (self = [super init]) {
        self.sourceVC = sourceVC;
        [self setLocalCache];
    }
    return self;
}

- (void)setLocalCache {
#ifdef AUIVIDEOLIST_DEMO_ENABLE_CACHEPROLOAD
    [AUIVideoCachePreloadTool setLocalCacheConfig];
#else
    [AVToastView show:AlivcPlayerString(@"No Mudule Tip") view:self.sourceVC.view position:AVToastViewPositionMid];
#endif
}

- (void)openFunctionListPage {
#ifdef AUIVIDEOLIST_DEMO_ENABLE_FUNCTIONLIST
    AUIVideoFunctionListView *vc = [[AUIVideoFunctionListView alloc] init];
    [self.sourceVC.navigationController pushViewController:vc animated:YES];
#else
    [AVToastView show:AlivcPlayerString(@"No Mudule Tip") view:self.sourceVC.view position:AVToastViewPositionMid];
#endif
}

- (void)openStandradListPage {
#ifdef AUIVIDEOLIST_DEMO_ENABLE_STANDRADLIST
    AUIVideoStandradListView *vc = [[AUIVideoStandradListView alloc] init];
    [self.sourceVC.navigationController pushViewController:vc animated:YES];
#else
    [AVToastView show:AlivcPlayerString(@"No Mudule Tip") view:self.sourceVC.view position:AVToastViewPositionMid];
#endif
}

@end
