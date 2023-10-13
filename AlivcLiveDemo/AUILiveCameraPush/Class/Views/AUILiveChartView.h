//
//  AUILiveChartView.h
//  AlivcLiveCaptureDev
//
//  Created by TripleL on 2017/10/9.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AUILiveChartView : UIView

/**
 背景颜色
 */
@property (nonatomic, strong) UIColor *backgroundColor;


/**
 柱状图颜色
 */
@property (nonatomic, strong) UIColor *barColor;


/**
 柱状图总长度
 */
@property (nonatomic, assign) CGFloat barTotalProgress;


/**
 标题
 */
@property (nonatomic, strong) NSString *barTitle;


/**
 数值
 */
@property (nonatomic, strong, readonly) NSString *barText;


- (instancetype)initWithFrame:(CGRect)frame
              backgroundColor:(UIColor *)backgroundColor
                     barColor:(UIColor *)barColor
                     barTitle:(NSString *)title
             barTotalProgress:(CGFloat)barTotalProgress;


/**
 修改柱状图progres
 
 @param progress 范围 [0:barTotalProgress]
 */
- (void)updateBarProgress:(CGFloat)progress;


@end
