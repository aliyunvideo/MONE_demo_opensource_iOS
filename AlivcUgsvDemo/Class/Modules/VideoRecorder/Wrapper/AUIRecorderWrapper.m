//
//  AUIRecorderWrapper.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/5.
//

#import "AUIRecorderWrapper.h"
#import "AUIUgsvPath.h"
#import "NSString+AVHelper.h"
#import "Masonry.h"
#import "AVAlertController.h"
#import "UIView+AVHelper.h"
#import "AUIUgsvMacro.h"
#import "AlivcUgsvSDKHeader.h"

#ifdef INCLUDE_QUEEN
#import <AliyunQueenUIKit/AliyunQueenUIKit.h>
#endif // INCLUDE_QUEEN

@interface AUIRecorderWrapper ()<AliyunRecorderDelegate, AliyunRecorderCustomRender>
{
    NSMutableArray<NSNumber *> *_partDurations;
}
@property (nonatomic, strong) AliyunRecorderConfig *recorderConfig;

#ifdef INCLUDE_QUEEN
@property (nonatomic, strong) QueenEngine *beautyEngine;
@property (nonatomic, strong) AliyunQueenPanelController *beautyPanelController;
#endif // INCLUDE_QUEEN
@end

@implementation AUIRecorderWrapper

- (instancetype) initWithConfig:(AUIRecorderConfig *)config containerView:(UIView *)containerView {
    self = [super init];
    if (self) {
        _config = config;
        _containerView = containerView;
        _partDurations = @[].mutableCopy;
        [self setupRecorder];
    }
    return self;
}

- (void) setEnabledPreview:(BOOL)enabledPreview {
    if (_enabledPreview == enabledPreview) {
        return;
    }
    _enabledPreview = enabledPreview;
    if (_enabledPreview) {
        [self startPreview];
    } else {
        [self stopPreview];
    }
}

- (NSTimeInterval) duration {
    return _recorder.clipManager.duration;
}

- (NSTimeInterval) lastDuration {
    NSTimeInterval duration = 0;
    for (NSNumber *dur in _partDurations) {
        duration += dur.doubleValue;
    }
    return duration;
}

- (NSArray<NSNumber *> *) partDurations {
    return _partDurations.copy;
}

// MARK: - Actions
- (void) deleteLastPart {
    [_partDurations removeLastObject];
    [_recorder.clipManager deletePart];
}

- (void) startRecord {
    if (_recorder.state == AliyunRecorderState_Stopping) {
        [AVToastView show:AUIUgsvGetString(@"上一段正在存储，请稍等")
                     view:_containerView
                 position:AVToastViewPositionTop];
        return;
    }
    
    int ret = [_recorder startRecord];
    if (ret != ALIVC_COMMON_RETURN_SUCCESS) {
        __weak typeof(self) weakSelf = self;
        [self retryWithErrorTitle:AUIUgsvGetString(@"开始录制失败，是否重试") code:ret action:^(BOOL isCancel) {
            if (!isCancel) {
                [weakSelf startRecord];
            }
        }];
    }
}

- (void) stopRecord {
    [_recorder stopRecord];
}

- (void) cancelRecord {
    [_partDurations removeAllObjects];
    [_recorder cancel];
    if ([_delegate respondsToSelector:@selector(onAUIRecorderWrapperDidCancel:)]) {
        [_delegate onAUIRecorderWrapperDidCancel:self];
    }
}

static void s_retryForFinish(NSError *error, void(^onCompleted)(BOOL isCancel)) {
    [AVAlertController showWithTitle:AUIUgsvGetString(@"完成录制出错，是否重试？")
                             message:error.localizedDescription
                          needCancel:YES
                         onCompleted:onCompleted];
}

- (void)finishRecordSkipMerge:(void(^)(NSString *taskPath, NSError *error))completion {
    __weak typeof(self) weakSelf = self;
    [_recorder finishRecordForEdit:^(NSString *taskPath, NSError *error) {
        if (error) {
            s_retryForFinish(error, ^(BOOL isCancel) {
                if (isCancel) {
                    if (completion) {
                        completion(taskPath, error);
                    }
                    return;
                }
                [weakSelf finishRecordSkipMerge:completion];
            });
            return;
        }
        if (completion) {
            completion(taskPath, error);
        }
    }];
}

- (void)finishRecord:(void(^)(NSString *taskPath, NSString *outputPath, NSError *error))completion {
    NSString *taskPath = _recorderConfig.taskPath;
    __weak typeof(self) weakSelf = self;
    [_recorder finishRecord:^(NSString *outputPath, NSError *error) {
        if (error) {
            s_retryForFinish(error, ^(BOOL isCancel) {
                if (isCancel) {
                    if (completion) {
                        completion(taskPath, nil, error);
                    }
                    return;
                }
                [weakSelf finishRecord:completion];
            });
            return;
        }
        if (completion) {
            completion(taskPath, outputPath, error);
        }
    }];
}

