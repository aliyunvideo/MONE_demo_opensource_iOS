//
//  AUICropPreview.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/12/15.
//

#import "AUICropPreview.h"
#import "Masonry.h"
#import "AUIUgsvMacro.h"
#import "AUIFoundation.h"

@interface AUICropPreview ()<AUIVideoPlayObserver>
@property (nonatomic, assign) CGFloat baseScale;
@property (nonatomic, assign) CGFloat operateScale;
@property (nonatomic, assign) CGPoint operateOffset;

@property (nonatomic, readonly) CGFloat showScale;
@property (nonatomic, readonly) CGPoint showOffset;

@property (nonatomic, assign) BOOL isOperating;
@property (nonatomic, assign) CGFloat operatingScale;
@property (nonatomic, assign) CGPoint operatingOffset;
@property (nonatomic, assign) CGPoint pinchBeginPoint;
@property (nonatomic, assign) CGPoint pinchVector;

@property (nonatomic, strong) UIImageView *playStateImageView;
@property (nonatomic, assign) BOOL isVideoPlaying;

@property (nonatomic, strong) UIView *leftTopMaskView;
@property (nonatomic, strong) UIView *rightBottomMaskView;
@property (nonatomic, strong) UIView *centerMaskView;
@end

@implementation AUICropPreview
- (instancetype) initWithContent:(AUICropPreviewContent *)content
                outputResolution:(CGSize)resolution {
    self = [super init];
    if (self) {
        _operateScale = 1.0;
        _operateOffset = CGPointZero;
        _operatingScale = 1.0;
        _operatingOffset = CGPointZero;
        
        _outputResolution = resolution;
        _content = content;
        [self addSubview:_content];
        [self setupMaskView];
        [self setupVideoState];
        [self setupGesture];
        
        self.clipsToBounds = YES;
    }
    return self;
}

- (void) dealloc {
    [self.content.videoPlayer removeObserver:self];
}

- (CGRect)cropRect {
    CGRect frame = self.centerMaskView.frame;
    frame = [self convertRect:frame toView:self.content];
    frame.origin.x /= self.showScale;
    frame.origin.y /= self.showScale;
    frame.size.width /= self.showScale;
    frame.size.height /= self.showScale;
    return frame;
}

- (void)setIsOperating:(BOOL)isOperating {
    if (_isOperating == isOperating) {
        return;
    }
    _isOperating = isOperating;
    if (isOperating) {
        [self.content.videoPlayer pause];
    }
}

- (CGFloat)showScale {
    return self.baseScale * self.operateScale * (self.isOperating ? self.operatingScale : 1.0);
}

- (CGPoint)showOffset {
    return CGPointMake(self.operateOffset.x + (self.isOperating ? self.operatingOffset.x : 0.0),
                       self.operateOffset.y + (self.isOperating ? self.operatingOffset.y : 0.0));
}

- (void)setupGesture {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture:)];
    [self addGestureRecognizer:tapGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
    [self addGestureRecognizer:panGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinchGesture:)];
    [self addGestureRecognizer:pinchGesture];
}

- (void)makeOperatorValid {
    self.operateScale = MAX(1.0, self.operateScale);
    [self setNeedsLayout];
    [UIView animateWithDuration:0.2 animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)layoutContentWithoutAnimation {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self layoutContent];
    [CATransaction commit];
}

- (void)onTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (self.content.videoPlayer.isPlaying) {
            [self.content.videoPlayer pause];
        } else {
            [self.content.videoPlayer play];
        }
    }
}

- (void)onPinchGesture:(UIPinchGestureRecognizer *)pinGestureRecognizer {
    if (pinGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if (pinGestureRecognizer.numberOfTouches != 2) {
            return;
        }
        _pinchBeginPoint = [pinGestureRecognizer locationInView:self];
        CGPoint contentCenter = CGPointMake(self.content.bounds.size.width*0.5, self.content.bounds.size.height*0.5);
        contentCenter = [self.content convertPoint:contentCenter toView:self];
        _pinchVector = CGPointMake(contentCenter.x - _pinchBeginPoint.x, contentCenter.y - _pinchBeginPoint.y);
    }
    
    if (pinGestureRecognizer.state == UIGestureRecognizerStateBegan ||
        pinGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (pinGestureRecognizer.numberOfTouches != 2) {
            return;
        }
        self.isOperating = YES;
        self.operatingScale = pinGestureRecognizer.scale;
        CGPoint point = CGPointMake(_pinchVector.x * (self.operatingScale - 1.0), _pinchVector.y * (self.operatingScale - 1.0));
        CGPoint offset = [pinGestureRecognizer locationInView:self];
        offset.x -= _pinchBeginPoint.x;
        offset.y -= _pinchBeginPoint.y;
        self.operatingOffset = CGPointMake(point.x + offset.x, point.y + offset.y);
        [self layoutContentWithoutAnimation];
    } else {
        self.isOperating = NO;
        if (pinGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            self.operateScale *= self.operatingScale;
            _operateOffset.x += self.operatingOffset.x;
            _operateOffset.y += self.operatingOffset.y;
            [self makeOperatorValid];
        }
        self.operatingOffset = CGPointZero;
        self.operatingScale = 1.0;
    }
}

- (void)onPanGesture:(UIPanGestureRecognizer *)panGestureRecognizer {
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan ||
        panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        self.isOperating = YES;
        CGPoint translation = [panGestureRecognizer translationInView:self];
        self.operatingOffset = translation;
        [self layoutContentWithoutAnimation];
    } else {
        self.isOperating = NO;
        if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            _operateOffset.x += self.operatingOffset.x;
            _operateOffset.y += self.operatingOffset.y;
            [self makeOperatorValid];
        }
        self.operatingOffset = CGPointZero;
    }
}

