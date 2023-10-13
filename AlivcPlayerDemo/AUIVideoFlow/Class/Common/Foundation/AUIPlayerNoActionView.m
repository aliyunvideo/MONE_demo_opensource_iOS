//
//  AUIPlayerNoActionView.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/8/2.
//

#import "AUIPlayerNoActionView.h"

@implementation AUIPlayerNoActionView


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    
    return  view == self ? nil : view;
}

@end
