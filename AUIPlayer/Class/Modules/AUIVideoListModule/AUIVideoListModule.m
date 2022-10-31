//
//  AUIVideoListModule.m
//  AlivcPlayerDemo
//
//  Created by ISS013602000846 on 2022/5/30.
//

#import "AUIVideoListModule.h"
#import "AVToastView.h"

@interface AUIVideoListModule ()

@property (nonatomic, strong) UIViewController *sourceVC;

@end

@implementation AUIVideoListModule

- (instancetype)initWithSourceViewController:(UIViewController *)sourceVC {
    if (self = [super init]) {
        self.sourceVC = sourceVC;
        [self cache];
    }
    return self;
}

- (void)cache {
    Class toolClass = NSClassFromString(@"AUIVideoListTool");
    NSObject *tool = [[toolClass alloc] init];
    if ([tool respondsToSelector:@selector(setDefalutCache)]) {
        [tool performSelector:@selector(setDefalutCache)];
    }
}

- (void)open {
    Class viewControllerClass = NSClassFromString(@"AUIVideoListPlayerViewController");
    UIViewController *vc = [[viewControllerClass alloc] init];
    if (vc) {
        [self.sourceVC.navigationController pushViewController:vc animated:YES];
    } else {
        [AVToastView show:@"未集成该功能" view:self.sourceVC.view position:AVToastViewPositionMid];
    }
}

@end
