//
//  AUILiveSweepCodeView.h
//  AlivcLiveCaptureDev
//
//  Created by lyz on 2017/9/28.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AUILiveSweepCodeViewDelegate <NSObject>

- (void)onClickSweepCodeViewLightButton:(BOOL)isLight;

@end

@interface AUILiveSweepCodeView : UIView

@property (nonatomic, weak) id<AUILiveSweepCodeViewDelegate> delegate;

@end
