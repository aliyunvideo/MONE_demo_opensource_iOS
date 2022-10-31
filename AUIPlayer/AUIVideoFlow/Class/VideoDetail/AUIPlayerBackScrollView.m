//
//  AUIPlayerBackScrollView.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/8/17.
//

#import "AUIPlayerBackScrollView.h"

@implementation AUIPlayerBackScrollView

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint point = [gestureRecognizer locationInView:self];
        //保留右边返回手势
        if (point.x <= 36) {
            return NO;
        }
    }
    return YES;
    
}

@end
