//
//  UIImage+APColor.m
//  ApsaraVideo
//
//  Created by Bingo on 2021/7/2.
//

#import "UIImage+AVHelper.h"

@implementation UIImage (AVHelper)

+ (UIImage *)av_imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
