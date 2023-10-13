//
//  AUILiveChartView.m
//  AlivcLiveCaptureDev
//
//  Created by TripleL on 2017/10/9.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import "AUILiveChartView.h"

@interface AUILiveChartView ()

@property (nonatomic, strong) CAShapeLayer *backgroundLayer;
@property (nonatomic, strong) UIBezierPath *backgroundPath;
@property (nonatomic, strong) CAShapeLayer *barLayer;
@property (nonatomic, strong) UIBezierPath *barPath;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UILabel *titleLabel;


@end

@implementation AUILiveChartView


- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupDefaultValue];
        [self setupSubViews];
    }
    return self;
}



- (instancetype)initWithFrame:(CGRect)frame
              backgroundColor:(UIColor *)backgroundColor
                     barColor:(UIColor *)barColor
                     barTitle:(NSString *)title
             barTotalProgress:(CGFloat)barTotalProgress {
    
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundColor = backgroundColor;
        _barColor = barColor;
        _barTitle = title;
        _barTotalProgress = barTotalProgress;
        [self setupSubViews];
    }
    return self;
}


- (void)setupDefaultValue {
    
    _backgroundColor = [UIColor grayColor];
    _barColor = [UIColor redColor];
    _barTitle = nil;
    _barTotalProgress = 1.0;
}


- (void)setupSubViews {
    
    [self setupBarTitle];
    
    [self setupBarText];
    
    [self setupBackground];
    
    [self setupProgress];
    
}




- (void)setupBackground {
    
    self.backgroundLayer = [[CAShapeLayer alloc] init];
    [self.layer addSublayer:self.backgroundLayer];
    self.backgroundLayer.fillColor = self.backgroundColor.CGColor;
    self.backgroundLayer.frame = CGRectMake(CGRectGetMaxX(self.textLabel.frame) + 5, 0, AlivcSizeWidth(180), CGRectGetHeight(self.frame));
    
    self.backgroundPath = [UIBezierPath bezierPathWithRect:self.backgroundLayer.bounds];
    [self.backgroundPath setLineCapStyle:kCGLineCapSquare];
    self.backgroundLayer.path = self.backgroundPath.CGPath;
}



- (void)setupProgress {
    
    self.barLayer = [[CAShapeLayer alloc] init];
    [self.layer addSublayer:self.barLayer];
    self.barLayer.fillColor = self.barColor.CGColor;
    self.barLayer.lineCap = kCALineCapSquare;
    self.barLayer.frame = CGRectMake(CGRectGetMaxX(self.textLabel.frame) + 5, 0, AlivcSizeWidth(180), CGRectGetHeight(self.frame));;
    
    self.barPath = [UIBezierPath bezierPathWithRect:CGRectZero];
    [self.barPath setLineCapStyle:kCGLineCapSquare];
    
    self.barLayer.path = self.barPath.CGPath;
}


- (void)setupBarTitle {
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.frame = CGRectMake(0, 0, AlivcSizeWidth(75), CGRectGetHeight(self.frame));
    self.titleLabel.text = self.barTitle;
    self.titleLabel.font = [UIFont systemFontOfSize:14.f];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.textColor = self.barColor;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [self addSubview:self.titleLabel];
    
}


- (void)setupBarText {
    
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.frame = CGRectMake(CGRectGetMaxX(self.titleLabel.frame), 0, AlivcSizeWidth(30), CGRectGetHeight(self.frame));
    self.textLabel.text = @"0";
    self.textLabel.font = [UIFont systemFontOfSize:14.f];
    self.textLabel.textAlignment = NSTextAlignmentRight;
    self.textLabel.textColor = self.barColor;
    [self addSubview:self.textLabel];
}


- (void)updateBarProgress:(CGFloat)progress {
    
    if (progress > self.barTotalProgress) {
        progress = self.barTotalProgress;
    }
    
    CGFloat width = progress / self.barTotalProgress * self.barLayer.bounds.size.width;

    dispatch_async(dispatch_get_main_queue(), ^{
        self.barPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width, self.bounds.size.height)];
        self.barLayer.path = self.barPath.CGPath;
        self.textLabel.text = [NSString stringWithFormat:@"%.f", progress];
        
    });

}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    
    _backgroundColor = backgroundColor;
    _backgroundLayer.fillColor = backgroundColor.CGColor;
}



- (void)setBarColor:(UIColor *)barColor {
    
    _barColor = barColor;
    _barLayer.fillColor = barColor.CGColor;
}



// 设置标题
- (void)setBarTitle:(NSString *)barTitle {
    
    _barTitle = barTitle;
    self.titleLabel.text = barTitle;
}

// 渐变动画
- (CABasicAnimation*)fadeAnimation {
    
    CABasicAnimation* fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    fadeAnimation.toValue = [NSNumber numberWithFloat:1.0];
    fadeAnimation.duration = 2.0;
    
    return fadeAnimation;
}
@end
