//
//  UIView+AUIPlayerHelper.m
//  ApsaraVideo
//
//  Created by Bingo on 2021/7/6.
//

#import "UIView+AUIPlayerHelper.h"
#import <MBProgressHUD/MBProgressHUD.h>

@implementation UIView (AUIPlayerHelper)

- (void)ap_showTips:(NSString *)tips {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.bezelView.blurEffectStyle = UIBlurEffectStyleDark;
    hud.contentColor = [UIColor whiteColor];
    hud.userInteractionEnabled = NO;
    hud.label.text = tips;
    [hud hideAnimated:YES afterDelay:3.0f];
}

+ (CAGradientLayer *)bgGradientLayer
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    UIColor *color1 = [[UIColor blackColor] colorWithAlphaComponent:0.9];
    UIColor *color2 = [[UIColor blackColor] colorWithAlphaComponent:0.53];
    UIColor *color3 = [[UIColor blackColor] colorWithAlphaComponent:0.35];
    UIColor *color4 = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    UIColor *color5 = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    
    
    gradientLayer.colors = @[ (__bridge id) color5.CGColor, (__bridge id) color4.CGColor, (__bridge id) color3.CGColor, (__bridge id) color2.CGColor, (__bridge id) color1.CGColor];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.locations = @[@0,@(2.0/12.0),@(4.0/12.0),@(6.0/12.0),@(12.0/12.0)];
    
    return gradientLayer;
 
}

@end
