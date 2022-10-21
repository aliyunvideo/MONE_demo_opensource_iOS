//
//  AUIRecorderProgressView.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/6.
//

#import "AUIRecorderProgressView.h"
#import "AUIUgsvMacro.h"
#import "AUIFoundationMacro.h"
#import "AVCircularProgressView.h"
#import "Masonry.h"

const static CGFloat ProgressLineWidth = 3.0;

@interface AUIRecorderPartDuration : NSObject
@property (nonatomic, readonly) NSTimeInterval maxDuration;
@property (nonatomic, readonly) NSTimeInterval beginTime;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) NSTimeInterval endTime;
@property (nonatomic, readonly) CAShapeLayer *layer;
@property (nonatomic, assign) CGFloat radius;
- (instancetype)initWithBeginTime:(NSTimeInterval)beginTime
                         duration:(NSTimeInterval)duration
                      maxDuration:(NSTimeInterval)maxDuration
                           radius:(CGFloat)radius;
- (void)updateWithBeginTime:(NSTimeInterval)beginTime duration:(NSTimeInterval)duration;
@end

@interface AUIRecorderProgressView ()
{
    NSMutableArray<AUIRecorderPartDuration *> *_partDurations;
}
@property (nonatomic, strong) AVCircularProgressView *progressView;
@end

@implementation AUIRecorderProgressView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.userInteractionEnabled = NO;
        _partDurations = @[].mutableCopy;
        
        _progressView = [AVCircularProgressView new];
        _progressView.lineWidth = ProgressLineWidth;
        _progressView.lineCap = kCALineCapButt;
        _progressView.animationFullDuration = 1.0;
        _progressView.progressTintColor = AUIFoundationColor(@"colourful_fill_ultrastrong");
        _progressView.trackTintColor = AUIFoundationColor(@"fill_infrared");
        [self addSubview:_progressView];
        [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (NSTimeInterval) lastDuration {
    if (_partDurations.count > 0) {
        return _partDurations.lastObject.endTime;
    }
    return 0;
}

- (NSTimeInterval) totalDuration {
    return self.lastDuration + self.currentPartDuration;
}

- (void)updateProgressUI {
    [_progressView setProgress:(self.totalDuration/self.maxDuration) animated:YES];
}

- (void) setCurrentPartDuration:(NSTimeInterval)currentPartDuration {
    currentPartDuration = MAX(0.0, currentPartDuration);
    // current只增不减，等setPartDurations再去同步（影响效果）
    if (_currentPartDuration >= currentPartDuration) {
        return;
    }
    _currentPartDuration = currentPartDuration;
    [self updateProgressUI];
}

- (NSArray<NSNumber *> *) partDurations {
    NSMutableArray<NSNumber *> *ret = @[].mutableCopy;
    for (AUIRecorderPartDuration *parts in _partDurations) {
        [ret addObject:@(parts.duration)];
    }
    return ret;
}

- (CGFloat) radius {
    return self.bounds.size.width * 0.5;
}

- (void) setPartDurations:(NSArray<NSNumber *> *)partDurations {
    NSTimeInterval beginTime = 0;
    int i = 0, j = 0;
    for (;i < partDurations.count && j < _partDurations.count; ++i, ++j) {
        NSTimeInterval duration = partDurations[i].doubleValue;
        [_partDurations[j] updateWithBeginTime:beginTime duration:duration];
        beginTime += duration;
    }
    
    CGFloat radius = self.radius;
    for (; i < partDurations.count; ++i, ++j) {
        NSTimeInterval duration = partDurations[i].doubleValue;
        AUIRecorderPartDuration *part = [[AUIRecorderPartDuration alloc] initWithBeginTime:beginTime
                                                                                  duration:duration
                                                                               maxDuration:_maxDuration
                                                                                    radius:radius];
        if (beginTime + duration < _maxDuration) {
            [self.layer addSublayer:part.layer];
        }
        [_partDurations addObject:part];
        beginTime += duration;
    }
    
    while (j < _partDurations.count) {
        [_partDurations[j].layer removeFromSuperlayer];
        [_partDurations removeObjectAtIndex:j];
    }
    
    _currentPartDuration = 0.0;
    [self updateProgressUI];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    CGFloat radius = self.radius;
    for (AUIRecorderPartDuration *part in _partDurations) {
        part.radius = radius;
    }
}

@end


// MARK: - AUIRecorderPartDuration
@implementation AUIRecorderPartDuration
- (instancetype)initWithBeginTime:(NSTimeInterval)beginTime
                         duration:(NSTimeInterval)duration
                      maxDuration:(NSTimeInterval)maxDuration
                           radius:(CGFloat)radius {
    self = [super init];
    if (self) {
        [self setupLayer];
        _radius = radius;
        _maxDuration = maxDuration;
        _beginTime = beginTime;
        _duration = duration;
        [self updatePath];
    }
    return self;
}

- (void)updateWithBeginTime:(NSTimeInterval)beginTime duration:(NSTimeInterval)duration {
    _beginTime = beginTime;
    _duration = duration;
    [self updatePath];
}

- (NSTimeInterval)endTime {
    return _beginTime + _duration;
}

- (void) setupLayer {
    if (_layer) {
        return;
    }
    _layer = [CAShapeLayer layer];
    _layer.fillColor = UIColor.clearColor.CGColor;
    _layer.strokeColor = AUIFoundationColor(@"fill_infrared").CGColor;
    _layer.lineWidth = ProgressLineWidth;
    _layer.backgroundColor = UIColor.clearColor.CGColor;
}

- (void) updatePath {
    CGFloat centerAngle = self.endTime / self.maxDuration * M_PI * 2 - M_PI_2;
    CGFloat beginAngle = centerAngle - 1.0 / 180.0 * M_PI;
    CGFloat endAngle = centerAngle + 1.0 / 180.0 * M_PI;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint center = CGPointMake(_radius, _radius);
    [path addArcWithCenter:center
                    radius:_radius - _layer.lineWidth * 0.5
                startAngle:beginAngle
                  endAngle:endAngle
                 clockwise:YES];
    _layer.path = path.CGPath;
}

- (void) setRadius:(CGFloat)radius {
    if (fabs(_radius - radius) <= 0.1) {
        return;
    }
    _radius = radius;
    [self updatePath];
}

@end