- (void) startPreview {
    int ret = [_recorder startPreview];
    if (ret != ALIVC_COMMON_RETURN_SUCCESS) {
        __weak typeof(self) weakSelf = self;
        [self retryWithErrorTitle:AUIUgsvGetString(@"预览失败，是否重试") code:ret action:^(BOOL isCancel) {
            if (!isCancel) {
                [weakSelf startPreview];
            }
        }];
    }
}

- (void) stopPreview {
    [_recorder stopPreview];
}

// MARK: - AliyunRecorderDelegate
- (void) onAliyunRecorder:(AliyunRecorder *)recorder stateDidChange:(AliyunRecorderState)state {
    if (state == AliyunRecorderState_Stop) {
        NSTimeInterval cur = self.duration - self.lastDuration;
        if (cur > 0) {
            [_partDurations addObject:@(cur)];
        }
    }
    
    if ([_delegate respondsToSelector:@selector(onAUIRecorderWrapper:stateDidChange:)]) {
        [_delegate onAUIRecorderWrapper:self stateDidChange:state];
    }
}

- (void) onAliyunRecorder:(AliyunRecorder *)recorder progressWithDuration:(CGFloat)duration {
    if ([_delegate respondsToSelector:@selector(onAUIRecorderWrapper:progressWithDuration:)]) {
        [_delegate onAUIRecorderWrapper:self progressWithDuration:duration];
    }
}

- (void) onAliyunRecorder:(AliyunRecorder *)recorder occursError:(NSError *)error {
    __weak typeof(self) weakSelf = self;
    [AVAlertController showWithTitle:AUIUgsvGetString(@"录制出错了")
                             message:error.localizedDescription
                          needCancel:NO
                         onCompleted:^(BOOL isCanced) {
        [weakSelf cancelRecord];
    }];
}

- (void) onAliyunRecorderDidStopWithMaxDuration:(AliyunRecorder *)recorder {
    if ([_delegate respondsToSelector:@selector(onAUIRecorderWrapperWantFinish:)]) {
        [_delegate onAUIRecorderWrapperWantFinish:self];
    }
}

// MARK: - AliyunRecorderCustomRender
- (CVPixelBufferRef) onAliyunRecorderCustomRenderToPixelBuffer:(AliyunRecorder *)recorder
                                              withSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CVPixelBufferRef pixelBufferRef = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    if (!pixelBufferRef) {
        return pixelBufferRef;
    }
    
#ifdef INCLUDE_QUEEN
    [self setupBeautyIfNeed];
    QEPixelBufferData *bufferData = [QEPixelBufferData new];
    bufferData.bufferIn = pixelBufferRef;
    bufferData.bufferOut = pixelBufferRef;
    // 对pixelBuffer进行图像处理，输出处理后的buffer
    kQueenResultCode resultCode = [self.beautyEngine processPixelBuffer:bufferData];//执行此方法的线程需要始终是同一条线程
    if (resultCode == kQueenResultCodeOK && bufferData.bufferOut) {
        return bufferData.bufferOut;
    }
    else if (resultCode == kQueenResultCodeInvalidLicense) {
        NSLog(@"============== queen license校验失败。");
    }
    else if (resultCode == kQueenResultCodeInvalidParam) {
        NSLog(@"============== queen 非法参数");
    }
    else if (resultCode == kQueenResultCodeNoEffect) {
//        NSLog(@"============== queen 没有开启任何特效");
    }
#endif // INCLUDE_QUEEN
    
    return pixelBufferRef;
}

- (void) onAliyunRecorderDidDestory:(AliyunRecorder *)recorder {
#ifdef INCLUDE_QUEEN
    [_beautyEngine destroyEngine];
    _beautyEngine = nil;
#endif // INCLUDE_QUEEN
}

// MARK: - Config
- (void) setupRecorder {
    if (_recorder) {
        return;
    }
    
    NSString *randomPath = [AUIUgsvPath exportFilePath:nil];
    _recorderConfig = [[AliyunRecorderConfig alloc] initWithVideoConfig:_config.videoConfig
                                                             outputPath:randomPath
                                                               usingAEC:_config.isUsingAEC];
    [self setupCamera];
    [self setupWaterMark];

    _recorder = [[AliyunRecorder alloc] initWithConfig:_recorderConfig];
    _recorder.clipManager.minDuration = _config.minDuration;
    _recorder.clipManager.maxDuration = _config.maxDuration;
    _recorder.clipManager.deleteVideoClipsOnExit = _config.deleteVideoClipsOnExit;
    _recorder.delegate = self;
    _recorder.customRender = self;
    
    [_recorder prepare];
}

