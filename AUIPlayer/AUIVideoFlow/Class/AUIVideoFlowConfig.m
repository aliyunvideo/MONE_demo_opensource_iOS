//
//  AUIVideoFlowConfig.m
//  AUIVideoFlow
//
//  Created by ISS013602000846 on 2022/6/13.
//

#import "AUIVideoFlowConfig.h"
#import "AlivcPlayerManager.h"
#import "AlivcPlayerVideoDBManager.h"

@implementation AUIVideoFlowConfig

- (void)didFinishLaunching {
    [[AlivcPlayerVideoDBManager shareManager] deleteHistoryTimeOut];
}

- (BOOL)shouldFlowOrientation {
    return [AlivcPlayerManager manager].shouldFlowOrientation;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientation {
    if ([AlivcPlayerManager manager].shouldFlowOrientation) {
        BOOL landscape =([AlivcPlayerManager manager].playContainView.window)&& [AlivcPlayerManager manager].currentOrientation != 0;
        if (landscape) {
            return UIInterfaceOrientationMaskLandscape;
        } else {
            return UIInterfaceOrientationMaskPortrait;
        }
    } else {
        return [UIViewController.av_topViewController supportedInterfaceOrientations];
    }
}

@end
