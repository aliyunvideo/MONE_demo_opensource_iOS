//
//  AUIRecorderCameraWrapper.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/5.
//

#import "AUIRecorderCameraWrapper.h"
#import "AVToastView.h"
#import "AUIUgsvMacro.h"
#import "Masonry.h"
#import "AUIRecorderCameraForceView.h"

@interface AUIRecorderCameraWrapper ()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) AUIRecorderCameraForceView *forceView;
@property (nonatomic, assign) CGFloat pinBeginVideoZoomFactor;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@end

@implementation AUIRecorderCameraWrapper

- (instancetype) initWithCameraController:(id<AliyunCameraRecordController>)controller {
    self = [super init];
    if (self) {
        _cameraController = controller;
        [self setupController];
        [self setupGesture];
        [self setupForceView];
    }
    return self;
}

- (void) setupForceView {
    _forceView = [AUIRecorderCameraForceView new];
    [self addSubview:_forceView];
}

- (void) setupController {
    _cameraController.preview = self;
    _cameraController.faceDectectSync = NO;
    _cameraController.faceDetectCount = 2;
    _cameraController.isVideoMirror = NO;
}

// MARK: - Gesture
- (void) setupGesture {
    // pand
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
    _panGesture.delegate = self;
    [self addGestureRecognizer:_panGesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture:)];
    [self addGestureRecognizer:tapGesture];
    
    UIPinchGestureRecognizer *pinGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinchGesture:)];
    [self addGestureRecognizer:pinGesture];
}

- (void) onPanGesture:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan translationInView:self];
    point.y /= self.bounds.size.height;
    [_forceView addExposure:point.y];
    _cameraController.camera.exposureValue = _forceView.currentExposure;
    [pan setTranslation:CGPointZero inView:self];
}

- (void) onTapGesture:(UITapGestureRecognizer *)tapGesture {
    CGPoint point = [tapGesture locationInView:self];
    [_forceView showOnPosition:point];
    _cameraController.camera.exposureValue = _forceView.currentExposure;
    
    CGSize size = self.bounds.size;
    CGPoint normalizedPoint = CGPointMake(point.x/size.width, point.y/size.height);
    [_cameraController.camera adjustForceWithNormalizedPoint:normalizedPoint];
}

- (void) onPinchGesture:(UIPinchGestureRecognizer *)pinchGesture {
    if (isnan(pinchGesture.velocity) || pinchGesture.numberOfTouches != 2) {
        return;
    }
    
    if (pinchGesture.state == UIGestureRecognizerStateBegan) {
        _pinBeginVideoZoomFactor = _cameraController.camera.videoZoomFactor;
    }
    _cameraController.camera.videoZoomFactor = _pinBeginVideoZoomFactor * pinchGesture.scale;
}

// MARK: - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == _panGesture) {
        return _forceView.isShowing;
    }
    return YES;
}

// MARK: - passthrough
- (void) switchCameraPosition {
    AliyunCameraRecordSource *camera = _cameraController.camera;
    if (camera.position == AVCaptureDevicePositionFront) {
        camera.position = AVCaptureDevicePositionBack;
    } else {
        camera.position = AVCaptureDevicePositionFront;
    }
    
    if ([_delegate respondsToSelector:@selector(onAUIRecorderCameraWrapper:torchEnabled:)]) {
        [_delegate onAUIRecorderCameraWrapper:self torchEnabled:self.torchEnabled];
    }
}

- (void) setTorchOpened:(BOOL)torchOpened {
    if (torchOpened) {
        _cameraController.camera.torchMode = AVCaptureTorchModeOn;
    } else {
        _cameraController.camera.torchMode = AVCaptureTorchModeOff;
    }
}

- (BOOL) torchOpened {
    return (_cameraController.camera.torchMode == AVCaptureTorchModeOn);
}

- (BOOL) torchEnabled {
    return _cameraController.camera.hasTorch;
}

- (void) takePhoto {
    __weak typeof(self) weakSelf = self;
    [_cameraController takePhoto:^(UIImage *rawImage, UIImage *image) {
        AUIRecorderCameraWrapper *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        if (!image && !rawImage) {
            [strongSelf showToast:AUIUgsvGetString(@"拍照失败")];
            return;
        }
        
        if (image) {
            UIImageWriteToSavedPhotosAlbum(image, strongSelf, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)strongSelf);
        } else {
            [strongSelf showToast:AUIUgsvGetString(@"获取渲染结果失败")];
        }
    }];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    [self showToast:AUIUgsvGetString(@"照片已保存")];
}

// MARK: - helper
- (void) showToast:(NSString *)msg {
    [AVToastView show:msg view:self.superview position:AVToastViewPositionTop];
}

@end
