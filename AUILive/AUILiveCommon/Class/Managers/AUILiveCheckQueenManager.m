//
//  AUILiveCheckQueenManager.m
//  AlivcLivePusherDemo
//
//  Created by ISS013602000846 on 2022/8/16.
//  Copyright © 2022 TripleL. All rights reserved.
//

#import "AUILiveCheckQueenManager.h"
#import "AUILiveSDKHeader.h"
#import "AVProgressHUD.h"

@interface AUILiveCheckQueenManager ()<QueenMaterialDelegate>

@property (nonatomic, copy) void (^checkResult)(BOOL completed);
@property (nonatomic, strong) AVProgressHUD *hub;

@end

@implementation AUILiveCheckQueenManager

+ (instancetype)manager {
    static AUILiveCheckQueenManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AUILiveCheckQueenManager alloc] init];
    });
    return manager;
}

+ (void)checkWithCurrentView:(UIView *)view completed:(void (^)(BOOL completed))completed {
    [AUILiveCheckQueenManager manager].checkResult = completed;
    [[AUILiveCheckQueenManager manager] startCheckWithCurrentView:view];
}

- (void)startCheckWithCurrentView:(UIView *)view {
    
    BOOL result = [[QueenMaterial sharedInstance] requestMaterial:kQueenMaterialModel];
    if (!result) {
        if (self.checkResult) {
            self.checkResult(YES);
        }
    }
    else {
        [self.hub hideAnimated:NO];
        
        AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:view animated:YES];
        loading.labelText = NSLocalizedString(@"正在下载美颜模型中，请等待", nil);
        self.hub = loading;
        
        [QueenMaterial sharedInstance].delegate = self;
    }
}

#pragma mark - QueenMaterialDelegate

- (void)queenMaterialOnReady:(kQueenMaterialType)type
{
    // 资源下载成功
    if (type == kQueenMaterialModel) {
        [self.hub hideAnimated:YES];
        self.hub = nil;
        if (self.checkResult) {
            self.checkResult(YES);
        }
    }
}

- (void)queenMaterialOnProgress:(kQueenMaterialType)type withCurrentSize:(int)currentSize withTotalSize:(int)totalSize withProgess:(float)progress
{
    // 资源下载进度回调
    if (type == kQueenMaterialModel) {
        NSLog(@"====正在下载资源模型，进度：%f", progress);
    }
}

- (void)queenMaterialOnError:(kQueenMaterialType)type
{
    // 资源下载出错
    if (type == kQueenMaterialModel){
        [self.hub hideAnimated:YES];
        self.hub = nil;
        if (self.checkResult) {
            self.checkResult(NO);
        }
    }
}

@end
