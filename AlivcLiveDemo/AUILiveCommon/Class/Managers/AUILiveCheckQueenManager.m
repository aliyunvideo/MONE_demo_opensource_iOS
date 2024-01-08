//
//  AUILiveCheckQueenManager.m
//  AlivcLivePusherDemo
//
//  Created by ISS013602000846 on 2022/8/16.
//  Copyright © 2022 TripleL. All rights reserved.
//

#import "AUILiveCheckQueenManager.h"
#import "AUIBeautyManager.h"
#import "AVProgressHUD.h"


@implementation AUILiveCheckQueenManager

+ (void)checkWithCurrentView:(UIView *)view completed:(void (^)(BOOL completed))completed {
#ifdef ALIVC_LIVE_ENABLE_QUEEN_PRO
    id<AUIBeautyResourceProtocol> resource = [AUIBeautyManager resourceChecker];
    if (resource) {
        AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:view animated:YES];
        loading.labelText = AUILiveCommonString(@"正在下载美颜模型中，请等待");
        [[AUIBeautyManager resourceChecker] checkResource:^(BOOL succ) {
            [loading hideAnimated:NO];
            if (completed) {
                completed(succ);
            }
        }];
    }
    else {
        if (completed) {
            completed(YES);
        }
    }
#else
    if (completed) {
        completed(YES);
    }
#endif
}

@end