- (void)layoutContent {
    CGSize size = self.bounds.size;
    CGRect maskRect = self.centerMaskView.frame;
    self.baseScale = MAX(maskRect.size.width / self.content.resolution.width,
                         maskRect.size.height / self.content.resolution.height);
    CGRect contentRect;
    contentRect.size = CGSizeMake(self.content.resolution.width * self.showScale,
                                  self.content.resolution.height * self.showScale);
    if (!self.isOperating) {
        CGSize offsetRange = CGSizeMake((contentRect.size.width - maskRect.size.width)*0.5,
                                        (contentRect.size.height - maskRect.size.height)*0.5);
        _operateOffset.x = MAX(-offsetRange.width, MIN(offsetRange.width, _operateOffset.x));
        _operateOffset.y = MAX(-offsetRange.height, MIN(offsetRange.height, _operateOffset.y));
    }
    
    contentRect.origin = CGPointMake((size.width - contentRect.size.width) * 0.5 + self.showOffset.x,
                                     (size.height - contentRect.size.height) * 0.5 + self.showOffset.y);
    self.content.frame = contentRect;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize size = self.bounds.size;

    // maskView
    CGRect maskRect;
    if (size.width / size.height > _outputResolution.width / _outputResolution.height) {
        maskRect.size.height = size.height;
        maskRect.size.width = size.height * _outputResolution.width / _outputResolution.height;
    } else {
        maskRect.size.width = size.width;
        maskRect.size.height = size.width * _outputResolution.height / _outputResolution.width;
    }
    maskRect.origin.x = (size.width - maskRect.size.width) * 0.5;
    maskRect.origin.y = (size.height - maskRect.size.height) * 0.5;
    self.centerMaskView.frame = maskRect;
    
    CGSize edgeMaskSize = CGSizeMake(maskRect.origin.x, maskRect.origin.y);
    BOOL hasEdgeMask = (edgeMaskSize.width + edgeMaskSize.height) > 0;
    if (hasEdgeMask) {
        if (edgeMaskSize.width == 0) {
            edgeMaskSize.width = size.width;
        }
        if (edgeMaskSize.height == 0) {
            edgeMaskSize.height = size.height;
        }
    }
    self.leftTopMaskView.hidden = !hasEdgeMask;
    self.leftTopMaskView.frame = CGRectMake(0, 0, edgeMaskSize.width, edgeMaskSize.height);
    self.rightBottomMaskView.hidden = !hasEdgeMask;
    self.rightBottomMaskView.frame = CGRectMake(size.width - edgeMaskSize.width, size.height - edgeMaskSize.height,
                                                edgeMaskSize.width, edgeMaskSize.height);
    
    // content
    [self layoutContent];
    
    // video state
    _playStateImageView.center = CGPointMake(size.width * 0.5, size.height * 0.5);
}

- (UIView *)addMaskView {
    UIView *maskView = [UIView new];
    maskView.userInteractionEnabled = NO;
    maskView.backgroundColor = AUIFoundationColor(@"tsp_fill_weak");
    [self addSubview:maskView];
    return maskView;
}

- (void)setupMaskView {
    _leftTopMaskView = [self addMaskView];
    _rightBottomMaskView = [self addMaskView];
    _centerMaskView = [self addMaskView];
    _centerMaskView.backgroundColor = UIColor.clearColor;
    _centerMaskView.layer.borderColor = UIColor.whiteColor.CGColor;
    _centerMaskView.layer.borderWidth = 2.f;
    [self addSubview:_centerMaskView];
}

- (void)setupVideoState {
    if (!_content.isVideo) {
        return;
    }
    
    _playStateImageView = [[UIImageView alloc] initWithImage:AUIUgsvEditorImage(@"ic_play")];
    _playStateImageView.av_size = CGSizeMake(60, 60);
    [self addSubview:_playStateImageView];
    self.isVideoPlaying = self.content.videoPlayer.isPlaying;
    [self.content.videoPlayer addObserver:self];
}

// MARK: - AUIVideoPlayObserver
- (void)playStatus:(BOOL)isPlaying {
    if (self.isVideoPlaying && !isPlaying) {
        __weak typeof(self) weakSelf = self;
        // 可能是循环播放，延时一下同步
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.isVideoPlaying = weakSelf.content.videoPlayer.isPlaying;
        });
        return;
    }
    self.isVideoPlaying = isPlaying;
}

- (void)setIsVideoPlaying:(BOOL)isVideoPlaying {
    if (_isVideoPlaying == isVideoPlaying) {
        return;
    }
    _isVideoPlaying = isVideoPlaying;
    self.playStateImageView.alpha = isVideoPlaying ? 0.0 : 1.0;
}
@end

// MARK: - AUICropPreviewContent
@implementation AUICropPreviewContent

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        _resolution = image.size;
        _isVideo = NO;
        UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
        [self addSubview:imgView];
        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        self.av_size = _resolution;
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (instancetype)initWithVideo:(id<AUIVideoPlayProtocol>)video resolution:(CGSize)resolution {
    self = [super init];
    if (self) {
        _videoPlayer = video;
        _resolution = resolution;
        _isVideo = YES;
        [video setDisplayView:self];
        self.av_size = _resolution;
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.videoPlayer updateLayoutForDisplayView];
}

@end
