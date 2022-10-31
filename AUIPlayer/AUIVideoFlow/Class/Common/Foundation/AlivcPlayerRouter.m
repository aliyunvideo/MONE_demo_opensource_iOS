//
//  AlivcPlayerRouter.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/15.
//

#import "AlivcPlayerRouter.h"

@implementation AlivcPlayerRouter


+ (UIViewController *)currentViewController {
    
    UIViewController* vc = [UIApplication sharedApplication].delegate.window.rootViewController;
    
    while (1) {
        
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController*)vc).visibleViewController;
        }
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
        
    }
    
    return vc;
    
}
@end
