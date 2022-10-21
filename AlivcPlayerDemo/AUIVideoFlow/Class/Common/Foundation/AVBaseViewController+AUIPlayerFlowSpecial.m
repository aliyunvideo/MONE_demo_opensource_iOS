//
//  AVBaseViewController+AUIPlayerFlowSpecial.m
//  AUIVideoFlow
//
//  Created by ISS013602000846 on 2022/6/17.
//

#import "AVBaseViewController+AUIPlayerFlowSpecial.h"

@implementation AVBaseViewController (AUIPlayerFlowSpecial)

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
