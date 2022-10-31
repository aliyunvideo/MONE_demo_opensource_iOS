//
//  AUIPlayerCustomImageButton.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/22.
//

#import "AUIPlayerCustomImageButton.h"

@implementation AUIPlayerCustomImageButton

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    
    if (CGSizeEqualToSize( self.customSize, CGSizeZero)) {
        return [super imageRectForContentRect:contentRect];
    }
    
    CGSize size = self.customSize;

    CGFloat x = (contentRect.size.width - size.width)/2;
    CGFloat y = (contentRect.size.height - size.height)/2;


    return CGRectMake(x, y, size.width, size.height);
}

@end
