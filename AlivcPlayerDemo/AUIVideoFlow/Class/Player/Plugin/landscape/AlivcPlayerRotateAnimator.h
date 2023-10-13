//
//  AlivcPlayerRotateAnimator.h
//  ScreenRotate
//
//  Created by mengyehao on 2021/6/30.
//  Copyright © 2021 zuiye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlivcPlayerRotateAnimator : NSObject<UIViewControllerAnimatedTransitioning,UIViewControllerTransitioningDelegate>

@property (nonatomic, weak) UIView *playView;

@property (nonatomic) CGRect playViewOriginFrame;

@property (nonatomic) BOOL toLeft;




+ (BOOL)isAimationing;

@end


