//
//  AlivcPlayerRotateAnimator.m
//  ScreenRotate
//
//  Created by mengyehao on 2021/6/30.
//  Copyright © 2021 zuiye. All rights reserved.
//

#import "AlivcPlayerRotateAnimator.h"

static BOOL kIsAimationing = NO;

@interface AlivcPlayerRotateAnimator()

@property (nonatomic, weak) UIView *playViewSuper;

@end

@implementation AlivcPlayerRotateAnimator


#pragma mark - UIViewControllerAnimatedTransitioning

+ (BOOL)isAimationing
{
    return kIsAimationing;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.25;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = [transitionContext containerView];
    
    //FromVC
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    
    //ToVC
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    
    BOOL isPresent = [fromViewController.presentedViewController isEqual:toViewController];
    
    
    if (isPresent) {
        
        self.playViewSuper = self.playView.superview;
        
        // 计算toView的初始位置
        CGPoint  initialCenter = [containerView convertPoint:self.playView.center fromView:self.playView];
        [containerView addSubview:toView];

        // 将toView的 位置变为初始位置，准备动画
        [toView addSubview:self.playView];

        toView.bounds = self.playView.bounds;
        toView.center = initialCenter;

        toView.transform = self.toLeft ? CGAffineTransformMakeRotation(-M_PI_2) :CGAffineTransformMakeRotation(M_PI_2) ;

        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            kIsAimationing= YES;
            // 将 toView 从设置的初始位置回复到正常位置
            toView.transform = CGAffineTransformIdentity;
            toView.frame = transitionContext.containerView.bounds;
            self.playView.frame = toView.bounds;


        } completion:^(BOOL finished) {
            kIsAimationing = NO;
            BOOL wasCancelled = [transitionContext transitionWasCancelled];
            [transitionContext completeTransition:!wasCancelled];
        }];

        
    } else {
        
        CGFloat screenWidth =  [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight =   [UIScreen mainScreen].bounds.size.height;

        CGFloat maxValue = MAX(screenWidth,screenHeight);
        CGFloat minValue = MIN(screenWidth,screenHeight);
        
        UIView *videoContainerView = self.playViewSuper;

        CGRect toFrame = [videoContainerView convertRect:videoContainerView.bounds toView:videoContainerView.window];
        
        CGRect fromBounds = CGRectMake(0, 0, minValue, maxValue);
        
        UIView *playerTransitionView = fromView;
        
        playerTransitionView.frame = fromBounds;


        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            
            playerTransitionView.transform = CGAffineTransformIdentity;
            playerTransitionView.frame = toFrame;
            self.playView.frame = playerTransitionView.bounds;

        } completion:^(BOOL finished) {
            

            [self.playViewSuper addSubview:self.playView];
            [playerTransitionView removeFromSuperview];
            
            BOOL wasCancelled = [transitionContext transitionWasCancelled];
            [transitionContext completeTransition:!wasCancelled];
        }];
    }
}


#pragma mark - UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self;
}



- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self;
}

@end
