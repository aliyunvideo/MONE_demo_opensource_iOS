//
//  AUIVideoFlowModule.m
//  AlivcPlayerDemo
//
//  Created by ISS013602000846 on 2022/6/2.
//

#import "AUIVideoFlowModule.h"
#import "AVToastView.h"

@interface AUIVideoFlowModule ()

@property (nonatomic, strong) UIViewController *sourceVC;

@end

@implementation AUIVideoFlowModule

- (instancetype)initWithSourceViewController:(UIViewController *)sourceVC {
    if (self = [super init]) {
        self.sourceVC = sourceVC;
    }
    return self;
}

- (void)open {
    Class viewControllerClass = NSClassFromString(@"AUIVideoFlowViewController");
    UIViewController *vc = [[viewControllerClass alloc] init];
    if (vc) {
        [self.sourceVC.navigationController pushViewController:vc animated:YES];
    } else {
        [AVToastView show:@"未集成该功能" view:self.sourceVC.view position:AVToastViewPositionMid];
    }
}

@end
