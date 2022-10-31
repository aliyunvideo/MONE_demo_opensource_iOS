//
//  AUIMediaProgressView.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/7.
//

#import "AUIMediaProgressView.h"
#import "UIView+AVHelper.h"
#import "AUIFoundation.h"
#import "AUIUgsvMacro.h"


@interface AUIMediaProgressView()

@property (nonatomic, strong) UILabel *showLabel;
@property (nonatomic, strong) CAShapeLayer *shaperLayer;

@end

@implementation AUIMediaProgressView
 
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.showLabel];
        [self.layer addSublayer:self.shaperLayer];
    }
    return self;
}
 

- (UILabel *)showLabel
{
    if (!_showLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.av_width - 20 *2, self.av_height)];
        label.textColor = AUIFoundationColor(@"text_strong");
        label.text = @"0%";
        label.font = AVGetMediumFont(26);
        label.textAlignment = NSTextAlignmentCenter;
        _showLabel = label;
    }

    return _showLabel;
}

- (CAShapeLayer *)shaperLayer
{
    if (!_shaperLayer) {
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.lineWidth =  8.0f;
        layer.strokeColor = AUIFoundationColor(@"text_strong").CGColor;

        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectInset(self.bounds, -4, -4)];
        layer.path = path.CGPath;
        layer.strokeStart   = 0.0f;
        layer.strokeEnd     = 0.0f;
        layer.speed = 0.5;
        _shaperLayer = layer;
    }
    
    return _shaperLayer;
}

- (void)setProgress:(float)progress
{
    progress = MAX(0, progress);
    progress = MIN(1, progress);

    if (_progress != progress) {
        _progress = progress;
        self.showLabel.text = [NSString stringWithFormat:@"%.0f%@",progress * 100  ,@"%"];
        self.shaperLayer.strokeEnd = progress;
    }
}

@end
