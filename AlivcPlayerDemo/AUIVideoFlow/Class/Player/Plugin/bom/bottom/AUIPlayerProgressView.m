//
//  AUIPlayerProgressView.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/23.
//

#import "AUIPlayerProgressView.h"

@interface AUIPlayerProgressView()
@property (nonatomic, strong) UIView *trackView;
@end

@implementation AUIPlayerProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.trackView];
    }
    return self;
}

- (UIView *)trackView
{
    if (!_trackView) {
        _trackView = [[UIView alloc]init];
        _trackView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"bomProgress_trackView");
    }
    return _trackView;
}

- (void)setProgress:(float)progress
{
    NSLog(@"progress:%f",progress);
    progress = MAX(0, progress);
    progress = MIN(1, progress);

    if (_progress != progress) {
        _progress = progress;
        [self setNeedsLayout];
    }
}

- (void)setTrackTintColor:(UIColor *)trackTintColor
{
    self.backgroundColor = trackTintColor;
}

- (void)setProgressTintColor:(UIColor *)progressTintColor
{
    self.trackView.backgroundColor = progressTintColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.trackView.frame = CGRectMake(0, 0, self.bounds.size.width * self.progress, self.bounds.size.height);
}
@end
