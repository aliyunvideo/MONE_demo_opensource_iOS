//
//  AUIVideoFullScreenModule.m
//  AlivcPlayerDemo
//
//  Created by ISS013602000846 on 2022/6/2.
//

#import "AUIVideoFullScreenModule.h"
#import "AVActivityIndicator.h"

@interface AUIVideoFullScreenModule ()

@property (nonatomic, strong) UIViewController *sourceVC;
@property (nonatomic, strong) AVActivityIndicator *indicator;

@end

@implementation AUIVideoFullScreenModule

- (instancetype)initWithSourceViewController:(UIViewController *)sourceVC {
    if (self = [super init]) {
        self.sourceVC = sourceVC;
    }
    return self;
}

- (void)open {
    Class viewControllerClass = NSClassFromString(@"AUIPlayerFullScreenPlayViewController");
    UIViewController *vc = [[viewControllerClass alloc] init];
    if (vc) {
        self.indicator = [AVActivityIndicator start:self.sourceVC.view];
        __weak typeof(self) weakSelf = self;
        void(^requestURLCompletion)(BOOL) = ^(BOOL success) {
            __strong typeof(self) strongSelf = weakSelf;
            [AVActivityIndicator stop:strongSelf.indicator];
            if (success) {
                vc.modalPresentationStyle = UIModalPresentationFullScreen;
                [strongSelf.sourceVC presentViewController:vc animated:YES completion:nil];
            } else {
                [AVToastView show:@"未获取到数据" view:self.sourceVC.view position:AVToastViewPositionMid];
            }
        };
        
        if ([vc respondsToSelector:@selector(requestURL:)]) {
            [vc performSelector:@selector(requestURL:) withObject:requestURLCompletion];
        }
    } else {
        [AVToastView show:@"未集成该功能" view:self.sourceVC.view position:AVToastViewPositionMid];
    }
}

@end