- (void)setupWaterMark {
    if (_config.waterMarkPath.length == 0 || ![NSFileManager.defaultManager fileExistsAtPath:_config.waterMarkPath]) {
        return;
    }
    
    UIImage *waterImg = [UIImage imageWithContentsOfFile:_config.waterMarkPath];
    

    CGRect frame = _config.waterFrame;
    if (frame.size.width == 0 || frame.size.height == 0) {
        frame.size.width = waterImg.size.width;
        frame.size.height = waterImg.size.height;
        frame.origin.x = frame.size.width;
        frame.origin.y = frame.size.height;
    }
    
    AliyunRecorderImageSticker *waterMark = [[AliyunRecorderImageSticker alloc] initWithImagePath:_config.waterMarkPath];
    waterMark.size = frame.size;
    waterMark.center = CGPointMake(frame.origin.x + frame.size.width * 0.5, frame.origin.y + frame.size.height * 0.5);
    waterMark.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_recorderConfig addWaterMark:waterMark];
}

- (void) setupCamera {
    if (_camera) {
        [_recorderConfig removeCamera];
        [_camera removeFromSuperview];
    }
    
    AliyunVideoRecordLayoutParam *layout = [[AliyunVideoRecordLayoutParam alloc] initWithRenderMode:AliyunRenderMode_ResizeAspectFill];
    CGRect frame = _config.cameraFrame;
    CGPoint center = CGPointMake(frame.origin.x + frame.size.width * 0.5, frame.origin.y + frame.size.height * 0.5);
    layout.size = _config.cameraFrame.size;
    layout.center = center;
    
    id<AliyunCameraRecordController> controller = [_recorderConfig addCamera:layout];
    _camera = [[AUIRecorderCameraWrapper alloc] initWithCameraController:controller];
    [_containerView insertSubview:_camera atIndex:0];
    [self updateCameraLayout];
}

- (BOOL) changeResolutionRatio:(AUIRecorderResolutionRatio)ratio {
    if (_recorder.state != AliyunRecorderState_Idle) {
        return NO;
    }
    _config.resolutionRatio = ratio;
    _recorderConfig.videoConfig.resolution = _config.videoConfig.resolution;
    [self updateCameraLayout];
    return YES;
}

#ifdef INCLUDE_QUEEN
- (void) showBeautyPanel {
    [self.beautyPanelController showPanel:YES];
}

- (void)selectedDefaultBeautyPanel {
    [self beautyPanelController];
}

- (AliyunQueenPanelController *) beautyPanelController {
    if (!_beautyPanelController) {
        _beautyPanelController = [[AliyunQueenPanelController alloc] initWithParentView:_containerView];
        [self setupBeautyIfNeed];
        [_beautyPanelController selectDefaultBeautyEffect];
    }
    return _beautyPanelController;
}

- (void) setupBeautyIfNeed {
    if (!_beautyEngine) {
        QueenEngineConfigInfo *configInfo = [QueenEngineConfigInfo new];
        configInfo.runOnCustomThread = NO;
        configInfo.autoSettingImgAngle = YES;
        _beautyEngine = [[QueenEngine alloc] initWithConfigInfo:configInfo];
        if (_beautyPanelController) {
            _beautyPanelController.queenEngine = _beautyEngine;
            if (NSThread.isMainThread) {
                [_beautyPanelController selectCurrentBeautyEffect];
            }
            else {
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.beautyPanelController selectCurrentBeautyEffect];
                });
            }
        }
    }
}
#endif // INCLUDE_QUEEN

const static CGFloat HeaderHeight = 44.0;
- (void) updateCameraLayout {
    // TODO: 加一个高斯模糊+动画；切换前后摄像头也可以同样处理
    CGSize resolution = _recorderConfig.videoConfig.resolution;
    [_camera mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_containerView).inset(HeaderHeight + AVSafeTop).priority(999);
        make.centerY.equalTo(_containerView).priority(998);
        make.bottom.lessThanOrEqualTo(_containerView);
        make.left.right.equalTo(_containerView);
        make.height.equalTo(_camera.mas_width).multipliedBy(resolution.height / resolution.width);
    }];
    [UIView animateWithDuration:0.2 animations:^{
        [self.containerView layoutIfNeeded];
    }];
}

- (void)applyBGMWithPath:(NSString *)path
               beginTime:(NSTimeInterval)beginTime
                duration:(NSTimeInterval)duration {
    [_recorder.config setBgMusicWithFile:path startTime:beginTime duration:duration];
    // TODO: 当前为单源录制模式，添加背景音移除麦克风；后面需要根据场景修改（混音、回声消除等设置）
    [_recorder.config removeMicrophone];
}

- (void)removeBGM {
    // TODO: 当前为单源录制模式，移除背景音添加麦克风；后面需要根据场景修改（混音、回声消除等设置）
    [_recorder.config removeBgMusic];
    [_recorder.config addMicrophone];
}

// MARK: - Helper
- (void) retryWithErrorTitle:(NSString *)title code:(int)code action:(void(^)(BOOL isCancel))action {
    [AVAlertController showWithTitle:title
                             message:[NSString stringWithFormat:AUIUgsvGetString(@"错误码：%d"), code]
                          needCancel:YES
                         onCompleted:^(BOOL isCanced) {
        if (action) {
            action(isCanced);
        }
    }];
}

// MARK: - passthrough
- (AliyunRecorderState) recorderState {
    return _recorder.state;
}

@end
